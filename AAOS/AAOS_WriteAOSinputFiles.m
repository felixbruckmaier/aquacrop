%% Writes all user-specified parameter input values in AOS input files
function [] = AAOS_WriteAOSinputFiles(Directory,Config)



TestParAOSFile = string(Config.TestParameterAOSFile);
TestParNames = string(Config.TestParameterNames);
TestParValues = string(Config.AllParameterValues(Config.TestParameterIdx));
[TestParAOSFile,sortIdx] = sort(TestParAOSFile,'ascend');
TestParNames = TestParNames(sortIdx);
TestParValues = TestParValues(sortIdx);
FileNameOld = strings(1);

for idx = 1:size(TestParNames,1)
    VarName = TestParNames(idx);
    VarValue = TestParValues(idx);
    FileNameNew = TestParAOSFile(idx);
    if FileNameNew == FileNameOld
        OmitTemplate = 1;
    else
        OmitTemplate = 0;
    end
    [FileNameOld] = AAOS_OverwriteVariableInAOSfile(Config, Directory, ...
    FileNameNew, OmitTemplate, VarName, VarValue);
end
