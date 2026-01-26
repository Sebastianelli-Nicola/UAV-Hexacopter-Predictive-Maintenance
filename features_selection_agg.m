%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
% Cartella di destinazione per i risultati della selezione
resultsPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results\features_selection_prova";

% Crea la cartella se non esiste
if ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
    fprintf('Cartella risultati creata: %s\n', resultsPath);
end

fileName = "data_feature_Table_prova.mat";
fullDataPath = fullfile(inputPath, fileName);
if ~isfile(fullDataPath), error('File non trovato: %s', fullDataPath); end

fprintf('Caricamento dati completi...\n');
% Carichiamo SIA il Train CHE il Test per poterli ridurre entrambi alla fine
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
fprintf('Analisi di %d feature in corso...\n', num_features);

%% 2. CALCOLO RANKING (ANOVA + Kruskal-Wallis)
anova_scores = zeros(num_features, 1);
kw_scores = zeros(num_features, 1);

set(0,'DefaultFigureVisible','off'); % Nascondi plot temporanei
fprintf('Calcolo punteggi statistici...\n');
for i = 1:num_features
    % ANOVA
    [~, tbl_a] = anova1(X(:, i), Y, 'off');
    if size(tbl_a, 1) > 1, anova_scores(i) = tbl_a{2, 5}; end
    
    % Kruskal-Wallis
    [~, tbl_k] = kruskalwallis(X(:, i), Y, 'off');
    if size(tbl_k, 1) > 1, kw_scores(i) = tbl_k{2, 5}; end
end
set(0,'DefaultFigureVisible','on');

%% 3. SELEZIONE TOP 20 PER METODO
% Top 20 ANOVA
[~, idx_anova] = sort(anova_scores, 'descend');
top20_anova = predictorVars(idx_anova(1:20))';

% Top 20 KW
[~, idx_kw] = sort(kw_scores, 'descend');
top20_kw = predictorVars(idx_kw(1:20))';

%% 4. UNIONE E CREAZIONE TABELLA CONDENSATA
% Unione unica (Merge + Remove Duplicates)
final_list = unique([top20_anova; top20_kw]);
num_final = length(final_list);

% Creiamo una tabella dettagliata
SelectionSource = cell(num_final, 1);
Score_Anova = zeros(num_final, 1);
Score_KW = zeros(num_final, 1);

for i = 1:num_final
    feat = final_list{i};
    
    % Controlliamo chi l'ha selezionata
    in_anova = ismember(feat, top20_anova);
    in_kw = ismember(feat, top20_kw);
    
    if in_anova && in_kw
        SelectionSource{i} = 'ENTRAMBI (Both)';
    elseif in_anova
        SelectionSource{i} = 'Solo ANOVA';
    else
        SelectionSource{i} = 'Solo Kruskal-Wallis';
    end
    
    % Recuperiamo i punteggi originali
    idx_orig = find(strcmp(predictorVars, feat));
    Score_Anova(i) = anova_scores(idx_orig);
    Score_KW(i) = kw_scores(idx_orig);
end

% Creazione Tabella Finale
FinalTable = table(final_list, SelectionSource, Score_Anova, Score_KW, ...
    'VariableNames', {'Feature_Name', 'Selezionato_Da', 'Score_ANOVA', 'Score_KW'});

% Ordiniamo per leggibilità
FinalTable = sortrows(FinalTable, 'Selezionato_Da');

%% 5. OUTPUT E SALVATAGGIO CSV
clc;
fprintf('================================================================\n');
fprintf('                TABELLA FEATURES FINALE (CONDENSATA)            \n');
fprintf('================================================================\n');
fprintf('Numero totale feature selezionate: %d\n', num_final);
disp(FinalTable);

% Salvataggio CSV
outputCSV = fullfile(resultsPath, ' ryTabella_Finale_Features.csv');
writetable(FinalTable, outputCSV);
fprintf('[OK] Tabella CSV salvata in: %s\n', outputCSV);

%% 6. GRAFICO PUNTEGGI (Nuova aggiunta per la tesi)
% Creiamo un grafico per visualizzare l'importanza delle feature scelte
fig = figure('Name', 'Feature Scores Comparison', 'Color', 'w', 'Position', [100, 100, 1000, 600]);

% Normalizziamo i punteggi per poterli confrontare nel grafico
norm_anova = Score_Anova / max(Score_Anova);
norm_kw = Score_KW / max(Score_KW);

bar([norm_anova, norm_kw]);
xticks(1:num_final);
xticklabels(strrep(final_list, '_', '\_')); % Escape underscores per il plot
xtickangle(45);
legend('ANOVA Score (Norm)', 'KW Score (Norm)');
title(sprintf('Confronto Punteggi delle %d Feature Selezionate', num_final));
ylabel('Normalized Importance Score');
grid on;

% Salvataggio Immagine
imgFile = fullfile(resultsPath, 'Feature_Selection_Scores.png');
saveas(fig, imgFile);
fprintf('[OK] Immagine grafico salvata in: %s\n', imgFile);

%% 7. CREAZIONE E SALVATAGGIO DATASET RIDOTTO (.mat)
% Questo passaggio è CRUCIALE per gli script di training successivi.
% Creiamo le tabelle contenenti SOLO le feature selezionate + la label.

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

% Salvataggio del file .mat pronto per l'addestramento
% Nota: Lo salviamo SIA nella cartella results (per archivio) 
% SIA nella cartella dataset (dove gli script di training se lo aspettano).

% 1. Salvataggio in Results
outputMatResults = fullfile(resultsPath, 'data_selected_features.mat');
save(outputMatResults, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced', 'FinalTable');

% 2. Salvataggio in Dataset (Sovrascrittura o creazione per gli script successivi)
outputMatDataset = fullfile(inputPath, 'data_selected_features.mat');
save(outputMatDataset, 'feature_Table_Train_Reduced', 'feature_Table_Test_Reduced');

fprintf('[OK] Dataset ridotto (.mat) salvato in:\n 1. %s\n 2. %s\n', outputMatResults, outputMatDataset);