%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella di destinazione (Coerente con Decision Tree)
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results\due classi\decision_tree_anova";

% Crea cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella creata: %s\n', resultsPath);
end

% Caricamento dati (Versione ANOVA)
load(fullfile(inputPath, "data_selected_features_anova.mat"), 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');

responseVar = 'faultCode';
X_Train = feature_Table_Train_Reduced(:, setdiff(feature_Table_Train_Reduced.Properties.VariableNames, responseVar));
Y_Train = feature_Table_Train_Reduced.(responseVar);
X_Test = feature_Table_Test_Reduced(:, setdiff(feature_Table_Test_Reduced.Properties.VariableNames, responseVar));
Y_Test = feature_Table_Test_Reduced.(responseVar);

% CONVERSIONE BINARIA (0 vs 1)
% Uniamo le classi 5 e 10 in "1" (Guasto)
Y_Train = mergecats(Y_Train, {'5', '10'}, '1');
Y_Test  = mergecats(Y_Test,  {'5', '10'}, '1');

%% 2. TRAINING CON CROSS-VALIDATION (5-FOLD)
fprintf('Addestramento Albero Decisionale Binario (5-Fold CV)...\n');
rng(1); 

% Configurazione Albero con CV
% 'PredictorSelection', 'curvature': Evita bias verso variabili con molti livelli
Tree_CV_Model = fitctree(X_Train, Y_Train, ...
    'KFold', 5, ...
    'PredictorSelection', 'curvature', ...
    'Surrogate', 'off');

% Calcolo Accuratezza Media di Validazione
cv_accuracy = 1 - kfoldLoss(Tree_CV_Model);
fprintf('Validazione (K-Fold=5) Accuracy: %.2f%%\n', cv_accuracy * 100);

%% 3. MODELLO FINALE E TEST
fprintf('Addestramento modello finale su tutto il training set...\n');
% Addestriamo l'albero finale su tutti i dati di training per il test
Final_Model = fitctree(X_Train, Y_Train, ...
    'PredictorSelection', 'curvature', ...
    'Surrogate', 'off');

% Predizione su dati mai visti (Test Set)
Y_Test_Pred = predict(Final_Model, X_Test);
test_accuracy = sum(Y_Test_Pred == Y_Test) / length(Y_Test);
fprintf('Test Set Accuracy: %.2f%%\n', test_accuracy * 100);

%% 4. MATRICE DI CONFUSIONE CON ETICHETTE MANUALI
fig = figure('Name', 'Binary Decision Tree Confusion Matrix', 'Color', [1 1 1], ...
    'Position', [50, 50, 1000, 700], 'InvertHardcopy', 'off');

% Generazione Grafico Base
cm = confusionchart(Y_Test, Y_Test_Pred, ...
    'Normalization', 'row-normalized', ...  
    'RowSummary', 'row-normalized');  

cm.Title = sprintf('Decision Tree Binario - Accuracy: %.2f%%', test_accuracy*100);
cm.XLabel = 'Classe Predetta (0=Sano, 1=Guasto)';
cm.YLabel = 'Classe Reale (0=Sano, 1=Guasto)';
cm.FontColor = [0 0 0];
cm.FontName = 'Arial';
cm.FontSize = 12;

% --- AGGIUNTA ETICHETTE CON COORDINATE RICALIBRATE ---
% Etichette a Destra (TPR / FNR)
annotation('textbox', [0.69, 0.057, 0.1, 0.05], 'String', 'TPR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
annotation('textbox', [0.80, 0.057, 0.1, 0.05], 'String', 'FNR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

% Salvataggio Immagine
imgFile = fullfile(resultsPath, 'Confusion_Matrix_Binary_Decision_Tree.png');
print(fig, imgFile, '-dpng', '-r300'); 
fprintf('Immagine salvata in: %s\n', imgFile);

%% 5. REPORT TESTUALE
C = confusionmat(Y_Test, Y_Test_Pred);
TN = C(1,1); FP = C(1,2); FN = C(2,1); TP = C(2,2);

txtFile = fullfile(resultsPath, 'Report_Binary_Decision_Tree.txt');
fid = fopen(txtFile, 'w');
fprintf(fid, '=== REPORT DECISION TREE BINARIO (ANOVA) ===\n');
fprintf(fid, 'Validazione (5-Fold CV): %.2f%%\n', cv_accuracy*100);
fprintf(fid, 'Test Set Accuracy:       %.2f%%\n', test_accuracy*100);
fprintf(fid, '-----------------------------------\n');
fprintf(fid, 'Voli Sani:   %d (TN:%d, FP:%d)\n', TN+FP, TN, FP);
fprintf(fid, 'Voli Guasti: %d (TP:%d, FN:%d)\n', TP+FN, TP, FN);
fclose(fid);
fprintf('Report salvato in: %s\n', txtFile);