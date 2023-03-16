%% Calculate GoFs for all observation values together, and plot & write figures
function AnalysisOut = AAOS_Finalize(Directory,Config,AnalysisOut)

%% Get output file name:
FileName = AAOS_DeriveOutputFileName(Config, Directory);

switch Config.RUN_type % Determine user-defined analysis type:

    %% Options 'EE' & 'GLUE':
    case {"EE"; "GLUE"}

        %% In case, write numerical outputs to Excel spreadsheet (EE or GLUE analysis):
        if Config.WriteNum == "Y"
            AAOS_SAFE_WriteNumericalOutput(Config, Directory, FileName, AnalysisOut)
        end


        %% In case, create graphical output for either EE or GLUE analysis:
        % EE:
        if any(contains(Config.PlotGraphs,["EE"]))
            %% REVISE EE FUNCTION:
            %         AAOS_EE_PlotAndWriteGraphicalOutput(Config, Directory, FileName, AnalysisOut);

            % GLUE:
        elseif any(contains(Config.PlotGraphs, Config.GLUE_ChartNames.NonTimeSeriesCharts))
            AAOS_GLUE_PlotAndWriteGraphicalOutput(Config, Directory, ...
                AnalysisOut);
        end


        %% REVISE -> according to SAFE functions
    case {"DEF", "CAL"}
        % Delete all rows that only contain either zero or NaN values:
        ModelEval = AnalysisOut.ModelEvaluation(:,2:end);
        [rows,cols] = find(all(or(isnan(ModelEval),ModelEval==0),2));
        AnalysisOut.ModelEvaluation(rows,:,:,:) = [];
        AnalysisOut.SimulationOutput(rows,:,:,:) = [];

        % Calculate GoFs for all-plot timeseries, if >1 lots are tested:
        if numel(Config.SimulationLots) > 1
            AnalysisOut = AAOS_ModelEval_CalculateGoFsOverall(Config,AnalysisOut);
        end

        % In case, write numerical outputs to Excel spreadsheet:
        if Config.WriteNum == "Y"
            AAOS_ModelEval_WriteNumericalOutput(Directory,Config,FileName,AnalysisOut);
        end


        %% Plot figures and, in case, write them to the Excel file:
        % For every lot, plot one figure per used test variable CC and SWC, while
        % plotting the results from the 3. test variable (HI) within those figures:
        for idx_TestVar = 1:min(2,max(TestVarIds))
            % Only plot figures for lots with observations for this test variable:
            if not(isempty(AnalysisOut.SimulationOutput(1,1,1,idx_TestVar)))
                %% GRAPHICAL OUTPUT: REVISE
                %         AAOS_ModelEval_PlotFigure(Directory,FileName,...
                %             Config,ModelOut,idx_TestVar);
            end
        end
end


fclose ('all'); % Close open files
if Config.WriteFig == 'Y'; actxserver('Excel.Application').Quit; end
