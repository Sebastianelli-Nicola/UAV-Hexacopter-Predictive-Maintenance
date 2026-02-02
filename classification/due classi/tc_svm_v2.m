%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella specifica per SVM Binaria v2 (Loop 10 Split)
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v2\due classi\svm_anova_v2";

% Crea cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella risultati creata: %s\n', resultsPath);
end

% Caricamento dati V2 (10 Split)
fileName = "data_selected_features_anova_v2.mat";
fullDataPath = fullfile(inputPath, fileName);

if ~isfile(fullDataPath), error('File non trovato: %s', fullDataPath); end
fprintf('Caricamento dati V2 (10 Split)...\n');

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

%% 2. CICLO DI TRAINING E TEST (10 ITERAZIONI)
% Template SVM: utile per definire i parametri una volta sola
% Kernel Quadratica (Polynomial Order 2)
% Standardize = true (FONDAMENTALE per SVM)
svmTemplate = templateSVM('KernelFunction', 'polynomial', ...
                          'PolynomialOrder', 2, ...
                          'Standardize', true);

for s = 1:nSplits
    fprintf('\n=== SPLIT %d / %d ===\n', s, nSplits);

    % Estrazione dati dallo split corrente
    TrainTbl = feature_Table_Train_Reduced{s};
    TestTbl  = feature_Table_Test_Reduced{s};

    % --- CONVERSIONE BINARIA ---
    % Uniamo le classi '5' e '10' in '1' (Guasto)
    TrainTbl.(responseVar) = mergecats(TrainTbl.(responseVar), {'5', '10'}, '1');
    TestTbl.(responseVar)  = mergecats(TestTbl.(responseVar),  {'5', '10'}, '1');

    % Estrazione X e Y
    X_Train = TrainTbl(:, setdiff(TrainTbl.Properties.VariableNames, responseVar));
    Y_Train = TrainTbl.(responseVar);
    X_Test = TestTbl(:, setdiff(TestTbl.Properties.VariableNames, responseVar));
    Y_Test = TestTbl.(responseVar);

    % -----------------------
    % 1. Validazione Interna (5-Fold CV)
    % -----------------------
    rng(1+s); % Seed diverso per ogni split
    
    % fitcsvm è specifico per classificazione binaria
    SVM_CV_Model = fitcsvm(X_Train, Y_Train, ...
        'KernelFunction', 'polynomial', ...
        'PolynomialOrder', 2, ...
        'Standardize', true, ...
        'KFold', 5);

    cv_accuracy(s) = 1 - kfoldLoss(SVM_CV_Model);
    fprintf('CV Accuracy (5-Fold): %.2f%%\n', cv_accuracy(s)*100);

    % -----------------------
    % 2. Test Finale (Su dati mai visti)
    % -----------------------
    Final_SVM_Model = fitcsvm(X_Train, Y_Train, ...
        'KernelFunction', 'polynomial', ...
        'PolynomialOrder', 2, ...
        'Standardize', true);

    Y_Test_Pred = predict(Final_SVM_Model, X_Test);
    
    % Calcolo accuratezza test
    test_accuracy(s) = sum(Y_Test_Pred == Y_Test) / length(Y_Test);
    fprintf('Test Accuracy: %.2f%%\n', test_accuracy(s)*100);

    % --- SALVATAGGIO DEL MODELLO MIGLIORE ---
    if test_accuracy(s) > best_test_acc
        best_test_acc = test_accuracy(s);
        Best_Model = Final_SVM_Model;
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

%% 4. MATRICE DI CONFUSIONE CUMULATIVA (BINARIA)
fig = figure('Name', 'Cumulative Confusion Matrix Binary SVM', 'Color', [1 1 1], ...
    'Position', [50, 50, 1000, 700], 'InvertHardcopy', 'off');

cm = confusionchart(All_Y_Test, All_Y_Pred, ...
    'Normalization', 'row-normalized', ... 
    'RowSummary', 'row-normalized');

