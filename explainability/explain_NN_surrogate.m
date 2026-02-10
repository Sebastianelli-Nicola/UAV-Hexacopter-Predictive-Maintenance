%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 

% NOTA: Ho messo il percorso che appariva nel tuo ultimo errore. 
% Se il modello è altrove, modifica questa riga.
modelPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v2\tre classi\neural_network_anova_high_freq";

% Cartella output per l'Explainability
explainPath = fullfile(modelPath, "explainability_surrogate");

% Crea cartella explainability se non esiste
if ~exist(explainPath, 'dir')
    mkdir(explainPath);
    fprintf('Cartella Explainability creata: %s\n', explainPath);
end

% --- CARICAMENTO MODELLO ---
modelFile = fullfile(modelPath, "Best_NeuralNetwork_Model.mat");
if ~isfile(modelFile), error('Modello non trovato: %s', modelFile); end
fprintf('Caricamento Modello Migliore...\n');
load(modelFile, 'Best_Model', 'best_split_idx', 'best_test_acc');

% --- CARICAMENTO DATASET ---
dataFile = "data_selected_features_anova_high_freq.mat";
fullDataPath = fullfile(inputPath, dataFile);
if ~isfile(fullDataPath), error('Dataset non trovato: %s', fullDataPath); end
fprintf('Caricamento Dataset...\n');
load(fullDataPath, 'feature_Table_Train_Reduced');

% --- RECUPERO DATI DELLO SPLIT MIGLIORE ---
fprintf('Recupero dati dal Best Split #%d (Acc: %.2f%%)...\n', best_split_idx, best_test_acc*100);
TrainTbl = feature_Table_Train_Reduced{best_split_idx};

% --- CORREZIONE CRITICA: RIMOZIONE NaN ---
% Le reti neurali e gli alberi possono fallire se ci sono NaN (valori mancanti)
% generati da divisioni per zero nelle feature (es. ClearanceFactor su segnale piatto).
num_before = height(TrainTbl);
TrainTbl = rmmissing(TrainTbl); 
num_after = height(TrainTbl);

if num_before > num_after
    fprintf('ATTENZIONE: Rimosse %d righe contenenti NaN per evitare errori.\n', num_before - num_after);
end

responseVar = 'faultCode';
% Estrazione Feature (X)
X_Train = TrainTbl(:, setdiff(TrainTbl.Properties.VariableNames, responseVar));
% Nota: Non ci serve Y_Train reale, perché il surrogato deve imitare la Rete, non la realtà.

%% 2. GENERAZIONE PREDIZIONI "BLACK BOX"
fprintf('Generazione predizioni della Neural Network (Black Box)...\n');

% Usiamo la rete neurale per etichettare i dati di training
Y_Pred_NN = predict(Best_Model, X_Train);

% Convertiamo in stringa/categoriale per sicurezza nell'albero
if isnumeric(Y_Pred_NN)
    Y_Pred_NN = string(Y_Pred_NN);
end

%% 3. ADDESTRAMENTO MODELLO SURROGATO (DECISION TREE)
fprintf('Addestramento Albero Surrogato (White Box)... \n');

% Parametri per l'interpretabilità:
% - MaxNumSplits: 20-30 nodi max per mantenerlo leggibile
Surrogate_Tree = fitctree(X_Train, Y_Pred_NN, ...
    'PredictorNames', X_Train.Properties.VariableNames, ...
    'MaxNumSplits', 20, ... 
    'Prune', 'on'); 

%% 4. CALCOLO DELLA "FIDELITY" (FEDELTÀ)
% Misuriamo quanto il surrogato è simile alla rete neurale
Y_Pred_Tree = predict(Surrogate_Tree, X_Train);

% Calcolo coincidenze
if iscell(Y_Pred_NN) || isstring(Y_Pred_NN) || iscategorical(Y_Pred_NN)
    match = strcmp(string(Y_Pred_Tree), string(Y_Pred_NN));
else
    match = (Y_Pred_Tree == Y_Pred_NN);
end

fidelity = sum(match) / length(match);

fprintf('\n=== RISULTATI SURROGATO ===\n');
fprintf('Fidelity Score: %.2f%%\n', fidelity * 100);
fprintf('(Questo indica quanto accuratamente l''albero imita le decisioni della Neural Network)\n');

%% 5. VISUALIZZAZIONE E SALVATAGGIO GRAFICO
fprintf('Generazione grafico albero...\n');

% 1. Chiudiamo tutte le figure aperte per pulizia
close all; 

% 2. Usiamo 'view' in modalità graph. 
% Questo apre una NUOVA finestra dedicata al grafico dell'albero.
view(Surrogate_Tree, 'Mode', 'graph'); 

% 3. Catturiamo l'handle della figura appena aperta da view
fig = gcf; 

% 4. Aggiustiamo il titolo sulla figura corrente
title(sprintf('Modello Surrogato della Neural Network (Fidelity: %.2f%%)', fidelity*100));

% 5. Salvataggio Immagine
imgFile = fullfile(explainPath, 'Surrogate_Tree_Graph.png');
saveas(fig, imgFile);
fprintf('Grafico Albero Surrogato salvato in: %s\n', imgFile);

%% 6. ESTRAZIONE REGOLE E REPORT
txtFile = fullfile(explainPath, 'Report_Explainability_Surrogate.txt');
fid = fopen(txtFile, 'w');

fprintf(fid, '=== REPORT EXPLAINABILITY (MODELLO SURROGATO) ===\n');
fprintf(fid, 'Modello Originale: Neural Network (Split #%d)\n', best_split_idx);
fprintf(fid, 'Accuratezza Modello Originale: %.2f%%\n', best_test_acc*100);
fprintf(fid, '---------------------------------------------------\n');
fprintf(fid, 'Modello Surrogato: Decision Tree (Max 20 Splits)\n');
fprintf(fid, 'Fidelity Score:    %.2f%%\n', fidelity*100);
fprintf(fid, 'Interpretazione:   Il surrogato spiega il %.2f%% delle decisioni della rete.\n', fidelity*100);
fprintf(fid, '---------------------------------------------------\n');
fprintf(fid, '\nVISUALIZZAZIONE TESTUALE DELLE REGOLE:\n\n');

% Cattura l'output visuale dell'albero per scriverlo nel file
% Usiamo evalc per catturare ciò che view stamperebbe nella command window
tree_text = evalc('view(Surrogate_Tree)'); 
fprintf(fid, '%s', tree_text);

fclose(fid);
fprintf('Report regole testuali salvato in: %s\n', txtFile);

%% 7. VISUALIZZAZIONE REGOLE CHIAVE (TOP SPLITS)
% Mostriamo a video le variabili più importanti usate dal surrogato
imp = predictorImportance(Surrogate_Tree);
[sorted_imp, idx] = sort(imp, 'descend');
top_vars = Surrogate_Tree.PredictorNames(idx);

fprintf('\nTop 5 Variabili usate dal Surrogato per imitare la Rete:\n');
for i = 1:min(5, length(top_vars))
    if sorted_imp(i) > 0
        fprintf('%d. %s (Importance: %.4f)\n', i, top_vars{i}, sorted_imp(i));
    end
end