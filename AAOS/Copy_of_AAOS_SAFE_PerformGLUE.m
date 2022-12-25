function [Config, LotAnalysisOut] = AAOS_SAFE_PerformGLUE(Config, Directory, LotAnalysisOut)

SamplingOut = LotAnalysisOut.SamplingOut;
LotAnalysisOut.Values = SamplingOut.Values;
LotAnalysisOut.ColumnTitles = SamplingOut.ColumnTitles;
% Remove underscore sign from parameter names (plot function forces characters into lowercase)
ParameterNames = cellstr(replace(string(SamplingOut.ParameterNames),'_','-'));
N_Pars = size(ParameterNames,1);
SimOut = SamplingOut.Values;



ObsValuesAndDays = Config.TargetVar.Observations(:,2:3);
[~,row_Lot] = ismember(Config.LotName,ObsValuesAndDays(:,1));
HarvestDay = Config.TargetVar.Observations(row_Lot,1);
if row_Lot == 0

    fprintf(2,'No Harvested ' + Config.TargetVar.NameFull +...
        ' value available for lot #'+Config.LotIdx+'.\nSwitching to next lot.\n');

else
    TargetVarObs = ObsValuesAndDays(row_Lot,2);
    if Config.TargetVar.NameFull == "Biomass"
        idxTargetVar = 1;
    elseif Config.TargetVar.NameFull == "Yield"
        idxTargetVar = 3;
    end
    TargetVarSim = SimOut(6:end, N_Pars + idxTargetVar);
    BiomassLoss = SimOut(6:end, N_Pars + 2);

    % Calculate biomass/yield ARE:
    GLF_TargetVar = abs((TargetVarSim - TargetVarObs) / TargetVarObs) * 100;
    thresh_TargetVar = Config.thresh_TargetVar;





    cd(Directory.BASE_PATH);

    %% Store GLF results & Output Titles for Target Variable:
    VariableTitles(1:3) = ["Biomass [t/ha]", "Biomass Loss [t/ha]", "Yield [t/ha]"];
    GLF_Titles(1) = "Deviation_of_" + Config.TargetVar.NameShort + "[%]";
    GLFs(:,1) = GLF_TargetVar;
    PredictLimits = nan(4,1);
    VarSize = 3; % 3 columns for biomass & biomass loss & yield

    if any(~isnan(SamplingOut.TestVariableSizes(:,2)))
        TestVars = SamplingOut.TestVariableSizes(:,1);
        TestVarSizes = SamplingOut.TestVariableSizes(:,2);

        AvailTestVars = TestVars(~isnan(TestVarSizes));
        AvailTestVarSizes = TestVarSizes(~isnan(TestVarSizes));

        % Determine user-defined test variables:
        for TestVarIdx = 1:numel(AvailTestVars)

            TestVar = AvailTestVars(TestVarIdx);
            % Determine test variable:
            [TestVarNameFull,TestVarNameShort] = AAOS_SwitchTestVariable(TestVar);

            % Assign SWC depth to be tested (set to "1" when analyzing Canopy Cover):
            % -> column idx
            if TestVarNameShort == "SWC"
                idx_Observation = 1; %Config.idx_SimDepthsObservations(Config.idx_TestSWC);
            elseif TestVarNameShort == "CC"
                idx_Observation = 1;
            end


            % Read observed values for given test variable & depth:
            [TestVarObsAndDays,~] = AAOS_ReadTestVariableObservationsFile(Directory,Config,...
                TestVarNameShort,idx_Observation);

            TestVarDays = TestVarObsAndDays(:,1);
            TestVarObs = TestVarObsAndDays(:,2)';
            TestVarLength = AvailTestVarSizes(TestVarIdx); % size(TestVarObs,1);
            if TestVarIdx == 1
                startpoint = N_Pars + 4;
            elseif TestVarIdx == 2
                startpoint = N_Pars + 4 + TestVarSizes(TestVarIdx-1);
            end
            endpoint = N_Pars + 3 + sum(TestVarSizes(1:max(1,TestVarIdx)));
            TestVarSim = SimOut(6:end, startpoint : endpoint);

            %%TEMP:
            if TestVarIdx == 2
                AvailTestVarSizes(TestVarIdx) = size(TestVarObsAndDays,1);
                TestVarLength = AvailTestVarSizes(TestVarIdx);
                TestVarSim = SimOut(6:end, startpoint - 14 + TestVarObsAndDays(:,1));
            end

            TestVarSim(TestVarSim == -999) = 0;
            SampleLength = size(TestVarSim,1);
            GLF_TestVar = nan(SampleLength, 1);

            cd(Directory.SAFE_util);
            %% Calculate the GLF from sim. & obs. values of test variable
            % Use NRMSE, normalized to the mean, according to Raes al. 2018:
            GLF_TestVar(:,1) = RMSE(TestVarSim,TestVarObs) / mean(TestVarObs) * 100;

            thresh_TestVar = Config.thresh_TestVar;
            cd(Directory.SAFE_GLUE);
            if any(GLF_TestVar>0)
                [ idx_GoodTest, Llim_TestFromTest, Ulim_TestFromTest ] =...
                    GLUE(GLF_TestVar,thresh_TestVar,TestVarSim) ;
            else
                idx_GoodTest = zeros(SampleLength,1);
                Llim_TestFromTest= nan(TestVarLength,1);
                Ulim_TestFromTest = nan(TestVarLength,1);
            end

            %             if any(GLF_TargetVar>0)
            [ idx_GoodTarget, Llim_TestFromTarget, Ulim_TestFromTarget ] =...
                GLUE(GLF_TargetVar,thresh_TargetVar,TestVarSim) ;
            %             else
            %                 idx_GoodTarget = zeros(SampleLength,1);
            %                 Llim_TestFromTarget = nan(TestVarLength,1);
            %                 Ulim_TestFromTarget= nan(TestVarLength,1);
            %             end
            cd(Directory.BASE_PATH);

            %% Store Test Variables Output Titles & GLF results & Prediction Limits:
            VariableTitles(end+1 : end+TestVarLength) = TestVarNameShort;
            GLF_Titles(1 + TestVarIdx) = "GLF_on_" + TestVarNameShort + "[-]";
            GLFs(:,1 + TestVarIdx) = GLF_TestVar;
            PredictLimits(:, end+1:end+TestVarLength) =...
                [Llim_TestFromTest';Ulim_TestFromTest';Llim_TestFromTarget';Ulim_TestFromTarget'];

            LotAnalysisOut.GLUE_Out.(TestVarNameFull).idx_GoodTest = idx_GoodTest;
            LotAnalysisOut.GLUE_Out.(TestVarNameFull).idx_GoodTarget = idx_GoodTarget;
            LotAnalysisOut.GLUE_Out.(TestVarNameFull).Llim_TestFromTest = Llim_TestFromTest;
            LotAnalysisOut.GLUE_Out.(TestVarNameFull).Ulim_TestFromTest = Ulim_TestFromTest;
            LotAnalysisOut.GLUE_Out.(TestVarNameFull).Llim_TestFromTarget = Llim_TestFromTarget;
            LotAnalysisOut.GLUE_Out.(TestVarNameFull).Ulim_TestFromTarget = Ulim_TestFromTarget;
            LotAnalysisOut.GLUE_Out.(TestVarNameFull).TestVarDays = TestVarDays;
            LotAnalysisOut.GLUE_Out.(TestVarNameFull).TestVarSim = TestVarSim;
            LotAnalysisOut.GLUE_Out.(TestVarNameFull).TestVarObs = TestVarObs;
            LotAnalysisOut.GLUE_Out.(TestVarNameFull).GLF_TestVar = GLF_TestVar;






            VarSize = VarSize + sum(AvailTestVarSizes(TestVarIdx));
        end
        N_Vars = size(GLFs,2);
        %         % Re-convert target variable GLF output into original value: RMSE[%]
        %         GLFs(:,1) = -GLFs(:,1);


        cd(Directory.BASE_PATH);

        LotAnalysisOut.GLUE_Out.HarvestDay = HarvestDay;
        LotAnalysisOut.GLUE_Out.TargetVarSim = TargetVarSim;
        LotAnalysisOut.GLUE_Out.BiomassLoss = BiomassLoss;
        LotAnalysisOut.GLUE_Out.TargetVarObs = TargetVarObs;
        LotAnalysisOut.GLUE_Out.GLF_TargetVar = GLFs(:,1);
        LotAnalysisOut.GLUE_Out.AvailableTestVariableSizes = AvailTestVarSizes;
        LotAnalysisOut.GLUE_Out.AvailableTestVariables = AvailTestVars;
        LotAnalysisOut.GLUE_Out.Samples = SimOut(6:end, 1:N_Pars);

        LotAnalysisOut.TargetVar = Config.TargetVar;
        LotAnalysisOut.ParameterNames = ParameterNames;

        LotAnalysisOut.Values(1:end, end+1:end+N_Vars) = [nan(5,N_Vars); GLFs];
        LotAnalysisOut.Values(1:4, N_Pars + 3 : N_Pars + 3 + VarSize-3) =...
            PredictLimits; % VarSize contains also 3 columns for target var (losses)
        LotAnalysisOut.ColumnTitles(end+1 : end+VarSize) = cellstr(VariableTitles);
        LotAnalysisOut.ColumnTitles(end+1 : end+N_Vars) = cellstr(GLF_Titles);
    end
end