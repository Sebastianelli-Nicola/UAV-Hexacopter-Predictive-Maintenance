%% EXPLAINABILITY VISUAL: NEURAL NETWORK SURROGATE (NO PRUNING - FULL FIDELITY)
clear all; clc; close all;
set(0, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 10, 'DefaultAxesFontName', 'Arial');

% --- 1. SETUP E CARICAMENTO ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset";
modelPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v3\tre classi\neural_network_anova_high_freq_2_peak"; 
explainPath = fullfile(modelPath, "explainability_HQ");
if ~exist(explainPath, 'dir'), mkdir(explainPath); end

load(fullfile(modelPath, "Best_NeuralNetwork_Model.mat"), 'Best_Model', 'best_split_idx');
load(fullfile(inputPath, "data_selected_features_anova_high_freq_2_peak.mat"), 'feature_Table_Train_Reduced');

% Dati e Pulizia
TrainTbl = feature_Table_Train_Reduced{best_split_idx};
TrainTbl = rmmissing(TrainTbl); % Rimuoviamo NaN

responseVar = 'faultCode';
X_Train = TrainTbl(:, setdiff(TrainTbl.Properties.VariableNames, responseVar));

% --- 2. GENERAZIONE TARGET (PREDIZIONI NN) ---
fprintf('Generazione predizioni della Neural Network...\n');
Y_Pred_NN = predict(Best_Model, X_Train);
if isnumeric(Y_Pred_NN), Y_Pred_NN = string(Y_Pred_NN); end

% --- 3. ADDESTRAMENTO SURROGATO (NO PRUNING) ---
fprintf('Addestramento Albero Surrogato (SENZA PRUNING)...\n');
fprintf('Questo albero crescerà al massimo per imitare la rete.\n');

Surrogate_Tree = fitctree(X_Train, Y_Pred_NN, ...
    'PredictorNames', X_Train.Properties.VariableNames, ...
    'Prune', 'off', ...           % <--- NESSUNA POTATURA
    'MergeLeaves', 'off');        % <--- NESSUNA UNIONE FOGLIE

NumNodes = Surrogate_Tree.NumNodes;
fprintf('-> L''albero risultante ha %d nodi.\n', NumNodes);

% --- 4. CALCOLO FEDELTÀ ---
Y_Pred_Surrogate = predict(Surrogate_Tree, X_Train);
fidelity = sum(strcmp(string(Y_Pred_Surrogate), string(Y_Pred_NN))) / length(Y_Pred_NN);

fprintf('FEDELTÀ DEL SURROGATO: %.2f%%\n', fidelity * 100);

% Pie Chart Fidelity
fig1 = figure('Color', 'w', 'Position', [100, 100, 600, 400]);
pie([fidelity, 1-fidelity], {sprintf('Spiegato (%.1f%%)', fidelity*100), 'Non Spiegato'});
colormap([0.4660 0.6740 0.1880; 0.8500 0.3250 0.0980]); 
title({'Fedeltà del Modello Surrogato (No Pruning)', 'L''albero imita quasi perfettamente la rete'}, 'FontSize', 12);
exportgraphics(fig1, fullfile(explainPath, 'NN_Fidelity_Pie_NoPruning.png'), 'Resolution', 300);

% --- 5. MAPPATURA E TABELLA INTELLIGENTE ---
Children = Surrogate_Tree.Children;
NodeMap = zeros(NumNodes, 1);
ruleCounter = 0;
PlotLabels = strings(NumNodes, 1);

% Assegnazione ID Regole
for i = 1:NumNodes
    if Surrogate_Tree.IsBranchNode(i)
        ruleCounter = ruleCounter + 1;
        NodeMap(i) = ruleCounter;
        PlotLabels(i) = string(ruleCounter);
    else
        predClass = Surrogate_Tree.NodeClass(i);
        if iscell(predClass), predClass = string(predClass); end
        PlotLabels(i) = predClass;
    end
end

% Creazione Liste per CSV
RuleID_List = [];
Condition_List = string.empty;
True_Target_List = string.empty;  
False_Target_List = string.empty; 

