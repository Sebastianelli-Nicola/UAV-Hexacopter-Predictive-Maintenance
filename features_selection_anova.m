%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella di destinazione (ho mantenuto il nome _prova come nel tuo codice)
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results\features_selection_anova";

% Crea la cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella risultati creata: %s\n', resultsPath);
end

fileName = "data_feature_Table_prova.mat";
fullDataPath = fullfile(inputPath, fileName);

if ~isfile(fullDataPath), error('File non trovato: %s', fullDataPath); end
fprintf('Caricamento dati completi...\n');

% Carichiamo SIA il Train CHE il Test
load(fullDataPath, 'feature_Table_Train', 'feature_Table_Test');

% Setup Variabili
responseVar = 'faultCode';
all_vars = feature_Table_Train.Properties.VariableNames;
predictorVars = {};

% Filtro: Solo colonne numeriche (esclude Time, ID, Label)
for i = 1:length(all_vars)
    colName = all_vars{i};
    colData = feature_Table_Train.(colName);
    if isnumeric(colData) && ~strcmp(colName, responseVar) && ...
       ~contains(colName, 'EnsembleID') && ~isduration(colData)
        predictorVars{end+1} = colName;
    end
end

X = table2array(feature_Table_Train(:, predictorVars));
Y = double(feature_Table_Train.(responseVar));
num_features = length(predictorVars);
fprintf('Analisi ANOVA su %d feature in corso...\n', num_features);

%% 2. CALCOLO RANKING (SOLO ANOVA)
anova_scores = zeros(num_features, 1);

set(0,'DefaultFigureVisible','off'); % Nascondi plot temporanei
fprintf('Calcolo punteggi ANOVA...\n');
for i = 1:num_features
    % ANOVA One-Way
    % tbl_a{2,5} contiene il valore F (F-Statistic)
    [~, tbl_a] = anova1(X(:, i), Y, 'off');
    if size(tbl_a, 1) > 1
        anova_scores(i) = tbl_a{2, 5}; 
    else
        anova_scores(i) = 0;
    end
end
set(0,'DefaultFigureVisible','on');

%% 3. SELEZIONE TOP 20 (SOLO ANOVA)
% Ordiniamo i punteggi in ordine decrescente
[sorted_scores, idx_anova] = sort(anova_scores, 'descend');

% Selezioniamo solo le prime 20
num_select = 20; 
% (O meno se ci sono meno di 20 feature totali)
if num_features < 20, num_select = num_features; end

% Lista finale delle feature
final_list = predictorVars(idx_anova(1:num_select))';
final_scores = sorted_scores(1:num_select);
num_final = length(final_list);

%% 4. CREAZIONE TABELLA DI RIEPILOGO
% Creiamo una tabella semplice con Nome Feature e Score ANOVA
FinalTable = table(final_list, final_scores, ...
    'VariableNames', {'Feature_Name', 'Score_ANOVA'});

%% 5. OUTPUT E SALVATAGGIO CSV
clc;
fprintf('================================================================\n');
fprintf('          TABELLA FEATURES FINALE (SOLO ANOVA TOP 20)           \n');
fprintf('================================================================\n');
fprintf('Numero totale feature selezionate: %d\n', num_final);
disp(FinalTable);

% Salvataggio CSV
outputCSV = fullfile(resultsPath, 'Tabella_Finale_Features_ANOVA.csv');
writetable(FinalTable, outputCSV);
fprintf('[OK] Tabella CSV salvata in: %s\n', outputCSV);

%% 6. GRAFICO PUNTEGGI (Solo ANOVA)
fig = figure('Name', 'Feature Scores ANOVA', 'Color', 'w', 'Position', [100, 100, 1000, 600]);

% Bar plot dei punteggi
bar(final_scores);
xticks(1:num_final);
xticklabels(strrep(final_list, '_', '\_')); % Escape underscores per il plot
xtickangle(45);
title(sprintf('Top %d Feature Selezionate (Criterio: ANOVA F-Score)', num_final));
ylabel('ANOVA F-Score');
grid on;

% Salvataggio Immagine
imgFile = fullfile(resultsPath, 'Feature_Selection_ANOVA_Scores.png');
saveas(fig, imgFile);
fprintf('[OK] Immagine grafico salvata in: %s\n', imgFile);

%% 7. CREAZIONE E SALVATAGGIO DATASET RIDOTTO (.mat)
fprintf('\nGenerazione dataset ridotto per il training...\n');

% Colonne da mantenere: Feature Selezionate + Variabile di Risposta (faultCode)
varsToKeep = [final_list; responseVar];

% Riduzione Train
feature_Table_Train_Reduced = feature_Table_Train(:, varsToKeep);

% Riduzione Test (se presente)
if exist('feature_Table_Test', 'var')
    feature_Table_Test_Reduced = feature_Table_Test(:, varsToKeep);
else
    feature_Table_Test_Reduced = [];
    warning('Tabella di Test non trovata, creato solo Train ridotto.');
end

% 1. Salvataggio in Results
outputMatResults = fullfile(resultsPath, 'data_selected_features_anova.mat');
save(outputMatResults, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced', 'FinalTable');

% 2. Salvataggio in Dataset (Sovrascrittura o creazione per gli script successivi)
outputMatDataset = fullfile(inputPath, 'data_selected_features_anova.mat');
save(outputMatDataset, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');

fprintf('[OK] Dataset ridotto (.mat) salvato in:\n 1. %s\n 2. %s\n', outputMatResults, outputMatDataset);