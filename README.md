# Automated AquaCrop-OpenSource (AAOS) User Manual
## Author: Felix Bruckmaier
## Date: 23.03.2022


# AAOS functionalities

* Provided by the current version:
	* Automated model setup and simulation for several lots and seasons,
for up to 2 test variable timeseries (Canopy Cover/ Soil Water Content),
and 2 target variables (Harvested Biomass/ Harvested Yield), 2 different
parameter value sets (Default/ Calibrated), and up to 3 different
calibration rounds (according to the AquaCrop calibration guidelines)
		* Now possible for: season = 2019, lot = 1, test variable = CanopyCover, target variable = Yield)
		* NOTE: The tool does NOT offer automated calibration; the user is required
to provide input files with both default, and calibrated parameter values.

* Coming soon:
		* Validation of the calibrated model through the 'Validation Set Approach';
		* Quantification of water, aeration, heat, and cold stresses;
		* Parameter sensitivity analysis (link to SAFE toolbox);
		* Uncertainty analysis via the 'GLUE method' (link to SAFE toolbox);
		* Output file creation incl. graphical evaluation for every feature;
		* App feature for non-Matlab users.


# Get started:

	* 1. Download AquaCrop-OS v.6.0 and copy it into folder "AAOS/vendor/"
	* 2. Specify input data:
		* a) AOS .txt files in folder "AAOS/vendor/Input/"
		* b) AAOS .csv files in folder "AAOS/AAOS_Input/"
	* 3. Specify config: "default.m" and "season_x" in folder "AAOS/config/"
	* 4. Execute "RUN_AAOS.m" in folder "AAOS/AAOS_Output/"