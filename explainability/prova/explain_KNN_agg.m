%% EXPLAINABILITY VISUAL: KNN (CONFRONTO CORRETTO CLASS A vs CLASS B)
clear all; clc; close all;
set(0, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 11, 'DefaultAxesFontName', 'Arial');

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset";
modelPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v3\tre classi\knn_anova_high_freq_2_peak"; 
explainPath = fullfile(modelPath, "explainability_HQ");
if ~exist(explainPath, 'dir'), mkdir(explainPath); end

load(fullfile(modelPath, "Best_KNN_Model.mat"), 'Best_Model', 'best_split_idx');
load(fullfile(inputPath, "data_selected_features_anova_high_freq_2_peak.mat"), 'feature_Table_Test_Reduced', 'feature_Table_Train_Reduced');

% --- DATI ---
TestTbl = feature_Table_Test_Reduced{best_split_idx};
TrainTbl = feature_Table_Train_Reduced{best_split_idx};
responseVar = 'faultCode';

% Separazione Feature e Classi
X_Test = TestTbl(:, setdiff(TestTbl.Properties.VariableNames, responseVar));
X_Train = TrainTbl(:, setdiff(TrainTbl.Properties.VariableNames, responseVar));

% --- FIX CRITICO: GESTIONE ROBUSTA DELLE CLASSI ---
% Convertiamo tutto in stringa e rimuoviamo spazi per evitare errori di confronto
Y_Train_Str = strip(string(table2array(TrainTbl(:, responseVar))));
Y_Test_Str  = strip(string(table2array(TestTbl(:, responseVar))));

% Convertiamo Feature in matrici per velocità
X_Train_Mat = table2array(X_Train);
X_Test_Mat  = table2array(X_Test);

% --- SELEZIONE CASO STUDIO ---
idx_query = 1; % Cambia indice qui
QueryPoint_Mat = X_Test_Mat(idx_query, :);
RealClassQuery = Y_Test_Str(idx_query);

fprintf('Analisi Volo #%d (Classe Reale: %s)\n', idx_query, RealClassQuery);

%% 1. TROVA IL MIGLIOR VICINO (PREDIZIONE)
% Cerchiamo il punto più vicino in assoluto (K=1)
[idx_best, dist_best] = knnsearch(X_Train_Mat, QueryPoint_Mat, 'K', 1, 'Distance', Best_Model.Distance);

BestNeighbor = X_Train_Mat(idx_best, :);
BestNeighborClass = Y_Train_Str(idx_best);

fprintf('Il modello predice Classe: %s (Distanza: %.4f)\n', BestNeighborClass, dist_best);

%% 2. TROVA IL "VICINO NEMICO" (CLASSE DIVERSA)
% Cerchiamo il punto più vicino che appartiene a una classe DIVERSA da quella predetta
% Questo è il "Controfattuale": cosa avrebbe dovuto avere il volo per essere dell'altra classe?

% Indici di tutti i voli che NON sono della classe del BestNeighbor
idx_others = find(Y_Train_Str ~= BestNeighborClass);

if isempty(idx_others)
    error('Errore: Nel training set esiste solo una classe! Impossibile fare confronti.');
end

% Cerchiamo il più vicino tra quelli "diversi"
X_Train_Others = X_Train_Mat(idx_others, :);
[idx_local_worst, dist_worst] = knnsearch(X_Train_Others, QueryPoint_Mat, 'K', 1, 'Distance', Best_Model.Distance);

% Mappiamo l'indice locale all'indice globale di X_Train
idx_worst = idx_others(idx_local_worst);
WorstNeighbor = X_Train_Mat(idx_worst, :);
WorstNeighborClass = Y_Train_Str(idx_worst);

fprintf('Il "Vicino Nemico" più prossimo è Classe: %s (Distanza: %.4f)\n', WorstNeighborClass, dist_worst);

%% 3. GRAFICO 1: PERCHÉ È SIMILE AL VICINO CORRETTO (VERDE)
Diff_Best = abs(QueryPoint_Mat - BestNeighbor); % Differenza assoluta feature per feature
[sorted_diff_best, idx_b] = sort(Diff_Best, 'ascend'); % Le differenze MINORI in alto

n_show = 10;
featureNames = X_Test.Properties.VariableNames;

fig1 = figure('Color', 'w', 'Position', [50, 50, 900, 600]);
b1 = barh(sorted_diff_best(1:n_show), 'FaceColor', [0.4660 0.6740 0.1880]); % Verde
yticklabels(featureNames(idx_b(1:n_show)));
xlabel('Distanza (Minore è meglio)', 'FontWeight', 'bold');
title({sprintf('MATCH: Similitudine con Classe %s', BestNeighborClass), ...
       '(Feature con barre corte = Valori quasi identici)'}, 'FontSize', 14);
grid on; set(gca, 'YDir', 'reverse');

% Etichette
for i = 1:n_show
    text(sorted_diff_best(i), i, sprintf(' %.4f', sorted_diff_best(i)), ...
        'VerticalAlignment', 'middle', 'FontSize', 9);
end
exportgraphics(fig1, fullfile(explainPath, 'KNN_Explain_Match_Green.png'), 'Resolution', 300);

%% 4. GRAFICO 2: PERCHÉ È DIVERSO DALLA CLASSE SBAGLIATA (ROSSO)
Diff_Worst = abs(QueryPoint_Mat - WorstNeighbor);

% IMPORTANTE: Riordiniamo anche qui! Vogliamo vedere le differenze MAGGIORI o MINORI?
% Solitamente in XAI per il "contro-esempio" vogliamo vedere le feature che sono PIÙ DIVERSE
% (quelle che allontanano il punto dalla classe sbagliata) oppure quelle più simili.
% Qui mostriamo le feature più simili anche per il nemico, per vedere dove "quasi" si toccano,
% oppure (scelta consigliata) usiamo lo stesso ordine 'ascend' per mostrare che le distanze 
% minime qui sono comunque più grandi di quelle verdi.

[sorted_diff_worst, idx_w] = sort(Diff_Worst, 'ascend'); 

fig2 = figure('Color', 'w', 'Position', [100, 100, 900, 600]);
b2 = barh(sorted_diff_worst(1:n_show), 'FaceColor', [0.8500 0.3250 0.0980]); % Rosso
yticklabels(featureNames(idx_w(1:n_show))); % Usa i nomi feature propri di questo confronto
xlabel('Distanza (Minore è meglio)', 'FontWeight', 'bold');
title({sprintf('MISMATCH: Differenza con Classe %s', WorstNeighborClass), ...
       '(Anche le feature più simili sono più distanti rispetto al Match)'}, 'FontSize', 14);
grid on; set(gca, 'YDir', 'reverse');

for i = 1:n_show
    text(sorted_diff_worst(i), i, sprintf(' %.4f', sorted_diff_worst(i)), ...
        'VerticalAlignment', 'middle', 'FontSize', 9);
end
exportgraphics(fig2, fullfile(explainPath, 'KNN_Explain_Mismatch_Red.png'), 'Resolution', 300);

fprintf('Grafici salvati correttamente.\n');