%% EXPLAINABILITY VISUAL: RANDOM FOREST (IMPORTANCE + 2 ALBERI + IMPORTANCE LOCALE)
clear all; clc; close all;
set(0, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 11, 'DefaultAxesFontName', 'Arial');

% --- 1. SETUP E CARICAMENTO ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset";
modelPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v3\tre classi\random_forest_anova_high_freq_2_peak"; 
explainPath = fullfile(modelPath, "explainability_HQ");
if ~exist(explainPath, 'dir'), mkdir(explainPath); end

load(fullfile(modelPath, "Best_RandomForest_Model.mat"), 'Best_Model');

% --- 2. GLOBAL FEATURE IMPORTANCE (OOB) ---
% Questa è l'importanza media di TUTTA la foresta
try
    imp = Best_Model.OOBPermutedPredictorImportance;
catch
    imp = predictorImportance(Best_Model); 
end
[sorted_imp, idx] = sort(imp, 'descend');
n_show = 12;
top_scores = sorted_imp(1:n_show);
top_names = Best_Model.PredictorNames(idx(1:n_show));

figImp = figure('Color', 'w', 'Position', [100, 100, 900, 600]);
barh(top_scores, 'FaceColor', [0.9290 0.6940 0.1250]); % Giallo Oro
yticklabels(top_names);
xlabel('OOB Permuted Importance (Globale)', 'FontWeight', 'bold');
title('Random Forest: Gerarchia delle Feature (Intera Foresta)', 'FontSize', 14);
grid on; set(gca, 'YDir', 'reverse');
for i = 1:n_show
    text(top_scores(i), i, sprintf(' %.4f', top_scores(i)), 'VerticalAlignment', 'middle');
end
exportgraphics(figImp, fullfile(explainPath, 'RF_Global_Importance_HD.png'), 'Resolution', 300);
fprintf('Grafico Global Importance salvato.\n');

% --- 3. SELEZIONE DI 2 ALBERI DIVERSI ---
Tree1_Idx = 1;
Tree1 = Best_Model.Trained{Tree1_Idx};
RootVar1 = Tree1.CutVar(1); 

Tree2_Idx = 2; 
foundDifferent = false;
for i = 2:numel(Best_Model.Trained)
    TempTree = Best_Model.Trained{i};
    if ~isequal(TempTree.CutVar(1), RootVar1)
        Tree2_Idx = i;
        foundDifferent = true;
        break;
    end
end
if ~foundDifferent, fprintf('Uso alberi #1 e #2 (simili).\n'); end

SelectedTrees = {Tree1, Best_Model.Trained{Tree2_Idx}};
TreeIndices = [Tree1_Idx, Tree2_Idx];
TreeNames = ["A", "B"];

