%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella di destinazione
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v3\features_selection_anova_high_freq_2_peak";

% Crea la cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella risultati creata: %s\n', resultsPath);
end

% Input file: Versione (quella con i 10 split)
fileName = "data_feature_Table_high_freq_2_peak.mat";
fullDataPath = fullfile(inputPath, fileName);

if ~isfile(fullDataPath), error('File non trovato: %s', fullDataPath); end
fprintf('Caricamento dati completi (Structure 10-Splits)...\n');

load(fullDataPath, 'feature_Table_Train', 'feature_Table_Test');

% Setup Variabili
responseVar = 'faultCode';

% IMPORTANTE: feature_Table_Train è una CELLA {10x1}.
% Per l'analisi statistica (ANOVA), usiamo SOLO IL PRIMO SPLIT.
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
Y = double(AnalyzeTable.(responseVar));
num_features = length(predictorVars);
fprintf('Analisi ANOVA su %d feature (calcolata sul Split #1)...\n', num_features);

%% 2. CALCOLO RANKING (SOLO ANOVA)
anova_scores = zeros(num_features, 1);

set(0,'DefaultFigureVisible','off'); 
fprintf('Calcolo punteggi ANOVA...\n');
for i = 1:num_features
    [~, tbl_a] = anova1(X(:, i), Y, 'off');
    if size(tbl_a, 1) > 1
        anova_scores(i) = tbl_a{2, 5}; 
    else
        anova_scores(i) = 0;
    end
end
set(0,'DefaultFigureVisible','on');

%% 3. SELEZIONE TOP 20
[sorted_scores, idx_anova] = sort(anova_scores, 'descend');

num_select = 20; 
if num_features < 20, num_select = num_features; end

final_list = predictorVars(idx_anova(1:num_select))';
final_scores = sorted_scores(1:num_select);
num_final = length(final_list);

%% 4. CREAZIONE TABELLA DI RIEPILOGO
FinalTable = table(final_list, final_scores, ...
    'VariableNames', {'Feature_Name', 'Score_ANOVA'});

%% 5. OUTPUT E SALVATAGGIO CSV 
clc;
fprintf('================================================================\n');
fprintf('          TABELLA FEATURES FINALE (SOLO ANOVA TOP 20)           \n');
fprintf('================================================================\n');
fprintf('Numero totale feature selezionate: %d\n', num_final);
disp(FinalTable);

% Salvataggio CSV con nome 
outputCSV = fullfile(resultsPath, 'Tabella_Finale_Features_ANOVA_high_freq_2_peak.csv');
writetable(FinalTable, outputCSV);
fprintf('[OK] Tabella CSV salvata in: %s\n', outputCSV);

%% 6. GRAFICO PUNTEGGI
fig = figure('Name', 'Feature Scores ANOVA', 'Color', 'w', 'Position', [100, 100, 1000, 600]);
bar(final_scores);
xticks(1:num_final);
xticklabels(strrep(final_list, '_', '\_')); 
xtickangle(45);
title(sprintf('Top %d Feature Selezionate (ANOVA F-Score - Split 1)', num_final));
ylabel('ANOVA F-Score');
grid on;

% Salvataggio Immagine con nome 
imgFile = fullfile(resultsPath, 'Feature_Selection_ANOVA_Scores_v2.png');
saveas(fig, imgFile);
fprintf('[OK] Immagine grafico salvata in: %s\n', imgFile);

%% 7. CREAZIONE E SALVATAGGIO DATASET RIDOTTO (.mat )
fprintf('\nGenerazione dataset ridotti per TUTTI i 10 split...\n');

varsToKeep = [final_list; responseVar];

nSplits = numel(feature_Table_Train);
feature_Table_Train_Reduced = cell(nSplits, 1);
feature_Table_Test_Reduced  = cell(nSplits, 1);

for s = 1:nSplits
    % Riduciamo ogni split usando le feature selezionate
    feature_Table_Train_Reduced{s} = feature_Table_Train{s}(:, varsToKeep);
    feature_Table_Test_Reduced{s}  = feature_Table_Test{s}(:, varsToKeep);
end

% 1. Salvataggio in Results (con nome )
outputMatResults = fullfile(resultsPath, 'data_selected_features_anova_high_freq_2_peak.mat');
save(outputMatResults, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced', 'FinalTable');

% 2. Salvataggio in Dataset (con nome ) - CRUCIALE PER I PROSSIMI SCRIPT
outputMatDataset = fullfile(inputPath, 'data_selected_features_anova_high_freq_2_peak.mat');
save(outputMatDataset, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');

fprintf('[OK] Dataset ridotto (.mat) salvato con suffisso v2 in:\n 1. %s\n 2. %s\n', outputMatResults, outputMatDataset);