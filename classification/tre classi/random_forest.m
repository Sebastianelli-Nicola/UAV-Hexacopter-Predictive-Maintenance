%% 1. CARICAMENTO DATI E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella specifica per Random Forest
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results\tre classi\random_forest_prova";

% Crea cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella creata: %s\n', resultsPath);
end

fileName = "data_selected_features.mat";
fullDataPath = fullfile(inputPath, fileName);
if ~isfile(fullDataPath), error('File non trovato: %s', fullDataPath); end

fprintf('Caricamento dati Ensemble/Random Forest (3 Classi)...\n');
load(fullDataPath, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');

% Definizione Variabili
responseVar = 'faultCode';
X_Train = feature_Table_Train_Reduced(:, setdiff(feature_Table_Train_Reduced.Properties.VariableNames, responseVar));
Y_Train = feature_Table_Train_Reduced.(responseVar);
X_Test = feature_Table_Test_Reduced(:, setdiff(feature_Table_Test_Reduced.Properties.VariableNames, responseVar));
Y_Test = feature_Table_Test_Reduced.(responseVar);

%% 2. TRAINING & VALIDAZIONE (5-Fold CV)
fprintf('\n--- Addestramento Bagged Trees (30 Alberi, 5-Fold CV) ---\n');
rng(1); 

t = templateTree('Reproducible',true); 
Ensemble_CV_Model = fitcensemble(X_Train, Y_Train, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 30, ...
    'Learners', t, ...
    'KFold', 5);

cv_accuracy = 1 - kfoldLoss(Ensemble_CV_Model);
fprintf('Validazione (K-Fold=5) Accuracy: %.2f%%\n', cv_accuracy * 100);

%% 3. MODELLO FINALE E TEST
fprintf('Addestramento modello finale su tutto il training set...\n');
Final_Ensemble_Model = fitcensemble(X_Train, Y_Train, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 30, ...
    'Learners', t);

fprintf('\n--- Test su Dati Mai Visti (Testing Set) ---\n');
Y_Test_Pred = predict(Final_Ensemble_Model, X_Test);
test_accuracy = sum(Y_Test_Pred == Y_Test) / length(Y_Test);
fprintf('Test Set Accuracy: %.2f%%\n', test_accuracy * 100);

%% 4. VISUALIZZAZIONE MATRICE DI CONFUSIONE (Layout Avanzato)
fig = figure('Name', 'Random Forest Confusion Matrix', 'Color', [1 1 1], ...
    'Position', [50, 50, 1000, 700], 'InvertHardcopy', 'off');

% Plot Confusion Matrix
cm = confusionchart(Y_Test, Y_Test_Pred, ...
    'Normalization', 'row-normalized', ...  
    'RowSummary', 'row-normalized');     

cm.Title = sprintf('Random Forest (3 Classi) - Accuracy: %.2f%%', test_accuracy*100);
cm.XLabel = 'Classe Predetta';
cm.YLabel = 'Classe Reale';
cm.FontColor = [0 0 0];
cm.FontName = 'Arial';
cm.FontSize = 12;

% --- AGGIUNTA ETICHETTE MANUALI (TPR/FNR) ---
annotation('textbox', [0.71, 0.057, 0.1, 0.05], 'String', 'TPR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
annotation('textbox', [0.805, 0.057, 0.1, 0.05], 'String', 'FNR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

% Salvataggio Immagine CM
imgFile = fullfile(resultsPath, 'Confusion_Matrix_3Class_RandomForest.png');
print(fig, imgFile, '-dpng', '-r300'); 
fprintf('Immagine CM salvata in: %s\n', imgFile);

%% 5. EXPLAINABILITY: IMPORTANZA DELLE FEATURE (OOB)
fprintf('\nCalcolo importanza feature (OOB Permuted)...\n');
imp = oobPermutedPredictorImportance(Final_Ensemble_Model);

[sorted_imp, idx] = sort(imp, 'descend');
featureNames = X_Train.Properties.VariableNames;
top_features = featureNames(idx);

% Plot Feature Importance
fig_imp = figure('Name', 'Ensemble Feature Importance', 'Color', [1 1 1], 'Position', [100, 100, 800, 600]);
num_to_plot = min(10, length(sorted_imp));
barh(sorted_imp(1:num_to_plot)); 
yticklabels(top_features(1:num_to_plot));
xlabel('Importanza (Incremento Errore OOB)', 'Color', 'k');
title('Top 10 Feature per il Modello Ensemble', 'Color', 'k');
grid on;
set(gca, 'YDir', 'reverse', 'XColor', 'k', 'YColor', 'k');

% Salvataggio Immagine Feature Importance
impFile = fullfile(resultsPath, 'Feature_Importance_RF.png');
print(fig_imp, impFile, '-dpng', '-r300');
fprintf('Immagine Feature Importance salvata in: %s\n', impFile);

%% 6. REPORT TESTUALE
C = confusionmat(Y_Test, Y_Test_Pred);
classes = categories(Y_Test); 
idx_0 = find(strcmp(classes, '0')); 

txtFile = fullfile(resultsPath, 'Report_3Class_RandomForest.txt');
fid = fopen(txtFile, 'w');

fprintf(fid, '=== REPORT RANDOM FOREST (3 CLASSI) ===\n');
fprintf(fid, 'Accuratezza Globale: %.2f%%\n', test_accuracy * 100);
fprintf(fid, '--------------------------------------------\n');

if ~isempty(idx_0)
    total_NoFault = sum(C(idx_0, :));
    correct_NoFault = C(idx_0, idx_0);
    false_alarms = total_NoFault - correct_NoFault;
    perc_false_alarms = (false_alarms/total_NoFault)*100;
    
    fprintf(fid, 'ANALISI CLASSE "0" (NO GUASTO):\n');
    fprintf(fid, ' - Totale Voli Sani:       %d\n', total_NoFault);
    fprintf(fid, ' - Riconosciuti Sani:      %d\n', correct_NoFault);
    fprintf(fid, ' - FALSI ALLARMI (Errori): %d (%.2f%%)\n', false_alarms, perc_false_alarms);
    
    if false_alarms > 0
        fprintf(fid, '   NOTA: Il Random Forest ha classificato %d voli sani come guasti.\n', false_alarms);
    else
        fprintf(fid, '   OTTIMO: Nessun falso allarme generato.\n');
    end
end

fprintf(fid, '\nDETTAGLIO MATRICE DI CONFUSIONE:\n');
for i = 1:length(classes)
    cls = classes{i};
    tot = sum(C(i,:));
    corr = C(i,i);
    fprintf(fid, 'Classe %s: %d/%d corretti (%.2f%%)\n', cls, corr, tot, (corr/tot)*100);
end

fprintf(fid, '\n--------------------------------------------\n');
fprintf(fid, 'TOP 3 FEATURE PIU'' IMPORTANTI (OOB):\n');
for k = 1:3
    fprintf(fid, '%d. %s (Score: %.4f)\n', k, top_features{k}, sorted_imp(k));
end

fclose(fid);
fprintf('Report testuale salvato in: %s\n', txtFile);