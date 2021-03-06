%% REVISE: GRAPHICAL OUTPUT FUNCTIONS
%% Calculate GoFs for all observation values together, and plot & write figures
function AnalysisOut = AAOS_Finalize(Directory,Config,AnalysisOut)


%% MOVE to Config
colors = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980];...
    [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330];...
    [0.6350 0.0780 0.1840]]; % blue/orange/yellow/purple/green/cyan/red; see...
% https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html



% Derive name of output file:
FileName = AAOS_DeriveOutputFileName(Config, Directory);



switch Config.RUN_type
    case {"EE","GLUE"}
        LotNames = Config.SimulationLots;
                for LotIdx = 1 %1:numel(LotNames)
                    ObsValuesAndDays = Config.TargetVar.Observations(:,2:3);
                    LotName = LotNames(LotIdx);
                    [~,row_Lot] = ismember(Config.LotName,ObsValuesAndDays(:,1));
                    if row_Lot == 0
                        fprintf(2,'No Harvested ' + Config.TargetVar.NameFull +...
                            ' value available for lot #'+Config.LotIdx+'.\nSwitching to next lot.\n');
                    else
                        % Assign parameter file name as sheet name
                        LotNameFull = "Lot" + LotName;
                        LotAnalysisOut = AnalysisOut.(LotNameFull);
        
                        AAOS_SAFE_WriteNumericalOutput(Config, Directory, FileName, LotAnalysisOut, LotNameFull);
        
                        %% GRAPHICAL OUTPUT: REVISE
%                         if Config.RUN_type == "EE"
%                             cd(Directory.BASE_PATH)
%                             AAOS_EE_PlotAndWriteGraphicalOutput(Config, Directory, FileName, LotAnalysisOut, LotIdx, LotNameFull);
%                         elseif Config.RUN_type == "GLUE"
%                             AAOS_GLUE_PlotAndWriteGraphicalOutputTimeSeries...
%                                 (Config, Directory, FileName, LotAnalysisOut, LotIdx, LotNameFull, colors)
%                         end
                    end
                end

                %% GRAPHICAL OUTPUT: REVISE
%                 if Config.RUN_type == "GLUE"
% 
%                     InclText = 0;
% 
%                     HandleBadLot = -999;
%                     HandleBadSim = 0;
%                     AAOS_GLUE_PlotAndWriteGraphicalOutputStatistics...
%                         (Config, Directory, FileName, AnalysisOut, LotNames, colors,HandleBadLot,HandleBadSim, InclText)
%                     InclText = 1;
%                     HandleBadLot = 1;
%                     HandleBadSim = 1;
%                     AAOS_GLUE_PlotAndWriteGraphicalOutputStatistics...
%                         (Config, Directory, FileName, AnalysisOut, LotNames, colors,HandleBadLot,HandleBadSim, InclText)
% 
%                     HandleBadLot = 0;
%                     HandleBadSim = 0;
%                     InclText = 0;
%                     AAOS_GLUE_PlotAndWriteGraphicalOutputStatistics...
%                         (Config, Directory, FileName, AnalysisOut, LotNames, colors,HandleBadLot,HandleBadSim, InclText)
%                     InclText = 1;
%                     AAOS_GLUE_PlotAndWriteGraphicalOutputStatistics...
%                         (Config, Directory, FileName, AnalysisOut, LotNames, colors,HandleBadLot,HandleBadSim, InclText)
%                     HandleBadLot = 0;
%                     HandleBadSim = 1;
%                     AAOS_GLUE_PlotAndWriteGraphicalOutputStatistics...
%                         (Config, Directory, FileName, AnalysisOut, LotNames, colors,HandleBadLot,HandleBadSim, InclText)
%                     HandleBadLot = 2;
%                     HandleBadSim = 0;
%                     AAOS_GLUE_PlotAndWriteGraphicalOutputStatistics...
%                         (Config, Directory, FileName, AnalysisOut, LotNames, colors,HandleBadLot,HandleBadSim, InclText)
%                     HandleBadLot = 1;
%                     HandleBadSim = 0;
%                     AAOS_GLUE_PlotAndWriteGraphicalOutputStatistics...
%                         (Config, Directory, FileName, AnalysisOut, LotNames, colors,HandleBadLot,HandleBadSim, InclText)
% 
% 
%                 end

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

        % Write numerical outputs to spreadsheet:
        AAOS_ModelEval_WriteNumericalOutput(Directory,Config,FileName,AnalysisOut);

        %% Plot figures and, in case, write them to the Excel file:
        % For every lot, plot one figure per used test variable CC and SWC, while
        % plotting the results from the 3. test variable (HI) within those figures:
        for idx_TestVar = 1:min(2,max(Config.TestVarIds))
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
