%% 1. CARICAMENTO DATI E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella specifica per SVM (3 Classi)
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results\tre classi\svm_anova";

% Crea cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella creata: %s\n', resultsPath);
end

fileName = "data_selected_features_anova.mat";
fullDataPath = fullfile(inputPath, fileName);
if ~isfile(fullDataPath), error('File non trovato: %s', fullDataPath); end

fprintf('Caricamento dati SVM (3 Classi)...\n');
load(fullDataPath, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');

% Definizione Variabili
responseVar = 'faultCode';

% Estrazione X e Y
X_Train = feature_Table_Train_Reduced(:, setdiff(feature_Table_Train_Reduced.Properties.VariableNames, responseVar));
Y_Train = feature_Table_Train_Reduced.(responseVar);
X_Test = feature_Table_Test_Reduced(:, setdiff(feature_Table_Test_Reduced.Properties.VariableNames, responseVar));
Y_Test = feature_Table_Test_Reduced.(responseVar);

%% 2. CONFIGURAZIONE E VALIDAZIONE (5-Fold CV)
fprintf('\n--- Addestramento SVM Quadratica (3 Classi, 5-Fold CV) ---\n');
rng(1); 

% Template SVM: Polinomio Ordine 2, Standardizzato
t = templateSVM('KernelFunction', 'polynomial', 'PolynomialOrder', 2, ...
    'Standardize', true);

% fitcecoc gestisce il multiclasse (One-vs-One)
SVM_CV_Model = fitcecoc(X_Train, Y_Train, ...
    'Learners', t, ...
    'KFold', 5);

cv_accuracy = 1 - kfoldLoss(SVM_CV_Model);
fprintf('Validazione (K-Fold=5) Accuracy: %.2f%%\n', cv_accuracy * 100);

%% 3. MODELLO FINALE E TEST
fprintf('Addestramento modello finale...\n');
Final_SVM_Model = fitcecoc(X_Train, Y_Train, 'Learners', t);

fprintf('\n--- Test su Dati Mai Visti (Testing Set) ---\n');
Y_Test_Pred = predict(Final_SVM_Model, X_Test);
test_accuracy = sum(Y_Test_Pred == Y_Test) / length(Y_Test);
fprintf('Test Set Accuracy: %.2f%%\n', test_accuracy * 100);

%% 4. VISUALIZZAZIONE MATRICE DI CONFUSIONE (Layout Avanzato)
fig = figure('Name', 'SVM Confusion Matrix', 'Color', [1 1 1], ...
    'Position', [50, 50, 1000, 700], 'InvertHardcopy', 'off');

% Plot Confusion Matrix
cm = confusionchart(Y_Test, Y_Test_Pred, ...
    'Normalization', 'row-normalized', ...  % Percentuali (Recall)
    'RowSummary', 'row-normalized');     % Barra destra (TPR)

% Personalizzazione Titoli e Font
cm.Title = sprintf('SVM Quadratica (3 Classi) - Accuracy: %.2f%%', test_accuracy*100);
cm.XLabel = 'Classe Predetta';
cm.YLabel = 'Classe Reale';
cm.FontColor = [0 0 0];
cm.FontName = 'Arial';
cm.FontSize = 12;

% --- AGGIUNTA ETICHETTE MANUALI (TPR/FNR) ---
% Posizionamento standardizzato
annotation('textbox', [0.71, 0.057, 0.1, 0.05], 'String', 'TPR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
annotation('textbox', [0.805, 0.057, 0.1, 0.05], 'String', 'FNR', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

% Salvataggio Immagine
imgFile = fullfile(resultsPath, 'Confusion_Matrix_3Class_SVM.png');
print(fig, imgFile, '-dpng', '-r300'); 
fprintf('Immagine salvata in: %s\n', imgFile);

%% 5. ANALISI FALSI ALLARMI E REPORT
C = confusionmat(Y_Test, Y_Test_Pred);
classes = categories(Y_Test); 
idx_0 = find(strcmp(classes, '0')); % Indice classe "0" (Sano)

% Apertura file report
txtFile = fullfile(resultsPath, 'Report_3Class_SVM.txt');
fid = fopen(txtFile, 'w');

fprintf(fid, '=== REPORT SVM QUADRATICA (3 CLASSI) ===\n');
fprintf(fid, 'Accuratezza Globale: %.2f%%\n', test_accuracy * 100);
fprintf(fid, '--------------------------------------------\n');

if ~isempty(idx_0)
    % Calcoli specifici per i Falsi Allarmi
    total_NoFault = sum(C(idx_0, :));
    correct_NoFault = C(idx_0, idx_0);
    false_alarms = total_NoFault - correct_NoFault;
    perc_false_alarms = (false_alarms/total_NoFault)*100;
    
    fprintf(fid, 'ANALISI CLASSE "0" (NO GUASTO):\n');
    fprintf(fid, ' - Totale Voli Sani:       %d\n', total_NoFault);
    fprintf(fid, ' - Riconosciuti Sani:      %d\n', correct_NoFault);
    fprintf(fid, ' - FALSI ALLARMI (Errori): %d (%.2f%%)\n', false_alarms, perc_false_alarms);
    
    if false_alarms > 0
        fprintf(fid, '   NOTA: La SVM ha classificato %d voli sani come guasti.\n', false_alarms);
    else
        fprintf(fid, '   OTTIMO: Nessun falso allarme generato.\n');
    end
else
    fprintf(fid, 'Impossibile trovare la classe "0" per analisi specifica.\n');
end

% Aggiunta dettaglio per le altre classi
fprintf(fid, '\nDETTAGLIO MATRICE DI CONFUSIONE:\n');
for i = 1:length(classes)
    cls = classes{i};
    tot = sum(C(i,:));
    corr = C(i,i);
    acc = (corr/tot)*100;
    fprintf(fid, 'Classe %s: %d/%d corretti (%.2f%%)\n', cls, corr, tot, acc);
end

fclose(fid);
fprintf('Report testuale salvato in: %s\n', txtFile);