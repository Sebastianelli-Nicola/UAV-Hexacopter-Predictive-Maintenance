%% 1. CARICAMENTO DATI E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella specifica per Neural Network
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results\tre classi\neural_network_anova";

% Crea cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella creata: %s\n', resultsPath);
end

fileName = "data_selected_features_anova.mat";
fullDataPath = fullfile(inputPath, fileName);
if ~isfile(fullDataPath), error('File non trovato: %s', fullDataPath); end

fprintf('Caricamento dati Neural Network (3 Classi)...\n');
load(fullDataPath, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');

% Definizione Variabili
responseVar = 'faultCode';
X_Train = feature_Table_Train_Reduced(:, setdiff(feature_Table_Train_Reduced.Properties.VariableNames, responseVar));
Y_Train = feature_Table_Train_Reduced.(responseVar);
X_Test = feature_Table_Test_Reduced(:, setdiff(feature_Table_Test_Reduced.Properties.VariableNames, responseVar));
Y_Test = feature_Table_Test_Reduced.(responseVar);

%% 2. TRAINING & VALIDAZIONE (5-Fold CV)
fprintf('\n--- Addestramento Neural Network (Medium, 25 Neuroni) ---\n');
rng(1); 

% Configurazione Medium NN:
% - LayerSizes: 25
% - Activations: ReLU
% - Standardize: true (FONDAMENTALE)
NN_CV_Model = fitcnet(X_Train, Y_Train, ...
    'LayerSizes', 25, ...          
    'Activations', 'relu', ...     
    'Standardize', true, ...       
    'KFold', 5);

cv_accuracy = 1 - kfoldLoss(NN_CV_Model);
fprintf('Validazione (K-Fold=5) Accuracy: %.2f%%\n', cv_accuracy * 100);

%% 3. MODELLO FINALE E TEST
fprintf('Addestramento modello finale su tutto il training set...\n');
Final_NN_Model = fitcnet(X_Train, Y_Train, ...
    'LayerSizes', 25, ...
    'Activations', 'relu', ...
    'Standardize', true);

fprintf('\n--- Test su Dati Mai Visti (Testing Set) ---\n');
Y_Test_Pred = predict(Final_NN_Model, X_Test);
test_accuracy = sum(Y_Test_Pred == Y_Test) / length(Y_Test);
fprintf('Test Set Accuracy: %.2f%%\n', test_accuracy * 100);

%% 4. VISUALIZZAZIONE MATRICE DI CONFUSIONE (Layout Avanzato)
fig = figure('Name', 'Neural Network Confusion Matrix', 'Color', [1 1 1], ...
    'Position', [50, 50, 1000, 700], 'InvertHardcopy', 'off');

cm = confusionchart(Y_Test, Y_Test_Pred, ...
    'Normalization', 'row-normalized', ...  
    'RowSummary', 'row-normalized');     

cm.Title = sprintf('Neural Network (3 Classi) - Accuracy: %.2f%%', test_accuracy*100);
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
imgFile = fullfile(resultsPath, 'Confusion_Matrix_3Class_NN.png');
print(fig, imgFile, '-dpng', '-r300'); 
fprintf('Immagine CM salvata in: %s\n', imgFile);

%% 5. EXPLAINABILITY: PERMUTATION FEATURE IMPORTANCE
fprintf('\n--- Calcolo Feature Importance ---\n');
featureNames = X_Train.Properties.VariableNames;
base_loss = loss(Final_NN_Model, X_Test, Y_Test);
importance_scores = zeros(length(featureNames), 1);

for i = 1:length(featureNames)
    X_Test_Permuted = X_Test;
    % Permutazione casuale della colonna i-esima
    X_Test_Permuted.(featureNames{i}) = X_Test_Permuted.(featureNames{i})(randperm(height(X_Test)));
    % Calcolo perdita
    permuted_loss = loss(Final_NN_Model, X_Test_Permuted, Y_Test);
    importance_scores(i) = permuted_loss - base_loss;
end

[sorted_scores, idx] = sort(importance_scores, 'descend');
top_features = featureNames(idx);

% Plot Feature Importance
fig_imp = figure('Name', 'NN Feature Importance', 'Color', [1 1 1], 'Position', [100, 100, 800, 600]);
barh(sorted_scores(1:10));
yticklabels(top_features(1:10));
xlabel('Aumento dell''Errore (Importance)', 'Color', 'k');
title('Top 10 Feature Cruciali per la Rete Neurale', 'Color', 'k');
grid on;
set(gca, 'YDir', 'reverse', 'XColor', 'k', 'YColor', 'k');

% Salvataggio Immagine Feature Importance
impFile = fullfile(resultsPath, 'Feature_Importance_NN.png');
print(fig_imp, impFile, '-dpng', '-r300');
fprintf('Immagine Feature Importance salvata in: %s\n', impFile);

%% 6. REPORT TESTUALE
C = confusionmat(Y_Test, Y_Test_Pred);
classes = categories(Y_Test); 
idx_0 = find(strcmp(classes, '0')); 

txtFile = fullfile(resultsPath, 'Report_3Class_NN.txt');
fid = fopen(txtFile, 'w');

fprintf(fid, '=== REPORT NEURAL NETWORK (3 CLASSI) ===\n');
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
end

fprintf(fid, '\nDETTAGLIO MATRICE DI CONFUSIONE:\n');
for i = 1:length(classes)
    cls = classes{i};
    tot = sum(C(i,:));
    corr = C(i,i);
    fprintf(fid, 'Classe %s: %d/%d corretti (%.2f%%)\n', cls, corr, tot, (corr/tot)*100);
end

fprintf(fid, '\n--------------------------------------------\n');
fprintf(fid, 'TOP 3 FEATURE PIU'' IMPORTANTI (Explainability):\n');
for k = 1:3
    fprintf(fid, '%d. %s (Score: %.4f)\n', k, top_features{k}, sorted_scores(k));
end

fclose(fid);
fprintf('Report testuale salvato in: %s\n', txtFile);