% --- 4. CICLO DI ELABORAZIONE (ALBERI SINGOLI) ---
for t = 1:2
    CurrentTree = SelectedTrees{t};
    TreeID = TreeIndices(t);
    LabelID = TreeNames(t);
    
    fprintf('\n--- Elaborazione Albero Esempio %s (ID: %d) ---\n', LabelID, TreeID);
    
    % =====================================================================
    % NUOVA PARTE: FEATURE IMPORTANCE "LOCALE" (Specifico Albero)
    % =====================================================================
    % predictorImportance su un singolo albero calcola la somma del 
    % guadagno di rischio (Risk Reduction / Gini Decrease) per ogni feature.
    imp_local = predictorImportance(CurrentTree);
    
    [sorted_loc, idx_loc] = sort(imp_local, 'descend');
    
    % Prendiamo le Top 10 per questo specifico albero
    n_show_local = 10;
    % Protezione se ci sono meno di 10 feature usate
    n_actual = sum(sorted_loc > 0);
    n_show_local = min(n_show_local, n_actual);
    
    scores_loc = sorted_loc(1:n_show_local);
    names_loc = CurrentTree.PredictorNames(idx_loc(1:n_show_local));
    
    % --- Grafico Importance Locale ---
    figLoc = figure('Name', sprintf('Importance Tree %s', LabelID), 'Color', 'w', 'Position', [150, 150, 800, 500]);
    barh(scores_loc, 'FaceColor', [0.5 0.3 0.7]); % Viola (per distinguerlo dal Globale)
    yticklabels(names_loc);
    xlabel('Riduzione del Rischio (Gini Decrease)', 'FontWeight', 'bold');
    title({sprintf('Feature Determinanti per l''Albero %s', LabelID), ...
           '(Variabili che minimizzano la loss in questo specifico ramo)'}, 'FontSize', 12);
    grid on; set(gca, 'YDir', 'reverse');
    
    % Valori numerici
    for k = 1:n_show_local
        text(scores_loc(k), k, sprintf(' %.4f', scores_loc(k)), 'VerticalAlignment', 'middle');
    end
    
    imgLocName = sprintf('RF_Tree_%s_Local_Importance.png', LabelID);
    exportgraphics(figLoc, fullfile(explainPath, imgLocName), 'Resolution', 300);
    fprintf('Grafico Local Importance (%s) salvato.\n', LabelID);
    
    % =====================================================================
    % FINE NUOVA PARTE - PROSEGUE CON NAVIGAZIONE E VISUALIZZAZIONE ALBERO
    % =====================================================================
    
    NumNodes = CurrentTree.NumNodes;
    Children = CurrentTree.Children;
    
    % --- Mappatura ID Regole ---
    NodeMap = zeros(NumNodes, 1);
    ruleCounter = 0;
    PlotLabels = strings(NumNodes, 1); 

    for i = 1:NumNodes
        if CurrentTree.IsBranchNode(i)
            ruleCounter = ruleCounter + 1;
            NodeMap(i) = ruleCounter;
            PlotLabels(i) = string(ruleCounter);
        else
            predClass = CurrentTree.NodeClass(i);
            if iscell(predClass), predClass = string(predClass); end
            PlotLabels(i) = predClass;
        end
    end
    
    % --- Tabella Navigazione ---
    RuleID_List = []; Condition_List = string.empty; 
    True_Target_List = string.empty; False_Target_List = string.empty; 
    
    for i = 1:NumNodes
        if CurrentTree.IsBranchNode(i)
            myRuleID = NodeMap(i);
            varIdx = CurrentTree.CutVar(i); 
            if iscell(varIdx), varName = varIdx{1}; else, varName = CurrentTree.PredictorNames{varIdx}; end
            cutPoint = CurrentTree.CutPoint(i);
            
            % Target SX
            idxLeft = Children(i, 1);
            if CurrentTree.IsBranchNode(idxLeft), targetLeft = sprintf('Vai a Regola %d', NodeMap(idxLeft));
            else, targetLeft = sprintf('CLASSE: %s', string(CurrentTree.NodeClass(idxLeft))); end
            
            % Target DX
            idxRight = Children(i, 2);
            if CurrentTree.IsBranchNode(idxRight), targetRight = sprintf('Vai a Regola %d', NodeMap(idxRight));
            else, targetRight = sprintf('CLASSE: %s', string(CurrentTree.NodeClass(idxRight))); end
            
            RuleID_List = [RuleID_List; myRuleID];
            Condition_List = [Condition_List; string(sprintf('%s < %.4f', varName, cutPoint))];
            True_Target_List = [True_Target_List; string(targetLeft)];
            False_Target_List = [False_Target_List; string(targetRight)];
        end
    end
    
    NavTable = table(RuleID_List, Condition_List, True_Target_List, False_Target_List, ...
        'VariableNames', {'Regola_Num', 'Condizione_Check', 'Se_VERO_Vai_A', 'Se_FALSO_Vai_A'});
    writetable(NavTable, fullfile(explainPath, sprintf('RF_Tree_%s_Navigation_Table.csv', LabelID)));
    
    % --- Visualizzazione Grafica ---
    sourceNodes = []; targetNodes = [];
    for i = 1:NumNodes
        if Children(i, 1) ~= 0, sourceNodes = [sourceNodes i]; targetNodes = [targetNodes Children(i, 1)]; end
        if Children(i, 2) ~= 0, sourceNodes = [sourceNodes i]; targetNodes = [targetNodes Children(i, 2)]; end
    end
    TreeGraph = digraph(sourceNodes, targetNodes);
    
    figT = figure('Name', sprintf('RF Tree %s', LabelID), 'Color', 'w', 'Position', [50, 50, 1800, 900]);
    
    if NumNodes > 100, bSize = 8; lSize = 15; fSize = 7;
    elseif NumNodes > 50, bSize = 12; lSize = 25; fSize = 9;
    else, bSize = 16; lSize = 35; fSize = 11; end
    
    h_plot = plot(TreeGraph, 'Layout', 'layered', 'NodeLabel', PlotLabels, 'Interpreter', 'none', ...
        'EdgeColor', [0.6 0.6 0.6], 'LineWidth', 1, 'NodeFontSize', fSize, ...
        'NodeFontAngle', 'normal', 'NodeFontWeight', 'bold');      
    
    branchNodes = find(CurrentTree.IsBranchNode);
    if ~isempty(branchNodes), highlight(h_plot, branchNodes, 'Marker', 'o', 'MarkerSize', bSize, 'NodeColor', [0.6 0.8 1.0]); end
    leafNodes = find(~CurrentTree.IsBranchNode);
    if ~isempty(leafNodes), highlight(h_plot, leafNodes, 'Marker', 's', 'MarkerSize', lSize, 'NodeColor', [0.7 0.95 0.7]); end
    
    title({sprintf('Random Forest: Albero Esempio %s (ID Foresta: %d)', LabelID, TreeID), ...
           sprintf('Totale Nodi: %d - Vedi grafico a barre per le feature chiave', NumNodes)}, 'FontSize', 14);
    axis off; 
    
    exportgraphics(figT, fullfile(explainPath, sprintf('RF_Tree_%s_Visual.png', LabelID)), 'Resolution', 600);
    exportgraphics(figT, fullfile(explainPath, sprintf('RF_Tree_%s_Visual.pdf', LabelID)), 'ContentType', 'vector');
end
fprintf('Elaborazione completata.\n');