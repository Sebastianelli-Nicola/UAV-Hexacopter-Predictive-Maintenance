%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella di destinazione (Versione v2 - Kruskal)
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v2\features_selection_kruskal_high_freq";

% Crea la cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella risultati creata: %s\n', resultsPath);
end

% Input file: Versione v2 (quella con i 10 split)
fileName = "data_feature_Table_high_freq.mat";
fullDataPath = fullfile(inputPath, fileName);

if ~isfile(fullDataPath), error('File non trovato: %s', fullDataPath); end
fprintf('Caricamento dati completi (Structure 10-Splits)...\n');

load(fullDataPath, 'feature_Table_Train', 'feature_Table_Test');

% Setup Variabili
responseVar = 'faultCode';

% IMPORTANTE: feature_Table_Train è una CELLA {10x1}.
% Per l'analisi statistica, usiamo SOLO IL PRIMO SPLIT come riferimento.
AnalyzeTable = feature_Table_Train{1}; 

all_vars = AnalyzeTable.Properties.VariableNames;
predictorVars = {};

% Filtro: Solo colonne numeriche
for i = 1:length(all_vars)
    colName = all_vars{i};
    colData = AnalyzeTable.(colName);
    
    if isnumeric(colData) && ~strcmp(colName, responseVar) && ...
       ~contains(colName, 'EnsembleID') && ~isduration(colData)
        predictorVars{end+1} = colName;
    end
end

X = table2array(AnalyzeTable(:, predictorVars));
Y = double(AnalyzeTable.(responseVar)); % Assicuriamoci che le classi siano numeriche per kruskalwallis

num_features = length(predictorVars);
fprintf('Analisi Kruskal-Wallis su %d feature (calcolata sul Split #1)...\n', num_features);

%% 2. CALCOLO RANKING (KRUSKAL-WALLIS)
kruskal_scores = zeros(num_features, 1);

set(0,'DefaultFigureVisible','off'); % Nasconde i plot automatici di kruskalwallis
fprintf('Calcolo punteggi Kruskal-Wallis (Chi-Square)...\n');

for i = 1:num_features
    % 'off' impedisce la visualizzazione dei grafici boxplot per ogni feature
    [p_val, tbl_k, ~] = kruskalwallis(X(:, i), Y, 'off');
    
    % La tabella tbl_k ha questa struttura tipica:
    % Row 1: Headers
    % Row 2: Groups (SS, df, MS, Chi-sq, Prob>Chi-sq)
    % Estraiamo il valore Chi-Square (colonna 5 della riga 2)
    if size(tbl_k, 1) > 1
        kruskal_scores(i) = tbl_k{2, 5}; 
    else
        kruskal_scores(i) = 0;
    end
end
set(0,'DefaultFigureVisible','on');

%% 3. SELEZIONE TOP 20
% Ordiniamo in base al Chi-Square (più alto è meglio)
[sorted_scores, idx_kruskal] = sort(kruskal_scores, 'descend');

num_select = 20; 
if num_features < 20, num_select = num_features; end

final_list = predictorVars(idx_kruskal(1:num_select))';
final_scores = sorted_scores(1:num_select);
num_final = length(final_list);

%% 4. CREAZIONE TABELLA DI RIEPILOGO
FinalTable = table(final_list, final_scores, ...
    'VariableNames', {'Feature_Name', 'Score_ChiSq'});

%% 5. OUTPUT E SALVATAGGIO CSV (Versione v2 Kruskal)
clc;
fprintf('================================================================\n');
fprintf('      TABELLA FEATURES FINALE (KRUSKAL-WALLIS TOP 20)           \n');
fprintf('================================================================\n');
fprintf('Numero totale feature selezionate: %d\n', num_final);
disp(FinalTable);

% Salvataggio CSV
outputCSV = fullfile(resultsPath, 'Tabella_Finale_Features_Kruskal_high_freq.csv');
writetable(FinalTable, outputCSV);
fprintf('[OK] Tabella CSV salvata in: %s\n', outputCSV);

%% 6. GRAFICO PUNTEGGI (Versione v2 Kruskal)
fig = figure('Name', 'Feature Scores Kruskal', 'Color', 'w', 'Position', [100, 100, 1000, 600]);

bar(final_scores);
xticks(1:num_final);
xticklabels(strrep(final_list, '_', '\_')); 
xtickangle(45);
title(sprintf('Top %d Feature Selezionate (Kruskal Chi-Square - Split 1)', num_final));
ylabel('Chi-Square Statistic');
grid on;

% Salvataggio Immagine
imgFile = fullfile(resultsPath, 'Feature_Selection_Kruskal_Scores_high_freq.png');
saveas(fig, imgFile);
fprintf('[OK] Immagine grafico salvata in: %s\n', imgFile);

%% 7. CREAZIONE E SALVATAGGIO DATASET RIDOTTO (.mat v2)
fprintf('\nGenerazione dataset ridotti per TUTTI i 10 split...\n');

varsToKeep = [final_list; responseVar];
nSplits = numel(feature_Table_Train);

feature_Table_Train_Reduced = cell(nSplits, 1);
feature_Table_Test_Reduced  = cell(nSplits, 1);

for s = 1:nSplits
    % Riduciamo ogni split usando le feature selezionate con Kruskal
    feature_Table_Train_Reduced{s} = feature_Table_Train{s}(:, varsToKeep);
    feature_Table_Test_Reduced{s}  = feature_Table_Test{s}(:, varsToKeep);
end

% 1. Salvataggio in Results
outputMatResults = fullfile(resultsPath, 'data_selected_features_kruskal_high_freq.mat');
save(outputMatResults, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced', 'FinalTable');

% 2. Salvataggio in Dataset (Input Path) - Per l'uso nei classificatori successivi
outputMatDataset = fullfile(inputPath, 'data_selected_features_kruskal_high_freq.mat');
save(outputMatDataset, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');

fprintf('[OK] Dataset ridotto (.mat) salvato con suffisso _kruskal_v2 in:\n 1. %s\n 2. %s\n', outputMatResults, outputMatDataset);