cm.Title = sprintf('SVM Quadratica Cumulative Results (10 Splits) - Mean Acc: %.2f%%', mean_test);
cm.XLabel = 'Classe Predetta (0=Sano, 1=Guasto)';
cm.YLabel = 'Classe Reale (0=Sano, 1=Guasto)';
cm.FontColor = [0 0 0];
cm.FontName = 'Arial';
cm.FontSize = 12;

% Etichette TPR/FNR
annotation('textbox', [0.71, 0.057, 0.1, 0.05], 'String', 'TPR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
annotation('textbox', [0.805, 0.057, 0.1, 0.05], 'String', 'FNR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

% Salvataggio Immagine
imgFile = fullfile(resultsPath, 'Confusion_Matrix_Cumulative_Binary_SVM.png');
print(fig, imgFile, '-dpng', '-r300'); 
fprintf('Immagine Matrice Cumulativa salvata in: %s\n', imgFile);

%% 5. REPORT TESTUALE DETTAGLIATO
txtFile = fullfile(resultsPath, 'Report_Loop_10Split_Binary_SVM.txt');
fid = fopen(txtFile, 'w');
fprintf(fid, '=== REPORT SVM BINARIO - 10 SPLIT AGGREGATI ===\n');
fprintf(fid, 'Accuracy Media Test: %.2f ± %.2f %%\n', mean_test, std_test);
fprintf(fid, 'Miglior Modello Trovato: Split #%d (%.2f%%)\n', best_split_idx, best_test_acc*100);

% --- DETTAGLIO PER OGNI SPLIT ---
fprintf(fid, '---------------------------------------------------\n');
fprintf(fid, 'DETTAGLIO PERFORMANCE PER OGNI SPLIT:\n');
for k = 1:nSplits
    fprintf(fid, 'Split %2d -> CV Accuracy: %6.2f%%  |  Test Accuracy: %6.2f%%\n', ...
        k, cv_accuracy(k)*100, test_accuracy(k)*100);
end

fprintf(fid, '---------------------------------------------------\n');
fprintf(fid, 'ANALISI AGGREGATA SU %d VOLI TOTALI (Somma di 10 Test Set)\n', length(All_Y_Test));

% Matrice Cumulativa Numerica
C = confusionmat(All_Y_Test, All_Y_Pred);
TN = C(1,1); FP = C(1,2); 
FN = C(2,1); TP = C(2,2);

fprintf(fid, '\nMATRICE DI CONFUSIONE SOMMATA:\n');
fprintf(fid, 'Voli Sani (Reali):   %d -> Riconosciuti: %d (TN), Errati: %d (FP)\n', TN+FP, TN, FP);
fprintf(fid, 'Voli Guasti (Reali): %d -> Riconosciuti: %d (TP), Errati: %d (FN)\n', TP+FN, TP, FN);

% Metriche specifiche
accuracy = (TP+TN) / (TP+TN+FP+FN);
sensitivity = TP / (TP+FN); % Recall
specificity = TN / (TN+FP);
precision = TP / (TP+FP);
f1_score = 2 * (precision * sensitivity) / (precision + sensitivity);

fprintf(fid, '\nMETRICHE GLOBALI:\n');
fprintf(fid, ' - Accuracy:    %.2f%%\n', accuracy*100);
fprintf(fid, ' - Sensitivity: %.2f%% (Capacità di trovare i guasti)\n', sensitivity*100);
fprintf(fid, ' - Specificity: %.2f%% (Capacità di evitare falsi allarmi)\n', specificity*100);
fprintf(fid, ' - F1-Score:    %.4f\n', f1_score);

fclose(fid);
fprintf('Report salvato in: %s\n', txtFile);

%% 6. SALVATAGGIO DEL MODELLO MIGLIORE (.mat)
modelFile = fullfile(resultsPath, 'Best_Binary_SVM_Model.mat');
save(modelFile, 'Best_Model', 'best_test_acc', 'best_split_idx');
fprintf('Miglior Modello Binario SVM salvato in: %s\n', modelFile);