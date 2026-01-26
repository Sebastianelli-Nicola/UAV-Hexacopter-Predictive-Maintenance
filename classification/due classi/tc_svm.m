%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% MODIFICA: Cartella specifica per SVM
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results\due classi\svm";

if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

load(fullfile(inputPath, "data_selected_features.mat"), 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');
responseVar = 'faultCode';

X_Train = feature_Table_Train_Reduced(:, setdiff(feature_Table_Train_Reduced.Properties.VariableNames, responseVar));
Y_Train = feature_Table_Train_Reduced.(responseVar);
X_Test = feature_Table_Test_Reduced(:, setdiff(feature_Table_Test_Reduced.Properties.VariableNames, responseVar));
Y_Test = feature_Table_Test_Reduced.(responseVar);

% CONVERSIONE BINARIA
Y_Train = mergecats(Y_Train, {'5', '10'}, '1');
Y_Test  = mergecats(Y_Test,  {'5', '10'}, '1');

%% 2. TRAINING (SVM Quadratica)
fprintf('Addestramento SVM Quadratica Binaria...\n');
rng(1);

% fitcsvm è la funzione specifica per SVM binaria
% - KernelFunction: 'polynomial' con Order 2 crea curve quadratiche
% - Standardize: true (ESSENZIALE per SVM per scalare le variabili)
Model = fitcsvm(X_Train, Y_Train, ...
    'KernelFunction', 'polynomial', ...
    'PolynomialOrder', 2, ...
    'Standardize', true);

Y_Test_Pred = predict(Model, X_Test);
test_accuracy = sum(Y_Test_Pred == Y_Test) / length(Y_Test);

%% 3. MATRICE DI CONFUSIONE CON ETICHETTE MANUALI
fig = figure('Name', 'Binary SVM Confusion Matrix', 'Color', [1 1 1], ...
    'Position', [50, 50, 1000, 700], 'InvertHardcopy', 'off');

% Generazione Grafico Base
cm = confusionchart(Y_Test, Y_Test_Pred, ...
    'Normalization', 'row-normalized', ...  
    'RowSummary', 'row-normalized');  

cm.Title = sprintf('SVM Quadratica - Accuracy: %.2f%%', test_accuracy*100);
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
imgFile = fullfile(resultsPath, 'Confusion_Matrix_Binary_SVM.png');
print(fig, imgFile, '-dpng', '-r300'); 
fprintf('Immagine SVM salvata in: %s\n', imgFile);

%% 4. REPORT TESTUALE
C = confusionmat(Y_Test, Y_Test_Pred);
TN = C(1,1); FP = C(1,2); FN = C(2,1); TP = C(2,2);

txtFile = fullfile(resultsPath, 'Report_Binary_SVM.txt');
fid = fopen(txtFile, 'w');
fprintf(fid, '=== REPORT SVM QUADRATICA BINARIA ===\n');
fprintf(fid, 'Accuratezza: %.2f%%\n', test_accuracy*100);
fprintf(fid, 'Voli Sani: %d (TN:%d, FP:%d)\n', TN+FP, TN, FP);
fprintf(fid, 'Voli Guasti: %d (TP:%d, FN:%d)\n', TP+FN, TP, FN);
fclose(fid);