for i = 1:NumNodes
    if Surrogate_Tree.IsBranchNode(i)
        myRuleID = NodeMap(i);
        varIdx = Surrogate_Tree.CutVar(i); 
        if iscell(varIdx), varName = varIdx{1}; else, varName = Surrogate_Tree.PredictorNames{varIdx}; end
        cutPoint = Surrogate_Tree.CutPoint(i);
        
        % Target Sinistro
        idxLeft = Children(i, 1);
        if Surrogate_Tree.IsBranchNode(idxLeft)
            targetLeft = sprintf('Vai a Regola %d', NodeMap(idxLeft));
        else
            targetLeft = sprintf('CLASSE: %s', string(Surrogate_Tree.NodeClass(idxLeft)));
        end
        
        % Target Destro
        idxRight = Children(i, 2);
        if Surrogate_Tree.IsBranchNode(idxRight)
            targetRight = sprintf('Vai a Regola %d', NodeMap(idxRight));
        else
            targetRight = sprintf('CLASSE: %s', string(Surrogate_Tree.NodeClass(idxRight)));
        end
        
        RuleID_List = [RuleID_List; myRuleID];
        Condition_List = [Condition_List; string(sprintf('%s < %.4f', varName, cutPoint))];
        True_Target_List = [True_Target_List; string(targetLeft)];
        False_Target_List = [False_Target_List; string(targetRight)];
    end
end

% Salvataggio CSV
NavigationTable = table(RuleID_List, Condition_List, True_Target_List, False_Target_List, ...
    'VariableNames', {'Regola_Num', 'Condizione_Check', 'Se_VERO_Vai_A', 'Se_FALSO_Vai_A'});

timestamp = datestr(now, 'yyyymmdd_HHMMSS');
csvFile = fullfile(explainPath, sprintf('NN_Surrogate_Rules_NoPruning_%s.csv', timestamp));
writetable(NavigationTable, csvFile);
fprintf('Tabella Regole salvata in: %s\n', csvFile);

% --- 6. VISUALIZZAZIONE GRAFICA ADATTIVA ---
sourceNodes = [];
targetNodes = [];
for i = 1:NumNodes
    if Children(i, 1) ~= 0, sourceNodes = [sourceNodes i]; targetNodes = [targetNodes Children(i, 1)]; end
    if Children(i, 2) ~= 0, sourceNodes = [sourceNodes i]; targetNodes = [targetNodes Children(i, 2)]; end
end
TreeGraph = digraph(sourceNodes, targetNodes);

% Dimensione Figura Maggiorata
fig2 = figure('Name', 'NN Surrogate Tree Full', 'Color', 'w', 'Position', [10, 10, 1800, 900]);

% --- LOGICA ADATTIVA DIMENSIONI ---
% Se l'albero è enorme (perché non potato), riduciamo i pallini per non fare un pasticcio
if NumNodes > 100
    fprintf('Albero molto grande (%d nodi). Adatto la grafica per renderlo leggibile.\n', NumNodes);
    branchSize = 8;     leafSize = 15;     fSize = 7;
elseif NumNodes > 50
    branchSize = 12;    leafSize = 25;     fSize = 9;
else
    branchSize = 18;    leafSize = 40;     fSize = 11;
end

h_plot = plot(TreeGraph, ...
    'Layout', 'layered', ...
    'NodeLabel', PlotLabels, ...     
    'Interpreter', 'none', ...       
    'EdgeColor', [0.6 0.6 0.6], ...  
    'LineWidth', 1, ...              
    'NodeFontSize', fSize, ...       % Font adattivo
    'NodeFontAngle', 'normal', ...   
    'NodeFontWeight', 'bold');       

% Stile Nodi
branchNodes = find(Surrogate_Tree.IsBranchNode);
if ~isempty(branchNodes)
    highlight(h_plot, branchNodes, 'Marker', 'o', 'MarkerSize', branchSize, 'NodeColor', [0.6 0.8 1.0]);    
end

leafNodes = find(~Surrogate_Tree.IsBranchNode);
if ~isempty(leafNodes)
    highlight(h_plot, leafNodes, 'Marker', 's', 'MarkerSize', leafSize, 'NodeColor', [0.7 0.95 0.7]);   
end

title({'Surrogato Neural Network (No Pruning)', ...
       sprintf('Fedeltà: %.2f%% | Totale Nodi: %d', fidelity*100, NumNodes)}, ...
       'FontSize', 14);
axis off; 

% Export
imgFile = fullfile(explainPath, 'NN_Surrogate_Tree_NoPruning.png');
exportgraphics(fig2, imgFile, 'Resolution', 600); % Alta risoluzione per zoomare
fprintf('Grafico salvato in: %s\n', imgFile);

% PDF Vettoriale (Essenziale se l'albero è grande)
pdfFile = fullfile(explainPath, 'NN_Surrogate_Tree_NoPruning.pdf');
exportgraphics(fig2, pdfFile, 'ContentType', 'vector');
fprintf('PDF Vettoriale salvato in: %s\n', pdfFile);