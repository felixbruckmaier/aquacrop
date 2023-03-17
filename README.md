# Automated AquaCrop-OpenSource (AAOS) tool
GLUE and Matlab-based tool to evaluate model errors for large samples of AquaCrop-OS (AOS) input parameter combinations.

## Table of Contents
- [Introduction](#introduction)
- [Technologies](#technologies)
- [Setup](#setup)
- [Acknowledgments](#acknowledgments)

## Introduction
This tool is supposed to support AOS model calibration for data-scarce regions. It enables the analysis of AOS model performance for a potentially large number of model input parameter combinations with regard to different model variables (biomass or yield at harvest and/or canopy cover and/or soil water content).

## Technologies
- MATLAB R2022a
- AquaCrop-OpenSource (AOS) v.6.0a
- Sensitivity For Everybody (SAFE) toolbox v.1.1
- Microsoft Excel (optional)

## Setup
1. Download AAOS
2. Download & unzip AOS and copy the entire folder to the folder: "..\AAOS\vendor"
3. Download & unzip SAFE and copy the entire folder to the folder: "..\AAOS\vendor"
4. Download xlswritefig.m and copy the entire folder to the folder: "..\AAOS\vendor" (optional: to write MATLAB figures to a Microsoft Excel spreadsheet)
5. Adjust code in "..\safe_R1.1\GLUE" to account for the case where all simulations are non-behavioral according to SAFE terminology.
- Replace the code in line 125 ("Llim(t) = y_sorted(1);") with the following snippet:
if any(idx==1)
    Llim(t) = y_sorted(1);
else
    Llim(t) = nan;
end
- Replace the code in line 132 ("Ulim(t) = y_sorted(end);") with the following snippet:
if any(idx==1)
    Ulim(t) = y_sorted(end);
else
    Ulim(t) = nan;
end
6. Follow the steps listed in the [AAOS-v1.0_Instruction-Manual.pdf](/AAOS-v1.0_Instruction-Manual.pdf) file, to run the tool.

## Acknowledgements
- AOS tool: Foster, T., Brozović, N., Butler, A., Neale, C., Raes, D., Steduto, P., Fereres, E. and Hsiao, T. (2017), ‘AquaCrop-OS: An open source version of FAO’s crop water productivity model’, Agricultural Water Management 181, 18–22.
Available at: https://www.sciencedirect.com/science/article/pii/S0378377416304589
- SAFE toolbox: Pianosi, F., Sarrazin, F. and Wagener, T. (2015), ‘A matlab toolbox for global sensitivity analysis’, Environmental Modelling Software 70, 80–85.
Available at: https://www.sciencedirect.com/science/article/pii/S1364815215001188
- xlswritefig.m: Michelle Hirsch (2022). xlswritefig (https://github.com/michellehirsch/xlswritefig), GitHub. Retrieved December 8, 2022. 