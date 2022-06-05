function [Config, LotAnalysisOut] = AAOS_PerformSAFE(Config, Directory, LotAnalysisOut, LotNameFull)





%% Derive name for struct (used for analysis) & .mat file (either opened or written)
% for the current lot, containing names & ranges of sampled parameters,
% and all (valid) samples, each of which incl. values of input parameters &
% simulated output variables (always: Yield or Biomass; if available: Canopy
% Cover and/ or Soil Water Content):



% Derive name of file to store the derived samples (Option 1, see below), or
% to be opened (Option 2):
SamplingOut_FileNameFull = strcat(Config.SamplingOut_FileNamePrefix,"_",LotNameFull);
%% TEMP:
SamplingOut_FileNameFull = strcat(Config.SamplingOut_FileNamePrefix, "Season",Config.season);





if Config.CreateNewSamples == 1



    [Config,SamplingOut] =...
        AAOS_SAFE_DeriveValidSamples(Directory,Config);
    cd(Directory.AAOS_Output);
    save(SamplingOut_FileNameFull, "SamplingOut");
    LotAnalysisOut.SamplingOut = SamplingOut;
    cd(Directory.BASE_PATH);


elseif Config.CreateNewSamples == 0
    % Option to test existing .mat output files, i.e. skipping the entire
    % sampling/model evaluation process:
    %     [Config, AnalysisOut] = AAOS_SAFE_TEST_BypassSamplingAndEval(Config, Directory, AnalysisOut);
    %     AnalysisOut.("Lot"+Config.LotName).ObsTestVar = ObsTestVarTemp;
    cd(Directory.AAOS_Output);
    LotAnalysisOut.SamplingOut = importdata(SamplingOut_FileNameFull+".mat");
    cd(Directory.BASE_PATH);

end



if Config.RUN_type == "GLUE"
    %% (MOVE TO Initialize.m:) Define row titles for GLUE:
%     LotAnalysisOut.RowTitles(1,1) = ["INPUT VALUES"];
    LotAnalysisOut.RowTitles(1:2,1) = ["Lower limit","Upper limit"];
    LotAnalysisOut.RowTitles(6,1) = ["Samples"];
%     LotAnalysisOut.RowTitles(rows_Samp,1) = 1:n_new;
    [Config, LotAnalysisOut] = AAOS_SAFE_PerformGLUE(Config, Directory, LotAnalysisOut);
elseif Config.RUN_type == "EE"
    [Config, LotAnalysisOut] = AAOS_SAFE_PerformEE(Config, Directory, LotAnalysisOut);
end

