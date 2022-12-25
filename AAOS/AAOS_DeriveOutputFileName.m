function FileName = AAOS_DeriveOutputFileName(Config, Directory)

% Derive filename:
% ... from current timestamp (to avoid output file conflicts):
currentday_full = clock;
currentday = strcat(string(currentday_full(:,1)),"-",string(currentday_full(:,2)),"-",string(currentday_full(:,3))...
    ,"_",string(currentday_full(:,4)),"-",string(currentday_full(:,5)));
FileName = strcat(currentday,"_");
% ... season, analysis type:
FileName = strcat(FileName,"S",Config.season,"_",Config.RUN_type,"_");

if Config.RUN_type == "SA"
    FileName = strcat(FileName,"Morris_on_"+Config.TargetVar.NameFull);

else
    %% Enable for CAL analysis:
%     if Config.CalcMean == 1
%         FileName = strcat(FileName,"MEAN_");
%     end
    
% ...test & target variable(s) and GoFs:
    % - Create string with all test variables:
    TestVarNamesShortArr = strings(2,1);
    TestVarNamesShortStr = "";
    for idx_TestVar = Config.TestVarIds
        [~,TestVarNameShort] = AAOS_SwitchTestVariable(idx_TestVar);
        TestVarNamesShortArr(idx_TestVar,1) = TestVarNameShort;
        TestVarNamesShortStr = strcat(TestVarNamesShortStr,"_",TestVarNameShort);
    end

    GoF_NamesStr = "";
    if Config.RUN_type ~= "GLUE"
        % - Create string with all calculated GoFs:
        GoF_NamesArr = strings(3,1);
        for idx = 1:length(Config.GoF)
            GoF_NamesArr(idx) = Config.GoF(idx);
            GoF_NamesStr = strcat("_via",GoF_NamesStr);
        end
        GoF_NamesStr = strcat(GoF_NamesStr,"_",GoF_NamesArr(idx));
    end

    % - Assign all elements to filename:
    if Config.RUN_type ~= "STQ"
        FileName = strcat(FileName,"of",TestVarNamesShortStr,"_on_",Config.TargetVar.NameShort,GoF_NamesStr);
    end
end
% Determine final filename & add extension:
FileName = char(strcat(...
    Directory.AAOS_Output,filesep,FileName,Config.filename_xtra,".xlsx"));