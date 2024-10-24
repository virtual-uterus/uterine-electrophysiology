# Uterine electrophysiology
This repository contains tools to analyse uterine electrophysiological data recorded using [BioSemi](https://www.biosemi.com/) devices and processed with [GEMS](https://link.springer.com/article/10.1186/1471-230X-12-60).
# Table of contents
1. [Requirements](#requirements)
2. [Data folder structure](#structure)
3. [Usage](#usage)
	1. [Configuration files](#config)
	2. [Analysis structures](#as)
	3. [Individual experiment processing](#individual)
	4. [Estrus phase processing](#estrus)
	5. [Statistics and export for R](#stats)
 

<a id="requirements"></a>
## Requirements
The code was developed in [MATLAB](https://www.mathworks.com/products/matlab.html) version 2022a and requires the MATLAB **Image Processing Toolbox** and **Signal Processing Toolbox** packages. The configuration files are written in [TOML](https://toml.io/en/) and require the [MATLAB implementation of TOML](https://github.com/g-s-k/matlab-toml). Statistical analysis is performed in [R](https://www.r-project.org/?2827) version 4.4.1. 

<a id="structure"></a>
## Data folder structure
The folders containing the data are structured as follows:
```bash
data
├── AWA026
│   └── mat
│       ├── AWA026_run_X_G7x2_marked.mat
│       ├── AWA026_config.toml
├── AWB001
│   └── mat
│       ├── AWB001_run_X_G7x2_marked.mat
│       ├── AWB001_config.toml
└── estrus_config.toml
```
Examples of the different configuration files can be found in the config folder and a list of the fields is given in the [Configuration files](#config) section.

The naming convention for the .mat files is EXPT_run_X_G7x2_marked.mat, where EXPT is the name of the folder and X is the run number. For the individual experiment configuration files, the naming convention is EXPT_config.toml, where EXPT is the name of the folder. 

All experiment folders must contain a mat folder which contains a configuration file and a .mat file. The estrus_config.toml file must be located in the data folder. 
 
<a id="usage"></a>
## Usage
The analysis process requires that the data be marked in [GEMS](https://link.springer.com/article/10.1186/1471-230X-12-60) because the analysis depends on the timestamps and wave numbers provided in the annotated .mat files. 

**NOTE:** The baseDir() and base_dir() functions located in the code/utils folder and code/stats/utils.R script respectively, produce the start of the path to the data directory. They are currently set to $HOME/Documents/phd and need to be changed to fit your setup before running the code. 
 
<a id="config"></a>
### Configuration files
There are two different configuration files: the individual experiment configuration files, which are located in the mat folders of each experiment, and the global estrus configuration file, located in the data folder. 

The individual experiment configuration files contains the following fields:
 - run_nb, the run number is the value of X in the names of the mat files shown in the [data folder structure](#structure). If several experimental runs are annotated, this allows to switch from one to another.
 - transition, this is a binary value indicating if the animal was transitioning from one stage of the estrus cycle to another. 1 is true, and 0 is false.
 - start_time, this value marks the beginning of the analysis window for the experiment. This value is in seconds.
 - end_time, this value marks the end of the analysis window for the experiment. This value is in seconds.
 - win_size, the size of the observation window around the timestamps of the marked events. This value is in seconds.
 - win_split, the percentage of signal covered by the window before the timestamp. This value is between 0 and 1. At 0, the window selects win_size seconds after the timestamp, at 1, the window selects win_size seconds before the timestamps, at 0.5 the window is centred around the timestamp.
 - lowpass_cutoff_freq, the cutoff frequency of the low-pass filter which extracts the slow-wave component from the signal. This can be a single value or a vector (_i.e._ [_f0_, _f1_], with _f0_ < _f1_) for a bandpass filter. The value are in Hz.
 - highpass_cutoff_freq, the cutoff frequency of the high-pass filter which extracts the fast-wave component from the signal. This can be a single value or a vector (_i.e._ [_f0_, _f1_], with _f0_ < _f1_) for a bandpass filter. The value are in Hz.
 - min_nb_chns, the minimal number of channels in which the event should appear for it to be analysed.
 
The global configuration file contains the following fields:
- [phases]
    - proestrus, list of experiment that are in the proestrus phase.
    - estrus, list of experiment that are in the estrus phase. 
    - metestrus, list of experiment that are in the metestrus phase. 
    - diestrus, list of experiment that are in the diestrus phase.
    
The contents of the estrus phases must be the names of the folders contained in the data folder. 

<a id="as"></a>
### Analysis structures
The analysis structures are created with the __createAnalysisStructure.m__ function located in the code/utils folder. The fields of an analysis structure can be viewed by calling the help function in MATLAB:
```bash
>> help createAnalysisStruct
```

The fields in the analysis structure are the following:
 - nb_events, number of events to analyse in the data.
 - EOR, event occurrence rate (events/min).
 - prop_vel, propagation velocity of events (mm/s).
 - prop_dist, propagation distance (mm).
 - prop_direction, propagation direction of events, 1  is for ovaries to cervix, -1 is for cervix to ovaries, and 0 is for other types of propagation activity.
 - event_interval, time between two events (s).
 - nb_samples, number of channels analysed for each event.
 - sw_duration, slow-wave duration, sw_duration(2, NB_EVENTS), row 1: mean, row 2: std.
 - fw_duration, fast-wave duration, fw_duration(2, NB_EVENTS), row 1: mean, row 2: std.
 - fw_delay, delay betwen onset of the slow and fast-waves (s).
 - fw_presence, percentage of events exhibiting fast-wave bursting activity.

<a id="individual"></a>
### Individual experiment processing
The different experiments can be processed individually with the __markedDataAnalysis.m__ function located in the code/analysis folder. The function produces an analysis structure based on the marked events in the .mat file of the selected experiment. The contents of the analysis structure are details [here](#as). 

The data in an analysis structure can be displayed using the __displayAnalysisStructureResults.m__ function located in the code/utils folder. For visualising the data in plots the __fieldPlot.m__ function located in the code/plots folder can be used to plot the information from the different fields of the analysis structure. Use the help function to display more information in MATLAB: 
```bash
>> help fieldPlot
```

<a id="estrus"></a>
### Estrus phase processing
Multiple experiments can be processed in batches depending on the estrus cycle with the __estrus_analysis.m__ script located in the code/analysis folder. This script calls the __markedDataAnalysis.m__ function for each experiments and groups them by their estrus phase, as described in the estrus_config.toml configuration file. It creates two structures: analysis_structs, which contains the analysis structures of each experiment sorted by estrus phase, and export_structs, which contains all the data produce from the analysis for each metric and experiment. The latter is mainly used for exporting the data to R (see [next section](#stats)).

The analysis can be done for a specific phase of the estrus cycle or all at once. The data can be displayed in a similar fashion as for the individual experiments processing. 

**NOTE:** The __estrus_analysis.m__ script sets the remaining path from baseDir to the data and needs to be modified to fit your setup (line 2 in the script).

<a id="stats"></a>
### Statistics and export for R
Statistics can be run on the results of the analysis to test for significant differences between the different estrus phases. This analysis is performed in R using an analysis of variance (ANOVA).

The __exportForR.m__ function exports all of the necessary data to run the statistical analysis in R. It creates an export folder to store all the data. 
Use the help function to display more information in MATLAB: 
```bash
>> help exportForR
```

The __statistical-analysis.R__ script located in the code/stats folder is used to perform the statistical analysis and plot the results for exported metrics from the __exportForR.m__ function. A Shapiro-Wilk test is performed before the analysis and the results printed to test for data normality. The list of metrics available exactly matches the metrics in the analysis structure. The __direction-analysis.R__ script is used only for plotting the propagation direction and no statistical analysis is performed on the data. 

All plots are saved in the directory provided as input argument. The __generate_figures__ bash script calls the both scripts and saves the results. The list of metrics can be edited to fit your needs.

**NOTE:** Don't forget to change the value of base_dir to fit your setup.