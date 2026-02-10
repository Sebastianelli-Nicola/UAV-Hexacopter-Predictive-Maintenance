%% EXPLAINABILITY VISUAL: SVM (ROBUST PERMUTATION - 10 RIPETIZIONI)
clear all; clc; close all;
set(0, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 12, 'DefaultAxesFontName', 'Arial');

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset";
modelPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v3\tre classi\svm_kruskal_high_freq_2_peak"; 
explainPath = fullfile(modelPath, "explainability_HQ");
if ~exist(explainPath, 'dir'), mkdir(explainPath); end

% --- CARICAMENTO ---
fprintf('Caricamento modello e dati...\n');
load(fullfile(modelPath, "Best_SVM_Model.mat"), 'Best_Model', 'best_split_idx'); 
load(fullfile(inputPath, "data_selected_features_kruskal_high_freq_2_peak.mat"), 'feature_Table_Test_Reduced');

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
n_repeats = 10; % Numero di volte che mescoliamo ogni feature per fare la media
featureNames = X_Test.Properties.VariableNames;
n_features = length(featureNames);

mean_acc_drop = zeros(n_features, 1); % Qui salviamo la media del calo
std_acc_drop = zeros(n_features, 1);  % (Opzionale) Deviazione standard

fprintf('\nInizio calcolo Permutation Importance (%d ripetizioni per feature)...\n', n_repeats);
fprintf('Questo processo potrebbe richiedere qualche secondo.\n');

% --- CICLO SU OGNI FEATURE ---
for i = 1:n_features
    current_feature = featureNames{i};
    drops_for_this_feature = zeros(n_repeats, 1);
    
    % Stampiamo progresso ogni tanto
    fprintf(' -> Analisi feature %d/%d: %s... ', i, n_features, current_feature);
    
    % --- CICLO DI RIPETIZIONE (Monte Carlo) ---
    for k = 1:n_repeats
        X_Perm = X_Test; % Copia fresca dei dati
        
        % Mescoliamo casualmente la colonna
        X_Perm.(current_feature) = X_Perm.(current_feature)(randperm(height(X_Perm)));
        
        % Calcoliamo accuratezza sul dato "rotto"
        perm_acc = 1 - loss(Best_Model, X_Perm, Y_Test);
        
        % Salviamo quanto abbiamo perso rispetto alla base
        drops_for_this_feature(k) = base_acc - perm_acc;
    end
    
    % Calcoliamo la MEDIA dei cali
    mean_drop = mean(drops_for_this_feature);
    mean_acc_drop(i) = mean_drop;
    
    fprintf('Calo Medio: %.2f%%\n', mean_drop*100);
end

% --- ORDINAMENTO ---
[sorted_drop, idx] = sort(mean_acc_drop, 'descend');
n_show = min(15, length(sorted_drop)); % Mostriamo le 15 migliori

% --- GRAFICO ---
fig = figure('Color', 'w', 'Position', [100, 100, 1000, 600]);

% Creiamo il grafico a barre
b = barh(sorted_drop(1:n_show), 'FaceColor', [0.8 0.3 0.3]); % Rosso SVM

yticklabels(featureNames(idx(1:n_show)));
xlabel(sprintf('Perdita Media di Accuratezza (su %d permutazioni)', n_repeats), 'FontWeight', 'bold');
title(sprintf('SVM Feature Importance (Robust Permutation)'), 'FontSize', 14);
grid on; set(gca, 'YDir', 'reverse');

% Aggiunta etichette percentuali precise
for i = 1:n_show
    val = sorted_drop(i);
    % Se il calo è negativo (strano ma possibile col rumore), mettiamo 0
    if val < 0, val = 0; end
    
    text(val, i, sprintf(' -%.2f%%', val*100), ...
        'VerticalAlignment', 'middle', 'FontSize', 10, 'FontWeight', 'bold');
end

% Salvataggio
imgFile = fullfile(explainPath, 'SVM_Feature_Drop_Robust_HD.png');
exportgraphics(fig, imgFile, 'Resolution', 300);
fprintf('\nGrafico SVM (Robusto) salvato in: %s\n', imgFile);

% --- SALVATAGGIO DATI IN CSV ---
% È utile avere anche i numeri esatti
ResultsTable = table(featureNames(idx)', mean_acc_drop(idx), ...
    'VariableNames', {'Feature', 'Mean_Accuracy_Drop'});
writetable(ResultsTable, fullfile(explainPath, 'SVM_Feature_Importance_Values.csv'));