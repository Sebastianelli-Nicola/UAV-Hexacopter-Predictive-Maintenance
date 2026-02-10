%% EXPLAINABILITY VISUAL: DECISION TREE (ESTETICA PERFETTA - TESTO DRITTO E CENTRATO)
clear all; clc; close all;
set(0, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 11, 'DefaultAxesFontName', 'Arial');

% --- 1. SETUP E CARICAMENTO ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset";
modelPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v2\tre classi\decision_tree_anova_v2"; 
explainPath = fullfile(modelPath, "explainability_HQ");
if ~exist(explainPath, 'dir'), mkdir(explainPath); end

load(fullfile(modelPath, "Best_DecisionTree_Model.mat"), 'Best_Model', 'best_split_idx');
load(fullfile(inputPath, "data_selected_features_anova_v2.mat"), 'feature_Table_Train_Reduced');

TrainTbl = feature_Table_Train_Reduced{best_split_idx};
responseVar = 'faultCode';
X_Train = TrainTbl(:, setdiff(TrainTbl.Properties.VariableNames, responseVar));
Y_Train = TrainTbl.(responseVar);

% --- 2. CREAZIONE ALBERO SEMPLIFICATO ---
fprintf('Generazione Albero Semplificato (Max 12 nodi)...\n');
Visual_Tree = fitctree(X_Train, Y_Train, ...
    'PredictorNames', X_Train.Properties.VariableNames, ...
    'MaxNumSplits', 12, ... 
    'Prune', 'on'); 

% --- 3. PREPARAZIONE ETICHETTE E LEGENDA ---
NumNodes = Visual_Tree.NumNodes;
Children = Visual_Tree.Children;

NodeID_List = (1:NumNodes)';
Description = strings(NumNodes, 1);
PlotLabels = strings(NumNodes, 1);

for i = 1:NumNodes
    if Visual_Tree.IsBranchNode(i)
        % NODO DECISIONE: Solo numero
        PlotLabels(i) = string(i); 
        
        varIdx = Visual_Tree.CutVar(i); 
        if iscell(varIdx), varName = varIdx{1}; else, varName = Visual_Tree.PredictorNames{varIdx}; end
        cutPoint = Visual_Tree.CutPoint(i);
        Description(i) = sprintf('SE %s < %.4f VAI A SX (Altrimenti DX)', varName, cutPoint);
        
    else
        % NODO FOGLIA: Classe predetta
        predClass = Visual_Tree.NodeClass(i);
        if iscell(predClass), predClass = string(predClass); end
        
        PlotLabels(i) = predClass; 
        Description(i) = sprintf('PREDIZIONE FINALE: %s', predClass);
    end
end

% Salva Legenda
LegendTable = table(NodeID_List, Description, 'VariableNames', {'Nodo', 'Regola_o_Risultato'});
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
csvFile = fullfile(explainPath, sprintf('DT_Rules_Legend_%s.csv', timestamp));
writetable(LegendTable, csvFile);

% --- 4. COSTRUZIONE GRAFO ---
sourceNodes = [];
targetNodes = [];
for i = 1:NumNodes
    if Children(i, 1) ~= 0, sourceNodes = [sourceNodes i]; targetNodes = [targetNodes Children(i, 1)]; end
    if Children(i, 2) ~= 0, sourceNodes = [sourceNodes i]; targetNodes = [targetNodes Children(i, 2)]; end
end
TreeGraph = digraph(sourceNodes, targetNodes);

% --- 5. VISUALIZZAZIONE ESTETICA (FIX PER CENTRATURA) ---
fig = figure('Name', 'Decision Tree Aesthetics', 'Color', 'w', 'Position', [50, 50, 1200, 750]);

h_plot = plot(TreeGraph, ...
    'Layout', 'layered', ...
    'NodeLabel', PlotLabels, ...     
    'Interpreter', 'none', ...       
    'EdgeColor', [0.4 0.4 0.4], ...  
    'LineWidth', 1.5, ...
    'NodeFontSize', 12, ...          % Font un po' più grande
    'NodeFontAngle', 'normal', ...   % <--- IMPORTANTE: QUESTO RADDRIZZA IL TESTO (No Italico)
    'NodeFontWeight', 'bold');       % Grassetto per renderlo nitido

% --- STYLING DEI NODI ---

% 1. STILE NODI DECISIONE (Cerchi Azzurri)
branchNodes = find(Visual_Tree.IsBranchNode);
if ~isempty(branchNodes)
    highlight(h_plot, branchNodes, ...
        'Marker', 'o', ...              
        'MarkerSize', 18, ...           % Abbastanza grande per centrare il numero
        'NodeColor', [0.6 0.8 1.0]);    
end

% 2. STILE NODI FOGLIA (Quadrati Verdi)
leafNodes = find(~Visual_Tree.IsBranchNode);
if ~isempty(leafNodes)
    highlight(h_plot, leafNodes, ...
        'Marker', 's', ...              
        'MarkerSize', 40, ...           % MOLTO GRANDE: così il testo ("Guasto") sta comodo al centro
        'NodeColor', [0.6 0.9 0.6]);    
end

% Titolo
title({'Albero Decisionale: Percorsi Diagnostici', ...
       'Cerchi Numerati = Regole (vedi Tabella CSV) | Quadrati = Predizione Finale'}, ...
       'FontSize', 14);

axis off; 

% --- SALVATAGGIO ---
imgFile = fullfile(explainPath, 'DT_Aesthetic_Tree_Fixed.png');
exportgraphics(fig, imgFile, 'Resolution', 300);
fprintf('Grafico salvato con testo dritto e centrato in: %s\n', imgFile);