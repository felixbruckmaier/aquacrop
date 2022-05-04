%% Derives indices of a) EE parameters in AOS_SamplesRaw matrix, and
% b) converted EE parameters in both AOS_SamplesRaw and EE_Samples
%
%% USED NOMENCLATURE FOR PARAMETERS, UNITS, SAMPLES, SAMPLE VALIDITY, AND
% MATRICES DERIVED FROM ALL OF THE PREVIOUS:

% I. Types of parameters:
% I.1) "SAFE parameters": parameters sampled within (user-defined) input range
% -> to be printed to AOS input files AND analyzed by Morris method/ GLUE;
% I.2) "Fix parameters": parameters with (user-defined) fix value across all
% samples -> only to be printed to AOS input files
% I.3) "AOS parameters": I.1) & I.2)
%
% II. Types of units:
% II.1) "Input unit": (user-defined) parameter units, might be heterogeneous
% II.2) "Output unit": (user-defined) homogenous parameter unit used by AOS
% input files (Crop.txt etc.)
% II.3) "Converted unit": parameter units not given in II.2) and therefore
% converted
% 
% III. Validity:
% (No indication:) "All samples" 
% III.) "Valid samples": samples that meet AOS phenology constraints
%
% IV. Types of matrices:
% IV.1) Samples_AOS_In: I.3) + II.1)
% IV.2) Samples_AOS_Out: I.3) + II.2)
% IV.3) Samples_ValidAOS_Out: IV.2) + III)
% IV.3) Samples_ValidAOS_In: IV.2) + III)
% Samples_ValidConvert_In
% IV.4) Samples_SAFE_Input: I.1) + II.1)

% IV.5) Samples_SAFE_Output: I.1) + II.2)
%
% IV. Types of parameter indices/ matrix columns:
% IV.1) Col_Conv_SAFEinAOS: II.3) in IV.1)/2) in I.3)
% IV.2) Col_Conv_SAFEinSAFE: II.3) in IV.3)/4) in I.3)

function [Col_SAFEinAOS,Col_Conv_SAFEinAOS,Col_Conv_SAFEinSAFE]...
    = AAOS_SAFE_DeriveSamplesToAnalyze(Config,N_ParAll,FixedParCol)

%% a)  Derive indices of EE parameters (= values sampled within input range)
% in AOS_SamplesRaw matrix (= all parameters to be printed to AOS input files,
% = (sampled) EE parameters + parameters with fix value across all samples):
Col_AllPar = 1:N_ParAll;
Col_SAFEinAOS = setdiff(Col_AllPar,FixedParCol);
Col_AllSampled = 1:size(Col_SAFEinAOS,2);

%% b) Derive which parameters are not given in the unit to be printed in AOS
% output files (the original=input unit will be used for computing the
% elementary effects with the Morris method):
% b.1) Derive output unit & input units:
PhenoUnitAOS = string(Config.PhenoUnitAOS);
AllParUnits = string(Config.AllParameterUnits);
% b.2) Read all non-relevant units ("NR"), i.e., of parameters not part of the
% phenology unit conversion process (e.g., ksat, CCx, ...),  as equal to
% output units:
AllParUnits(AllParUnits == "NR") = PhenoUnitAOS;
SampledUnits = AllParUnits(Col_SAFEinAOS);
% b.3) Find index of converted parameters...
% - ... in matrix with sampled and fixed values:
Loc_Conv_inAOS = AllParUnits ~= PhenoUnitAOS;
Col_Conv_inAOS = Col_AllPar(Loc_Conv_inAOS == 1);
Col_Conv_SAFEinAOS = intersect(Col_Conv_inAOS,Col_SAFEinAOS);
% - ... in matrix with only sampled values:
Loc_Conv_SAFEinSAFE = SampledUnits ~= PhenoUnitAOS;
Col_Conv_SAFEinSAFE = Col_AllSampled(Loc_Conv_SAFEinSAFE == 1);