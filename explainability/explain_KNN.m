%% EXPLAINABILITY VISUAL: KNN (TABELLA TOP 10 + GRAFICI SCALA UNIFICATA)
clear all; clc; close all;
set(0, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 12, 'DefaultAxesFontName', 'Arial');

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
Y_Train = TrainTbl.(responseVar);

% --- SELEZIONE CASO STUDIO ---
idx_query = 2; % Cambia qui per analizzare un altro volo
QueryPoint = X_Test(idx_query, :);
RealClassQuery = string(TestTbl.(responseVar)(idx_query));

fprintf('Analisi Volo #%d (Classe Reale: %s)\n', idx_query, RealClassQuery);

% Convertiamo in matrici per knnsearch
X_Train_Mat = table2array(X_Train);
QueryPoint_Mat = table2array(QueryPoint);

%% 1. GENERAZIONE TABELLA TOP 10 VICINI
% Anche se il modello usa K=3 o K=5, noi ne mostriamo 10 per l'analisi
K_Show = 10; 
[idx_neighbors, dists] = knnsearch(X_Train_Mat, QueryPoint_Mat, ...
    'K', K_Show, 'Distance', Best_Model.Distance);

% Recuperiamo le classi dei vicini
NeighborsLabels = string(Y_Train(idx_neighbors));

% Creazione Tabella Formattata
NeighborsTable = table((1:K_Show)', idx_neighbors', NeighborsLabels, dists', ...
    'VariableNames', {'Rango', 'ID_Volo_Training', 'Classe_Appartenenza', 'Distanza_Euclidea'});

fprintf('\n--- TABELLA DEI %d VICINI PIÙ PROSSIMI ---\n', K_Show);
disp(NeighborsTable);

% Salvataggio CSV per la relazione
csvFile = fullfile(explainPath, sprintf('KNN_Top10_Neighbors_Flight%d.csv', idx_query));
writetable(NeighborsTable, csvFile);
fprintf('[OK] Tabella esportata in: %s\n', csvFile);

%% --- CALCOLO PRELIMINARE DATI (PER SCALA UNIFICATA) ---

% A) Dati Vicino Migliore (Verde)
BestNeighbor = X_Train(idx_neighbors(1), :);
BestNeighborClass = NeighborsLabels(1);
Diff_Best = abs(QueryPoint_Mat - table2array(BestNeighbor));
[sorted_diff_best, idx_b] = sort(Diff_Best, 'ascend'); % Ascend: barre corte in alto
n_show = 10;
vals_green = sorted_diff_best(1:n_show);

% B) Dati Vicino Nemico (Rosso) - Calcolati ora per trovare il MAX scala
idx_diff_class = find(string(Y_Train) ~= RealClassQuery);
vals_red = []; % Inizializzazione vuota

if ~isempty(idx_diff_class)
    X_Train_Opposite = X_Train_Mat(idx_diff_class, :);
    [idx_opp_local, ~] = knnsearch(X_Train_Opposite, QueryPoint_Mat, 'K', 1);
    
    idx_worst = idx_diff_class(idx_opp_local);
    WorstNeighbor = X_Train(idx_worst, :);
    WorstNeighborClass = string(Y_Train(idx_worst));
    
    Diff_Worst = abs(QueryPoint_Mat - table2array(WorstNeighbor));
    sorted_diff_worst = Diff_Worst(idx_b); % Stesso ordine del grafico verde
    vals_red = sorted_diff_worst(1:n_show);
end

% C) Calcolo Limite Asse X Comune
max_val_green = max(vals_green);
max_val_red = 0;
if ~isempty(vals_red), max_val_red = max(vals_red); end

% Imposta il limite al valore massimo trovato + 15% di margine
common_xlim = [0, max(max_val_green, max_val_red) * 1.15];
fprintf('Scala Unificata Asse X impostata a: [0, %.4f]\n', common_xlim(2));

%% 2. GRAFICO SIMILARITÀ (VERDE) - CON IL 1° VICINO
fig1 = figure('Color', 'w', 'Position', [50, 50, 900, 600]);
barh(vals_green, 'FaceColor', [0.4660 0.6740 0.1880]); % Verde
yticklabels(X_Test.Properties.VariableNames(idx_b(1:n_show)));
xlabel('Distanza Assoluta', 'FontWeight', 'bold');
title(sprintf('Similitudine col Vicino #%d (Classe: %s)', ...
    idx_neighbors(1), BestNeighborClass), 'FontSize', 14);
grid on; set(gca, 'YDir', 'reverse');

xlim(common_xlim); % <--- APPLICAZIONE SCALA

% Etichette valori
for i = 1:n_show
    text(vals_green(i), i, sprintf(' %.4f', vals_green(i)), ...
        'VerticalAlignment', 'middle', 'FontSize', 10);
end
exportgraphics(fig1, fullfile(explainPath, 'KNN_Similitudine_BestNeighbor.png'), 'Resolution', 300);

%% 3. GRAFICO DIFFERENZA (ROSSO) - CON CLASSE OPPOSTA
if ~isempty(idx_diff_class)
    fig2 = figure('Color', 'w', 'Position', [100, 100, 900, 600]);
    barh(vals_red, 'FaceColor', [0.8500 0.3250 0.0980]); % Rosso
    yticklabels(X_Test.Properties.VariableNames(idx_b(1:n_show)));
    xlabel('Distanza Assoluta', 'FontWeight', 'bold');
    title(sprintf('Differenza col Vicino #%d (Classe: %s)', ...
        idx_worst, WorstNeighborClass), 'FontSize', 14);
    grid on; set(gca, 'YDir', 'reverse');
    
    xlim(common_xlim); % <--- APPLICAZIONE SCALA
    
    for i = 1:n_show
        text(vals_red(i), i, sprintf(' %.4f', vals_red(i)), ...
            'VerticalAlignment', 'middle', 'FontSize', 10);
    end
    exportgraphics(fig2, fullfile(explainPath, 'KNN_Differenza_OppositeClass.png'), 'Resolution', 300);
end