%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella specifica per Random Forest v2 (Loop 10 Split)
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v2\tre classi\random_forest_kruskal_v2";

% Crea cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella risultati creata: %s\n', resultsPath);
end

% Caricamento dati V2 (10 Split)
fileName = "data_selected_features_kruskal_v2.mat";
fullDataPath = fullfile(inputPath, fileName);

if ~isfile(fullDataPath), error('File non trovato: %s', fullDataPath); end
fprintf('Caricamento dati Random Forest V2 (10 Split)...\n');

load(fullDataPath, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');

responseVar = 'faultCode';
nSplits = numel(feature_Table_Train_Reduced);

% Vettori per salvare i risultati
test_accuracy = zeros(nSplits,1);
cv_accuracy   = zeros(nSplits,1);

% --- VARIABILI PER LA MATRICE CUMULATIVA ---
All_Y_Test = []; 
All_Y_Pred = [];

% --- VARIABILI PER IL SALVATAGGIO DEL MODELLO MIGLIORE ---
best_test_acc = 0;
Best_Model = [];
best_split_idx = 0;

% Template Albero (Riproducibile)
t = templateTree('Reproducible',true); 

%% 2. CICLO DI TRAINING E TEST (10 ITERAZIONI)
for s = 1:nSplits
    fprintf('\n=== SPLIT %d / %d ===\n', s, nSplits);

    % Estrazione dati
    TrainTbl = feature_Table_Train_Reduced{s};
    TestTbl  = feature_Table_Test_Reduced{s};

    X_Train = TrainTbl(:, setdiff(TrainTbl.Properties.VariableNames, responseVar));
    Y_Train = TrainTbl.(responseVar);
    X_Test = TestTbl(:, setdiff(TestTbl.Properties.VariableNames, responseVar));
    Y_Test = TestTbl.(responseVar);

    % -----------------------
    % 1. Validazione Interna (5-Fold CV)
    % -----------------------
    rng(1+s); % Seed diverso per ogni split
    
    RF_CV_Model = fitcensemble(X_Train, Y_Train, ...
        'Method', 'Bag', ...
        'NumLearningCycles', 30, ...
        'Learners', t, ...
        'KFold', 5);

    cv_accuracy(s) = 1 - kfoldLoss(RF_CV_Model);
    fprintf('CV Accuracy (5-Fold): %.2f%%\n', cv_accuracy(s)*100);

    % -----------------------
    % 2. Test Finale (Su dati mai visti)
    % -----------------------
    Final_RF_Model = fitcensemble(X_Train, Y_Train, ...
        'Method', 'Bag', ...
        'NumLearningCycles', 30, ...
        'Learners', t);

    Y_Test_Pred = predict(Final_RF_Model, X_Test);
    
    % Calcolo accuratezza test
    test_accuracy(s) = sum(Y_Test_Pred == Y_Test) / length(Y_Test);
    fprintf('Test Accuracy: %.2f%%\n', test_accuracy(s)*100);

    % --- SALVATAGGIO DEL MODELLO MIGLIORE ---
    if test_accuracy(s) > best_test_acc
        best_test_acc = test_accuracy(s);
        Best_Model = Final_RF_Model;
        best_split_idx = s;
    end

    % --- ACCUMULO DATI PER MATRICE FINALE ---
    All_Y_Test = [All_Y_Test; Y_Test];
    All_Y_Pred = [All_Y_Pred; Y_Test_Pred];
end

%% 3. RISULTATI FINALI (STATISTICHE)
mean_cv = mean(cv_accuracy) * 100;
std_cv  = std(cv_accuracy) * 100;
mean_test = mean(test_accuracy) * 100;
std_test  = std(test_accuracy) * 100;

fprintf('\n=== RISULTATI MEDI (10 split) ===\n');
fprintf('CV Accuracy:   %.2f ± %.2f %%\n', mean_cv, std_cv);
fprintf('Test Accuracy: %.2f ± %.2f %%\n', mean_test, std_test);
fprintf('Miglior Split: #%d (Acc: %.2f%%)\n', best_split_idx, best_test_acc*100);

%% 4. MATRICE DI CONFUSIONE CUMULATIVA
fig = figure('Name', 'Cumulative Confusion Matrix RF', 'Color', [1 1 1], ...
    'Position', [50, 50, 1000, 700], 'InvertHardcopy', 'off');

cm = confusionchart(All_Y_Test, All_Y_Pred, ...
    'Normalization', 'row-normalized', ... 
    'RowSummary', 'row-normalized');

cm.Title = sprintf('Random Forest Cumulative Results (10 Splits) - Mean Acc: %.2f%%', mean_test);
cm.XLabel = 'Classe Predetta';
cm.YLabel = 'Classe Reale';
cm.FontColor = [0 0 0];
cm.FontName = 'Arial';
cm.FontSize = 12;

% Etichette TPR/FNR
annotation('textbox', [0.71, 0.057, 0.1, 0.05], 'String', 'TPR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
annotation('textbox', [0.805, 0.057, 0.1, 0.05], 'String', 'FNR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

% Salvataggio Immagine
imgFile = fullfile(resultsPath, 'Confusion_Matrix_Cumulative_RandomForest.png');
print(fig, imgFile, '-dpng', '-r300'); 
fprintf('Immagine Matrice Cumulativa salvata in: %s\n', imgFile);

%% 5. EXPLAINABILITY: FEATURE IMPORTANCE (SUL BEST MODEL)
fprintf('\nCalcolo importanza feature (OOB Permuted) sul Miglior Modello...\n');
% Usiamo il miglior modello trovato nel loop per calcolare l'importanza
imp = oobPermutedPredictorImportance(Best_Model);
[sorted_imp, idx] = sort(imp, 'descend');
featureNames = Best_Model.PredictorNames;
top_features = featureNames(idx);

% Plot Feature Importance
fig_imp = figure('Name', 'Random Forest Feature Importance', 'Color', [1 1 1], 'Position', [100, 100, 800, 600]);
num_to_plot = min(10, length(sorted_imp));
barh(sorted_imp(1:num_to_plot)); 
yticklabels(top_features(1:num_to_plot));
xlabel('Importanza (Incremento Errore OOB)', 'Color', 'k');
title(sprintf('Top 10 Feature (Best Split #%d)', best_split_idx), 'Color', 'k');
grid on;
set(gca, 'YDir', 'reverse', 'XColor', 'k', 'YColor', 'k');

% Salvataggio Immagine Feature Importance
impFile = fullfile(resultsPath, 'Feature_Importance_Best_RF.png');
print(fig_imp, impFile, '-dpng', '-r300');
fprintf('Immagine Feature Importance salvata in: %s\n', impFile);

%% 6. REPORT TESTUALE DETTAGLIATO
txtFile = fullfile(resultsPath, 'Report_Loop_10Split_RandomForest.txt');
fid = fopen(txtFile, 'w');
fprintf(fid, '=== REPORT RANDOM FOREST (30 ALBERI) - 10 SPLIT AGGREGATI ===\n');
fprintf(fid, 'Accuracy Media Test: %.2f ± %.2f %%\n', mean_test, std_test);
fprintf(fid, 'Miglior Modello Trovato: Split #%d (%.2f%%)\n', best_split_idx, best_test_acc*100);

% --- DETTAGLIO PER OGNI SPLIT ---
fprintf(fid, '---------------------------------------------------\n');
fprintf(fid, 'DETTAGLIO PERFORMANCE PER OGNI SPLIT:\n');
for k = 1:nSplits
    fprintf(fid, 'Split %2d -> CV Accuracy: %6.2f%%  |  Test Accuracy: %6.2f%%\n', ...
        k, cv_accuracy(k)*100, test_accuracy(k)*100);
end
% --------------------------------

fprintf(fid, '---------------------------------------------------\n');
fprintf(fid, 'ANALISI AGGREGATA SU %d VOLI TOTALI (Somma di 10 Test Set)\n', length(All_Y_Test));

% Analisi Falsi Allarmi Cumulativa
C = confusionmat(All_Y_Test, All_Y_Pred);
classes = categories(All_Y_Test);
idx_0 = find(strcmp(classes, '0'));

if ~isempty(idx_0)
    total_NoFault = sum(C(idx_0, :));
    correct_NoFault = C(idx_0, idx_0);
    false_alarms = total_NoFault - correct_NoFault;
    fprintf(fid, '\nFALSI ALLARMI (Classe 0 predetta come Guasto):\n');
    fprintf(fid, ' - Su %d casi "Sani" totali testati,\n', total_NoFault);
    fprintf(fid, ' - %d sono stati confusi (%.2f%% tasso errore medio)\n', false_alarms, (false_alarms/total_NoFault)*100);
end

fprintf(fid, '\n---------------------------------------------------\n');
fprintf(fid, 'TOP 5 FEATURE PIU'' IMPORTANTI (BEST MODEL):\n');
for k = 1:5
    fprintf(fid, '%d. %s (Score: %.4f)\n', k, top_features{k}, sorted_imp(k));
end

fclose(fid);
fprintf('Report salvato in: %s\n', txtFile);

%% 7. SALVATAGGIO DEL MODELLO MIGLIORE (.mat)
modelFile = fullfile(resultsPath, 'Best_RandomForest_Model.mat');
save(modelFile, 'Best_Model', 'best_test_acc', 'best_split_idx', 'top_features', 'sorted_imp');
fprintf('Miglior Modello Random Forest salvato in: %s\n', modelFile);