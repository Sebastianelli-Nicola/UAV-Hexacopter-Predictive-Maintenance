%% EXPLAINABILITY VISUAL: DECISION TREE (CON REGOLE NUMERATE)
clear all; clc; close all;
% --- CONFIGURAZIONE GRAFICA GENERALE ---
set(0, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 12, 'DefaultAxesFontName', 'Arial');

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset";
modelPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v2\tre classi\decision_tree_anova_v2"; 
explainPath = fullfile(modelPath, "explainability_HQ");
if ~exist(explainPath, 'dir'), mkdir(explainPath); end

% Caricamento
load(fullfile(modelPath, "Best_DecisionTree_Model.mat"), 'Best_Model');

%% 1. FEATURE IMPORTANCE
imp = predictorImportance(Best_Model);
[sorted_imp, idx] = sort(imp, 'descend');
top_vars = Best_Model.PredictorNames(idx);
n_top = min(10, length(sorted_imp));

fig1 = figure('Name', 'DT Feature Importance', 'Color', 'w', 'Position', [100, 100, 900, 500]);
barh(sorted_imp(1:n_top), 'FaceColor', [0.2 0.4 0.7]);
yticklabels(top_vars(1:n_top));
xlabel('Gini Importance Score', 'FontWeight', 'bold');
title('Top 10 Feature Determinanti (Decision Tree)', 'FontSize', 14);
grid on; set(gca, 'YDir', 'reverse');

for i = 1:n_top
    text(sorted_imp(i), i, sprintf(' %.4f', sorted_imp(i)), 'VerticalAlignment', 'middle', 'FontSize', 10);
end
exportgraphics(fig1, fullfile(explainPath, 'DT_Feature_Importance_HD.png'), 'Resolution', 300);

%% 2. STRUTTURA ALBERO GRAFICA
fig2 = figure('Name', 'DT Structure', 'Color', 'w', 'Position', [50, 50, 1200, 800]);
view(Best_Model, 'Mode', 'graph');
title('Struttura Decisionale dell''Albero', 'FontSize', 14);
saveas(fig2, fullfile(explainPath, 'DT_Structure_Graph.png'));

%% 3. ESTRAZIONE REGOLE (TABELLARE)
fprintf('Estrazione delle regole logiche (IF-THEN) dai nodi foglia...\n');

% Troviamo tutti i nodi foglia (dove l'albero prende una decisione finale)
isLeaf = ~Best_Model.IsBranchNode;
leafIndices = find(isLeaf);
nRules = length(leafIndices);

RuleID = zeros(nRules, 1);
Predictions = string(zeros(nRules, 1));
LogicConditions = string(zeros(nRules, 1));
NodeConfidences = zeros(nRules, 1);

% Ciclo su ogni foglia per ricostruire il percorso all'indietro
for i = 1:nRules
    leafNode = leafIndices(i);
    
    % Recuperiamo la classe predetta in questa foglia
    predClass = Best_Model.NodeClass(leafNode);
    if iscell(predClass), predClass = string(predClass); end
    
    % Probabilità (Confidenza) della foglia
    % Nota: NodeProbability è la frequenza relativa dei campioni in quel nodo
    nodeProb = Best_Model.NodeProbability(leafNode);
    
    % --- RICOSTRUZIONE REGOLA (Backtracking) ---
    conditions = {};
    currentNode = leafNode;
    parentNode = Best_Model.Parent(currentNode);
    
    while parentNode ~= 0 % Finché non arriviamo alla radice (0)
        % Troviamo quale figlio siamo (Sinistro o Destro)
        children = Best_Model.Children(parentNode, :);
        varName = Best_Model.CutVar{parentNode};
        cutPoint = Best_Model.CutPoint(parentNode);
        
        if currentNode == children(1) % Figlio Sinistro (<)
            cond = sprintf('%s < %.4f', varName, cutPoint);
        else % Figlio Destro (>=)
            cond = sprintf('%s >= %.4f', varName, cutPoint);
        end
        
        % Aggiungiamo la condizione all'inizio della lista (perché stiamo andando all'indietro)
        conditions = [{cond}, conditions];
        
        % Saliamo di un livello
        currentNode = parentNode;
        parentNode = Best_Model.Parent(currentNode);
    end
    
    % Uniamo tutte le condizioni con "AND"
    fullRule = strjoin(conditions, ' AND ');
    
    % Salvataggio nei vettori
    RuleID(i) = i; % Numero sequenziale della regola
    Predictions(i) = string(predClass);
    LogicConditions(i) = fullRule;
    NodeConfidences(i) = nodeProb;
end

% Creazione Tabella
RulesTable = table(RuleID, Predictions, NodeConfidences, LogicConditions, ...
    'VariableNames', {'Regola_Num', 'Classe_Predetta', 'Prob_Nodo', 'Logica_Decisionale'});

% Visualizzazione a video delle prime 5 regole
disp('--- ESEMPIO REGOLE ESTRATTE ---');
disp(RulesTable(1:min(5, height(RulesTable)), :));

% Salvataggio CSV
csvFile = fullfile(explainPath, 'DT_Rules_Table.csv');
writetable(RulesTable, csvFile);
fprintf('[OK] Tabella Regole salvata in: %s\n', csvFile);

%% 4. SALVATAGGIO VISTA TESTUALE (PER CONFRONTO NODI)
% Questo file serve a vedere i numeri "ufficiali" dei nodi di MATLAB
txtFile = fullfile(explainPath, 'DT_Nodes_Map.txt');
fid = fopen(txtFile, 'w');
fprintf(fid, '=== MAPPA NODI ALBERO (View Text) ===\n\n');
tree_text = evalc('view(Best_Model, ''Mode'', ''text'')');
fprintf(fid, '%s', tree_text);
fclose(fid);
fprintf('[OK] Mappa testuale nodi salvata in: %s\n', txtFile);