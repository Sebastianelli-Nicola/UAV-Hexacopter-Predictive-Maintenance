%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results\features_selection_prova"; 
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results\due classi\decision_tree_prova";

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

%% 2. TRAINING
fprintf('Addestramento Ensemble Binario...\n');
rng(1);
t = templateTree('Reproducible',true);
Model = fitcensemble(X_Train, Y_Train, 'Method', 'Bag', 'NumLearningCycles', 30, 'Learners', t);

Y_Test_Pred = predict(Model, X_Test);
test_accuracy = sum(Y_Test_Pred == Y_Test) / length(Y_Test);

%% 3. MATRICE DI CONFUSIONE CON ETICHETTE MANUALI POSIZIONATE MEGLIO
% Creiamo una figura grande
fig = figure('Name', 'Binary Ensemble Confusion Matrix', 'Color', [1 1 1], ...
    'Position', [50, 50, 1000, 700], 'InvertHardcopy', 'off');

% Generazione Grafico Base
cm = confusionchart(Y_Test, Y_Test_Pred, ...
    'Normalization', 'row-normalized', ...  
    'RowSummary', 'row-normalized');  

cm.Title = sprintf('Decision Tree 2 Classi - Accuracy: %.2f%%', test_accuracy*100);
cm.XLabel = 'Classe Predetta (0=Sano, 1=Guasto)';
cm.YLabel = 'Classe Reale (0=Sano, 1=Guasto)';
cm.FontColor = [0 0 0];
cm.FontName = 'Arial';
cm.FontSize = 12;

% --- AGGIUNTA ETICHETTE CON COORDINATE RICALIBRATE ---
% Le coordinate sono [x_inizio, y_inizio, larghezza, altezza] normalizzate (0.0 - 1.0)
% Ho spostato le etichette un po' più a sinistra e più in alto rispetto al tentativo precedente.


% Etichette a Destra (TPR / FNR)
annotation('textbox', [0.69, 0.057, 0.1, 0.05], 'String', 'TPR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
annotation('textbox', [0.80, 0.057, 0.1, 0.05], 'String', 'FNR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

% Salvataggio
imgFile = fullfile(resultsPath, 'Confusion_Matrix_Binary_Decision_Tree.png');
print(fig, imgFile, '-dpng', '-r300'); 
fprintf('Immagine con Etichette Ricalibrate salvata in: %s\n', imgFile);

%% 4. REPORT TESTUALE
C = confusionmat(Y_Test, Y_Test_Pred);
TN = C(1,1); FP = C(1,2); FN = C(2,1); TP = C(2,2);
txtFile = fullfile(resultsPath, 'Report_Binary_Ensemble.txt');
fid = fopen(txtFile, 'w');
fprintf(fid, '=== REPORT ENSEMBLE BINARIO ===\n');
fprintf(fid, 'Accuratezza: %.2f%%\n', test_accuracy*100);
fprintf(fid, 'Voli Sani: %d (TN:%d, FP:%d)\n', TN+FP, TN, FP);
fprintf(fid, 'Voli Guasti: %d (TP:%d, FN:%d)\n', TP+FN, TP, FN);
fclose(fid);