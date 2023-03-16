function [N_Par, ParameterNames_adj, LotNames, N_Combi, ...
    ParValues_AllParAllCombisAllLots, ...
    GLF_AllParAllCombisAllLots]...
    = AAOS_GLUE_PrepareGraphicalOutputBoxchartHeatmap(...
    AnalysisOut, N_Lots, N_AllSim, idcsBHS_AllVar_AllLots, Config, ...
    TargetVarNameShort, N_Var_User, GLF_AllSim_AllVarAllLots)

LotNames = "Lot"+Config.SimulationLots;
ParValues_AllSim_AllParAllLots = [];
GLF_AllSim_AllParAllLots = [];

%   % Create 1 single array containing GLF values and BHS indices
%     % from all plots and for all analyzed variables:
% idcsBHS_AllVar_AllLots = reshape(permute(idcsBHS_AllVar_AllLots,[1 3 2]),...
%     [],size(idcsBHS_AllVar_AllLots,2),1);
GLF_AllLots = reshape(permute(GLF_AllSim_AllVarAllLots,[1 3 2]),...
     [],size(GLF_AllSim_AllVarAllLots,2),1);
% % Set up graphical output array & fill it with target variable
% % values (test variable values: see loop below):
% idcsBHS = idcsBHS_AllVar_AllLots(:,1);
% GLF = GLF_AllLots;

% fprintf(1,"... generating parameter value distribution graph" + ...
%     "for '%s'...\n",Name);


for LotIdx = 1:N_Lots

    [~,LotNameFull] = AAOS_GetLotNumberAndName(Config, LotIdx);
    LotAnalysisOut = AnalysisOut.(LotNameFull);

 % Retrieve parameter names & transform certain signs to avoid legend auto-formatting:
    ParameterNames_orig = LotAnalysisOut.ParameterNames;
    ParameterNames_adj1 = replace(ParameterNames_orig,"_","-");
    ParameterNames_adj = replace(ParameterNames_adj1,"0","o");

    % Get number of parameters:
    N_Par = size(ParameterNames_orig,1);


    % Determine behavioural (BS)/ non-behavioural (NBS) simulations for every
    % possible variable combination:
    % 1 analyzed variable -> 1 combination (Var1) = BHS
    % 2 analyzed variables -> 3 combinations (Var1:Var2) = BS:BS / BS:NBS / NBS:BS
    % 3 analyzed variables -> 6 combinations (Var1:Var2:Var3) = ...
    % BS:NBS:NBS / NBS:BS:NBS / BS:BS:NBS / NBS:BS:BS / BS:NBS:BS / NBS:NBS:BS
    % / BS:BS:BS
    VarIdcsAll = {1; 2; [1 2]; [2 3]; [1 3]; 3; [1 2 3]};
    N_Combi = 2^(N_Var_User) - 1;


    idcsBHS_AllVar = idcsBHS_AllVar_AllLots(:,:,LotIdx);
    GLF_AllSim_AllVar = GLF_AllSim_AllVarAllLots(:,:,LotIdx);
    ParValues_AllSim_AllPar = LotAnalysisOut.SamplingOut.Values(6:end, 1:N_Par);
    
    
    

    ParValues_BHS_AllParAllCombis = {};
    GLF_AllParAllCombis = {};

    MED_AllLots = {};
    MX_AllLots = {};

VarNamesAll = [TargetVarNameShort, "CC", "SWC"];

    for idx_Combi = 1 : N_Combi
        VarIdcs = VarIdcsAll{idx_Combi};

VarNamesCombi0 = join(VarNamesAll(VarIdcs));
VarNamesCombi = replace(VarNamesCombi0," ","_");

% Extract behavioural parameter values for current variable combination:
        idcsBHS_combi = all(idcsBHS_AllVar(:,[VarIdcs])==1, 2);
        ParValues_BHS_AllPar_Current = ParValues_AllSim_AllPar(idcsBHS_combi==1, :);

        % Extract the decisive GLF values for current variable combination
        % (= the one indicating worst model performance = the largest one)
        GLF_BHS_AllPar_Current = max(GLF_AllSim_AllVar(:, VarIdcs), [], 2);

        if isempty(ParValues_BHS_AllPar_Current)
            ParValues_BHS_AllPar_Current(1, 1:N_Par) = -999;
        end

        ParValues_BHS_AllParAllCombis.(VarNamesCombi) = ParValues_BHS_AllPar_Current;
        GLF_AllParAllCombis.(VarNamesCombi) = GLF_BHS_AllPar_Current;

        %% Determine & store median ("MED") and mean ("MX") for all combinations & lots:
        MED = median(ParValues_BHS_AllPar_Current(:,:),'omitnan');
        MX = mean(ParValues_BHS_AllPar_Current(:,:),'omitnan');
        MODE = mode(ParValues_BHS_AllPar_Current(:,:));
        MED_AllLots{idx_Combi}(1,:) = MED;
        MX_AllLots{idx_Combi}(1,:) = MX;
        MODE_AllLots{idx_Combi}(1,:) = MODE;
        
    end

    % Merge all simulations from all lots (-> "Default" boxplot)
    N_columns = size(ParValues_AllSim_AllPar, 2);
    lastrow = size(ParValues_AllSim_AllParAllLots, 1);
    % Merge simulated parameter values:
    ParValues_AllSim_AllParAllLots(lastrow+1 : lastrow+N_AllSim, 1: N_columns)...
        = ParValues_AllSim_AllPar;

    % Store behavioural simulation output: #1 parameter values, #2 GLF...
    % (for all variable combinations, and the current lot):
    ParValues_AllParAllCombisAllLots.(LotNameFull) =...
        ParValues_BHS_AllParAllCombis; % #1 Parameter values
    GLF_AllParAllCombisAllLots.(LotNameFull) =...
        GLF_AllParAllCombis; % #2 GLF

end

ParValues_AllParAllCombisAllLots.AllSimulations = ParValues_AllSim_AllParAllLots;