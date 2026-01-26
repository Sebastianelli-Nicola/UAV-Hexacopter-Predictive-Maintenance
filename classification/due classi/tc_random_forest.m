%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella specifica per Random Forest (ANOVA)
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results\due classi\random_forest_anova";

% Crea cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella creata: %s\n', resultsPath);
end

% Caricamento dati ANOVA
load(fullfile(inputPath, "data_selected_features_anova.mat"), 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');

responseVar = 'faultCode';
X_Train = feature_Table_Train_Reduced(:, setdiff(feature_Table_Train_Reduced.Properties.VariableNames, responseVar));
Y_Train = feature_Table_Train_Reduced.(responseVar);
X_Test = feature_Table_Test_Reduced(:, setdiff(feature_Table_Test_Reduced.Properties.VariableNames, responseVar));
Y_Test = feature_Table_Test_Reduced.(responseVar);

% CONVERSIONE BINARIA
Y_Train = mergecats(Y_Train, {'5', '10'}, '1');
Y_Test  = mergecats(Y_Test,  {'5', '10'}, '1');

%% 2. TRAINING CON CROSS-VALIDATION (5-FOLD)
fprintf('Addestramento Random Forest Binario (50 Alberi) con 5-Fold CV...\n');
rng(1);

% Configurazione Albero
t = templateTree('Reproducible',true);

% 1. Modello Cross-Validato
RF_CV_Model = fitcensemble(X_Train, Y_Train, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 50, ...
    'Learners', t, ...
    'KFold', 5); % Attiva la CV

% Calcolo accuratezza media sui 5 fold
cv_accuracy = 1 - kfoldLoss(RF_CV_Model);
fprintf('Validazione (5-Fold) Accuracy: %.2f%%\n', cv_accuracy * 100);

% 2. Modello Finale (Addestrato su TUTTO il training set per il test finale)
fprintf('Addestramento modello finale...\n');
Final_Model = fitcensemble(X_Train, Y_Train, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 50, ...
    'Learners', t);

% Test su dati mai visti
Y_Test_Pred = predict(Final_Model, X_Test);
test_accuracy = sum(Y_Test_Pred == Y_Test) / length(Y_Test);
fprintf('Test Set Accuracy:       %.2f%%\n', test_accuracy * 100);

%% 3. MATRICE DI CONFUSIONE CON ETICHETTE MANUALI
fig = figure('Name', 'Binary Random Forest Confusion Matrix', 'Color', [1 1 1], ...
    'Position', [50, 50, 1000, 700], 'InvertHardcopy', 'off');

% Generazione Grafico Base
cm = confusionchart(Y_Test, Y_Test_Pred, ...
    'Normalization', 'row-normalized', ...  
    'RowSummary', 'row-normalized');  

cm.Title = sprintf('Random Forest (50 Trees) - Accuracy: %.2f%%', test_accuracy*100);
cm.XLabel = 'Classe Predetta (0=Sano, 1=Guasto)';
cm.YLabel = 'Classe Reale (0=Sano, 1=Guasto)';
cm.FontColor = [0 0 0];
cm.FontName = 'Arial';
cm.FontSize = 12;

% --- AGGIUNTA ETICHETTE (Coordinate calibrate) ---
annotation('textbox', [0.69, 0.057, 0.1, 0.05], 'String', 'TPR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
annotation('textbox', [0.80, 0.057, 0.1, 0.05], 'String', 'FNR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

% Salvataggio
imgFile = fullfile(resultsPath, 'Confusion_Matrix_Binary_Random_Forest.png');
print(fig, imgFile, '-dpng', '-r300'); 
fprintf('Immagine Random Forest salvata in: %s\n', imgFile);

%% 4. REPORT TESTUALE
C = confusionmat(Y_Test, Y_Test_Pred);
TN = C(1,1); FP = C(1,2); FN = C(2,1); TP = C(2,2);

txtFile = fullfile(resultsPath, 'Report_Binary_Random_Forest.txt');
fid = fopen(txtFile, 'w');
fprintf(fid, '=== REPORT RANDOM FOREST BINARIO (ANOVA) ===\n');
fprintf(fid, 'Validazione (5-Fold CV): %.2f%%\n', cv_accuracy*100);
fprintf(fid, 'Accuratezza Test Set:    %.2f%%\n', test_accuracy*100);
fprintf(fid, '-----------------------------------\n');
fprintf(fid, 'Voli Sani:   %d (TN:%d, FP:%d)\n', TN+FP, TN, FP);
fprintf(fid, 'Voli Guasti: %d (TP:%d, FN:%d)\n', TP+FN, TP, FN);
fclose(fid);
fprintf('Report salvato in: %s\n', txtFile);