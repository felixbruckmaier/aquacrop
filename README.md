# Automated AquaCrop-OpenSource (AAOS) User Manual
## Author: Felix Bruckmaier
## Date: 23.03.2022


# Functionalities
* ***Provided by the current version:***
	* Automated model setup and simulation for:
		* different seasons and lots/ observation
		* 1 of 2 target variables (Harvested Biomass/ Harvested Yield),
		* up to 2 test variable timeseries (Canopy Cover/ Soil Water Content),
		* up to 2 different parameter value sets (Default/ Calibrated),
		* up to 3 different calibration rounds (according to the AquaCrop calibration guidelines).
		* Now possible for: season = 2019, lot = 1, 1 parameter values set ('Default'), test variable = CanopyCover, target variable = Yield).
		* NOTE: This tool does not offer automated calibration; the user is required
to provide input files with both default, and calibrated parameter values.

* ***Coming soon:***
	* Validation of the calibrated model through the 'Validation Set Approach';
	* Quantification of water, aeration, heat, and cold stresses;
	* Parameter sensitivity analysis (link to SAFE toolbox);
	* Uncertainty analysis via the 'GLUE method' (link to SAFE toolbox);
	* Output file creation incl. graphical evaluation for every provided feature;
	* App feature for non-Matlab users.


# Get started
1. Download AquaCrop-OS v.6.0 and copy it into folder "AAOS/vendor/"
2. Specify input data:
	1. AOS .txt files in folder "AAOS/vendor/Input/"
	2. AAOS .csv files in folder "AAOS/AAOS_Input/"
3. Specify config: "default.m" and "season_x.m" in folder "AAOS/config/"
4. Execute "RUN_AAOS.m" in folder "AAOS/AAOS_Output/"