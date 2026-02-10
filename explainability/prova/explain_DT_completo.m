%% EXPLAINABILITY VISUAL: ALBERO CON TABELLA DI NAVIGAZIONE (FIXED STRING ERROR)
clear all; clc; close all;
set(0, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 10, 'DefaultAxesFontName', 'Arial');

% --- 1. SETUP E CARICAMENTO ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset";
modelPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v3\due classi\decision_tree_kruskal_high_freq_2_peak"; 
explainPath = fullfile(modelPath, "explainability_HQ");
if ~exist(explainPath, 'dir'), mkdir(explainPath); end

load(fullfile(modelPath, "Best_Binary_Tree_Model.mat"), 'Best_Model');

% Usiamo l'albero completo
Full_Tree = Best_Model; 
NumNodes = Full_Tree.NumNodes;
Children = Full_Tree.Children; % [FiglioSX, FiglioDX]

fprintf('Analisi Albero e Mappatura Navigazione...\n');

% --- 2. PASSAGGIO 1: MAPPATURA ID REGOLE ---
% Dobbiamo assegnare un "Numero Regola" (1, 2, 3...) solo ai nodi di decisione.
NodeMap = zeros(NumNodes, 1); % Mappa: Indice Matlab -> Mio Numero Regola
ruleCounter = 0;
PlotLabels = strings(NumNodes, 1); 

for i = 1:NumNodes
    if Full_Tree.IsBranchNode(i)
        ruleCounter = ruleCounter + 1;
        NodeMap(i) = ruleCounter;       % Assegna ID Regola
        PlotLabels(i) = string(ruleCounter);
    else
        predClass = Full_Tree.NodeClass(i);
        if iscell(predClass), predClass = string(predClass); end
        PlotLabels(i) = predClass;      % Assegna Nome Classe
    end
end

% --- 3. PASSAGGIO 2: COSTRUZIONE TABELLA (CON STRINGHE) ---
% Inizializziamo come array di STRINGHE vuote per evitare l'errore vertcat
RuleID_List = [];
Condition_List = string.empty;
True_Target_List = string.empty;  
False_Target_List = string.empty; 

for i = 1:NumNodes
    if Full_Tree.IsBranchNode(i)
        % Recuperiamo i dati
        myRuleID = NodeMap(i);
        
        varIdx = Full_Tree.CutVar(i); 
        if iscell(varIdx), varName = varIdx{1}; else, varName = Full_Tree.PredictorNames{varIdx}; end
        cutPoint = Full_Tree.CutPoint(i);
        
        % --- LOGICA DI NAVIGAZIONE ---
        
        % 1. Analisi Figlio SINISTRO (Condizione Vera: < )
        idxLeft = Children(i, 1);
        if Full_Tree.IsBranchNode(idxLeft)
            % Punta a un'altra regola
            targetLeft = sprintf('Vai a Regola %d', NodeMap(idxLeft));
        else
            % Punta a una foglia
            targetLeft = sprintf('CLASSE: %s', string(Full_Tree.NodeClass(idxLeft)));
        end
        
        % 2. Analisi Figlio DESTRO (Condizione Falsa: >= )
        idxRight = Children(i, 2);
        if Full_Tree.IsBranchNode(idxRight)
            % Punta a un'altra regola
            targetRight = sprintf('Vai a Regola %d', NodeMap(idxRight));
        else
            % Punta a una foglia
            targetRight = sprintf('CLASSE: %s', string(Full_Tree.NodeClass(idxRight)));
        end
        
        % --- SALVATAGGIO SICURO (CONVERSIONE IN STRING) ---
        RuleID_List = [RuleID_List; myRuleID];
        
        % Qui usiamo string() per forzare il tipo ed evitare l'errore di dimensioni
        Condition_List = [Condition_List; string(sprintf('%s < %.4f', varName, cutPoint))];
        True_Target_List = [True_Target_List; string(targetLeft)];
        False_Target_List = [False_Target_List; string(targetRight)];
    end
end

% --- CREAZIONE TABELLA ---
NavigationTable = table(RuleID_List, Condition_List, True_Target_List, False_Target_List, ...
    'VariableNames', {'Regola_Num', 'Condizione_Check', 'Se_VERO_Vai_A', 'Se_FALSO_Vai_A'});

% Salvataggio CSV con timestamp per evitare blocchi
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
csvFile = fullfile(explainPath, sprintf('DT_Navigation_Table_%s.csv', timestamp));
writetable(NavigationTable, csvFile);

fprintf('Tabella Navigazione salvata in: %s\n', csvFile);
disp('--- ANTEPRIMA TABELLA ---');
disp(head(NavigationTable, 5)); 

% --- 4. VISUALIZZAZIONE GRAFICA ---
sourceNodes = [];
targetNodes = [];
for i = 1:NumNodes
    if Children(i, 1) ~= 0, sourceNodes = [sourceNodes i]; targetNodes = [targetNodes Children(i, 1)]; end
    if Children(i, 2) ~= 0, sourceNodes = [sourceNodes i]; targetNodes = [targetNodes Children(i, 2)]; end
end
TreeGraph = digraph(sourceNodes, targetNodes);

fig = figure('Name', 'Full Decision Tree Smart', 'Color', 'w', 'Position', [10, 10, 1800, 900]);

% Adattamento dimensioni
if NumNodes > 60
    baseNodeSize = 10; leafNodeSize = 18; fontSize = 8;
else
    baseNodeSize = 16; leafNodeSize = 35; fontSize = 11;
end

h_plot = plot(TreeGraph, ...
    'Layout', 'layered', ...
    'NodeLabel', PlotLabels, ...     
    'Interpreter', 'none', ...       
    'EdgeColor', [0.6 0.6 0.6], ...  
    'LineWidth', 1, ...
    'NodeFontSize', fontSize, ...           
    'NodeFontAngle', 'normal', ...   % Testo dritto
    'NodeFontWeight', 'bold');      

% Highlight Regole (Blu)
branchNodes = find(Full_Tree.IsBranchNode);
if ~isempty(branchNodes)
    highlight(h_plot, branchNodes, 'Marker', 'o', 'MarkerSize', baseNodeSize, 'NodeColor', [0.6 0.8 1.0]);    
end

% Highlight Foglie (Verdi)
leafNodes = find(~Full_Tree.IsBranchNode);
if ~isempty(leafNodes)
    highlight(h_plot, leafNodes, 'Marker', 's', 'MarkerSize', leafNodeSize, 'NodeColor', [0.7 0.95 0.7]);   
end

axis off; 

% Export
imgFile = fullfile(explainPath, 'DT_Full_Smart_Visual.png');
exportgraphics(fig, imgFile, 'Resolution', 300); 
fprintf('Grafico salvato in: %s\n', imgFile);