%% EXPLAINABILITY VISUAL: SVM (ROBUST PERMUTATION - TUTTE LE FEATURE)
clear all; clc; close all;
set(0, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 11, 'DefaultAxesFontName', 'Arial');

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset";
modelPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v3\tre classi\svm_anova_high_freq_2_peak"; 
explainPath = fullfile(modelPath, "explainability_HQ");
if ~exist(explainPath, 'dir'), mkdir(explainPath); end

% --- CARICAMENTO ---
fprintf('Caricamento modello e dati...\n');
load(fullfile(modelPath, "Best_SVM_Model.mat"), 'Best_Model', 'best_split_idx'); 
load(fullfile(inputPath, "data_selected_features_anova_high_freq_2_peak.mat"), 'feature_Table_Test_Reduced');

% Setup Dati
TestTbl = feature_Table_Test_Reduced{best_split_idx};
responseVar = 'faultCode';
X_Test = TestTbl(:, setdiff(TestTbl.Properties.VariableNames, responseVar));
Y_Test = TestTbl.(responseVar);

% --- CALCOLO ACCURATEZZA BASE ---
base_loss = loss(Best_Model, X_Test, Y_Test);
base_acc = 1 - base_loss;
fprintf('Accuratezza Base (Dataset Originale): %.2f%%\n', base_acc*100);

% --- CONFIGURAZIONE PERMUTAZIONE ---
n_repeats = 10; 
featureNames = X_Test.Properties.VariableNames;
n_features = length(featureNames);
mean_acc_drop = zeros(n_features, 1); 

fprintf('\nInizio calcolo Permutation Importance (%d ripetizioni per feature)...\n', n_repeats);

% --- CICLO SU OGNI FEATURE ---
for i = 1:n_features
    current_feature = featureNames{i};
    drops_for_this_feature = zeros(n_repeats, 1);
    
    fprintf(' -> Analisi feature %d/%d: %s... ', i, n_features, current_feature);
    
    for k = 1:n_repeats
        X_Perm = X_Test; 
        X_Perm.(current_feature) = X_Perm.(current_feature)(randperm(height(X_Perm)));
        perm_acc = 1 - loss(Best_Model, X_Perm, Y_Test);
        drops_for_this_feature(k) = base_acc - perm_acc;
    end
    
    mean_drop = mean(drops_for_this_feature);
    mean_acc_drop(i) = mean_drop;
    fprintf('Calo Medio: %.2f%%\n', mean_drop*100);
end

% --- ORDINAMENTO ---
[sorted_drop, idx] = sort(mean_acc_drop, 'descend');

% Mostriamo TUTTE le feature
n_show = length(sorted_drop); 

% --- GRAFICO ---
% Aumentiamo l'altezza della figura (800 pixel) per farci stare comodamente 20 barre
fig = figure('Color', 'w', 'Position', [50, 50, 1000, 800]); 

b = barh(sorted_drop(1:n_show), 'FaceColor', [0.8 0.3 0.3]); % Rosso SVM

% Impostiamo i nomi delle feature sull'asse Y
ax = gca;
ax.YTick = 1:n_show; % Assicura che ci sia un tick per ogni barra
ax.YTickLabel = featureNames(idx(1:n_show));
ax.YDir = 'reverse'; % Ordine decrescente (la più importante in alto)

% Riduciamo leggermente il font se le feature sono tante
if n_show > 15
    ax.FontSize = 10; 
end

xlabel(sprintf('Perdita Media di Accuratezza (su %d permutazioni)', n_repeats), 'FontWeight', 'bold', 'FontSize', 12);
title(sprintf('SVM Feature Importance: Tutte le Feature (%d)', n_show), 'FontSize', 14);
grid on;

% Aggiunta etichette percentuali precise
for i = 1:n_show
    val = sorted_drop(i);
    if val < 0, val = 0; end
    
    text(val, i, sprintf(' -%.2f%%', val*100), ...
        'VerticalAlignment', 'middle', 'FontSize', 9, 'FontWeight', 'bold');
end

% Salvataggio
imgFile = fullfile(explainPath, 'SVM_Feature_Drop_All_HD.png');
exportgraphics(fig, imgFile, 'Resolution', 300);
fprintf('\nGrafico SVM (Tutte le feature) salvato in: %s\n', imgFile);

% --- SALVATAGGIO DATI IN CSV ---
ResultsTable = table(featureNames(idx)', mean_acc_drop(idx), ...
    'VariableNames', {'Feature', 'Mean_Accuracy_Drop'});
writetable(ResultsTable, fullfile(explainPath, 'SVM_Feature_Importance_Values.csv'));