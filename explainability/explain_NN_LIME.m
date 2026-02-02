%% 1. CARICAMENTO E SETUP
clear all; clc; close all;

% --- PERCORSI ---
inputPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\dataset"; 
modelPath = "C:\Users\seba9\Documents\MATLAB\ProgettoDrone\results_v2\tre classi\neural_network_anova_v2";
explainPath = fullfile(modelPath, "explainability_LIME");

if ~exist(explainPath, 'dir')
    mkdir(explainPath);
end

% --- CARICAMENTO MODELLO ---
modelFile = fullfile(modelPath, "Best_NeuralNetwork_Model.mat");
if ~isfile(modelFile), error('Modello non trovato: %s', modelFile); end
fprintf('Caricamento Modello Migliore...\n');
load(modelFile, 'Best_Model', 'best_split_idx', 'best_test_acc');

% --- CARICAMENTO DATASET ---
dataFile = "data_selected_features_anova_v2.mat";
fullDataPath = fullfile(inputPath, dataFile);
if ~isfile(fullDataPath), error('Dataset non trovato: %s', fullDataPath); end
fprintf('Caricamento Dataset...\n');
load(fullDataPath, 'feature_Table_Test_Reduced', 'feature_Table_Train_Reduced');

% Recuperiamo i dati dello split migliore
TestTbl = feature_Table_Test_Reduced{best_split_idx};
TrainTbl = feature_Table_Train_Reduced{best_split_idx}; 

responseVar = 'faultCode';
X_Test = TestTbl(:, setdiff(TestTbl.Properties.VariableNames, responseVar));
Y_Test = TestTbl.(responseVar);
X_Train = TrainTbl(:, setdiff(TrainTbl.Properties.VariableNames, responseVar));

%% 2. SELEZIONE DI UN "CASO STUDIO" (QUERY POINT)
fprintf('Generazione predizioni sul Test Set...\n');
Y_Pred = predict(Best_Model, X_Test);

% --- MODIFICA PER ERRORE CATEGORICAL ---
% Definiamo la classe che vogliamo analizzare (es. 1 = Guasto)
targetClass = 1; 

% Convertiamo tutto in stringa per evitare l'errore "Comparison not defined"
Y_Test_Str = string(Y_Test);
Y_Pred_Str = string(Y_Pred);
Target_Str = string(targetClass);

% Cerchiamo i "True Positives" (Casi reali=1 e predetti=1)
idx_TP = find(Y_Test_Str == Target_Str & Y_Pred_Str == Target_Str);

if isempty(idx_TP)
    warning('Nessun caso True Positive trovato per la classe %d. Prendo il primo elemento del Test Set.', targetClass);
    queryIdx = 1;
else
    % Prendiamo il primo caso trovato
    queryIdx = idx_TP(1); 
end

QueryPoint = X_Test(queryIdx, :);
RealLabel = Y_Test(queryIdx);
PredLabel = Y_Pred(queryIdx);

fprintf('\n--- CASO STUDIO SELEZIONATO ---\n');
fprintf('Indice nel Test Set: %d\n', queryIdx);
fprintf('Classe Reale:    %s\n', string(RealLabel));
fprintf('Classe Predetta: %s\n', string(PredLabel));
fprintf('-----------------------------\n');

%% 3. CONFIGURAZIONE DI LIME
fprintf('Configurazione LIME (Local Interpretable Model-agnostic Explanations)...\n');
fprintf('Nota: Potrebbe impiegare qualche secondo...\n');

% Creiamo l'oggetto LIME.
% X_Train serve a LIME per capire la distribuzione dei dati
explainer = lime(Best_Model, X_Train, ...
    'NumImportantPredictors', 10); 

%% 4. GENERAZIONE DELLA SPIEGAZIONE
% Chiediamo a LIME di spiegare la predizione per il nostro QueryPoint
fprintf('Calcolo spiegazione LIME...\n');
explanation = fit(explainer, QueryPoint);

%% 5. VISUALIZZAZIONE E SALVATAGGIO
fig = figure('Name', 'LIME Explanation', 'Color', 'w', 'Position', [100, 100, 1000, 600]);

% Plot nativo di LIME
plot(explanation);

title(sprintf('LIME: Perché il volo #%d è stato classificato "%s"?', queryIdx, string(PredLabel)));
xlabel('Contributo alla decisione (Importanza)');

% Salvataggio
imgFile = fullfile(explainPath, sprintf('LIME_Explanation_Flight_%d.png', queryIdx));
saveas(fig, imgFile);
fprintf('Grafico LIME salvato in: %s\n', imgFile);

%% 6. REPORT TESTUALE
txtFile = fullfile(explainPath, sprintf('LIME_Report_Flight_%d.txt', queryIdx));
fid = fopen(txtFile, 'w');

fprintf(fid, '=== REPORT LIME PER IL VOLO #%d ===\n', queryIdx);
fprintf(fid, 'Classe Reale: %s | Predetta: %s\n\n', string(RealLabel), string(PredLabel));
fprintf(fid, 'FEATURE CHE HANNO SPINTO VERSO LA CLASSE PREDETTA:\n');
fprintf(fid, '(Le barre nel grafico indicano peso e direzione del contributo)\n\n');

% Visualizziamo i risultati grezzi a video e nel file se possibile
disp(explanation); 

fclose(fid);
fprintf('Report salvato in: %s\n', txtFile);