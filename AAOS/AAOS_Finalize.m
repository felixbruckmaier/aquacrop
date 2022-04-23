%% Calculate GoFs for all observation values together, and plot & write figures
function ModelOut = AAOS_Finalize(Directory,Config,ModelOut)

% Delete all rows that only contain either zero or NaN values:
ModelEval = ModelOut.ModelEvaluation(:,2:end);
[rows,cols] = find(all(or(isnan(ModelEval),ModelEval==0),2));
ModelOut.ModelEvaluation(rows,:,:,:) = [];
ModelOut.SimulationOutput(rows,:,:,:) = [];

% Calculate GoFs for all-plot timeseries, if >1 lots are tested:
if numel(Config.SimulationLots) > 1
    ModelOut = AAOS_CalculateGoFsOverall(Config,ModelOut);
end

% try extrainput.SimMaturity(rows,:)
%     extrainput.SimMaturity(rows,:) = [];
% end
% extrainput.ObsHarvest(rows) = [];

% Write numerical outputs to spreadsheet:
[OutputDirectoryFilename] = AAOS_WriteModelEvaluation...
    (Directory,Config,ModelOut);

%% Plot figures and, in case, write them to the Excel file:
% For every lot, plot one figure per used test variable CC and SWC, while
% plotting the results from the 3. test variable (HI) within those figures:
for idx_TestVar = 1:min(2,max(Config.TestVarIds))
    % Only plot figures for lots with observations for this test variable:
    if not(isempty(ModelOut.SimulationOutput(1,1,1,idx_TestVar)))
        % REVISE FUNCTION:
%         AAOS_PlotFigModelPerformance(Directory,OutputDirectoryFilename,...
%             Config,ModelOut,idx_TestVar);
    end
end


fclose ('all'); % Close open files
if Config.WriteFig == 'Y'; actxserver('Excel.Application').Quit; end
