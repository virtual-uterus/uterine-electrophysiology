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
 

<a id="requirements"></a>
## Requirements
The code was developed in [MATLAB](https://www.mathworks.com/products/matlab.html) version 2022a and requires the MATLAB **Image Processing Toolbox** and **Signal Processing Toolbox** packages. The configuration files [TOML](https://toml.io/en/) and require the [MATLAB implementation of TOML](https://github.com/g-s-k/matlab-toml) 

<a id="structure"></a>
## Data folder structure
The folders containing the data are structured as follows:
```bash
data
├── AWA026
│   └── mat
│       ├── AWA026_run_X_G7x2_marked.mat
│       ├── AWA026_config.toml
├── AWAB001
│   └── mat
│       ├── AWB001_run_X_G7x2_marked.mat
│       ├── AWB001_config.toml
└── estrus_config.toml
```
Examples of the different configuration files can be found in the config folder.

<a id="usage"></a>
## Usage
The analysis process requires that the data be marked in [GEMS](https://link.springer.com/article/10.1186/1471-230X-12-60) because the analysis depends on the timestamps and wave numbers provided in the annotated .mat files. 
 
<a id="config"></a>
### Configuration files
There are two configuration different configuration files: the individual experiment configuration files, which are located in the mat folders of each experiment, and the global estrus configuration file, located in the data folder. 

The individual experiment configuration files contains the following fields:
 - run_nb, the run number is the value of X in the names of the mat files shown in the [data folder structure](#structure). If several experimental runs are annotated, this allows to switch from one to another.  
 - half_win_size, is half the size of the observation window around the timestamps of the marked events. half_win_size sampling points before and half_win_size sampling points after the marked timestamp will be selected and make up the event observation window.
 - lowpass_cutoff_freq, is the cutoff frequency of the low-pass filter which extracts the slow-wave component from the signal. The value is in Hz.
 - highpass_cutoff_freq, is the cutoff frequency of the high-pass filter which extracts the fast-wave component from the signal. The value is in Hz.
 - min_nb_chns, is the minimal number of channels in which the event should appear for it to be analysed.
 - time_res, is the temporal resolution for spectrographic analysis.
 - tolerance, is the maximum number of elements separating detected events for the duration calculation. If two events are closer than the tolerance, the detected events are considered to be the same and their durations are combined.
 - min_peak_dist, is the minimum peak distance for the annotationPlot.m function.
 
The global configuration file contains the following fields:
- [phases]
    - proestrus=["AWA033", "AWB004"] 
    - estrus=["AWA031", "AWB001"] 
    - metestrus=["AWB005"] 
    - diestrus=["AWA032", "AWB003"] 
    
The contents of the estrus phases must be the names of the folders contained in the data folder. 
<a id="as"></a>
### Analysis structures
The analysis structures are created with the __createAnalysisStructure.m__ function located in the code/utils folder. The fields of an analysis structure can be viewed by calling the help function in MATLAB:
```bash
>> help createAnalysisStructure
```

The fields in the analysis structure are the following:
 - nb_events, number of events to analyse in the data.
 - EOR, event occurrence rate.
 - velocity, propagation velocity.
 - nb_samples, number of channels analysed in each event, nb_samples(1, NB_EVENTS).
 - sw_frequency, slow-wave max frequency, sw_frequency(2, NB_EVENTS), row 1: mean, row 2: std.
 - sw_frequency, slow-wave max frequency, sw_frequency(2, NB_EVENTS), row 1: mean, row 2: std.
 - sw_duration, slow-wave duration, sw_duration(2, NB_EVENTS), row 1: mean, row 2: std.
 - fw_frequency, fast-wave max frequency, fw_frequency(2, NB_EVENTS), row 1: mean, row 2: std.
 - fw_bandwidth, frequency bandwidth with 95% of signal power,  fw_bandwidth(2, NB_EVENTS), row 1: mean, row 2: std.
 - fw_fhigh, high limit of 95% of signal power frequency band, fw_fhigh(2, NB_EVENTS), row 1: mean, row 2: std.
 - fw_flow, low limit of 95% of signal power frequency band, fw_flow(2, NB_EVENTS), row 1: mean, row 2: std.
 - fw_duration, fast-wave duration, fw_duration(2, NB_EVENTS), row 1: mean, row 2: std.

<a id="individual"></a>
### Individual experiment processing
The different experiments can be processed individually with the __markedDataAnalysis.m__ function located in the code/analysis folder. The function produces an analysis structure based on the marked events in the .mat file of the selected experiment. The contents of the analysis structure are details [here](#as). 

The data in an analysis structure can be displayed using the __displayAnalysisStructureResults.m__ function located in the code/utils folder. For visualising the data in plots the __fieldPlot.m__ function located in the code/plots folder can be used to plot the information from the different fields of the analysis structure. Use the help function to display more information in MATLAB: 
```bash
>> help fieldPlot
```

<a id="estrus"></a>
### Estrus phase processing
Multiple experiments can be processed in batches depending on the estrus cycle with the __estrusAnalysis.m__ script located in the code/analysis folder. This script calls the __markedDataAnalysis.m__ function for each experiments and groups them by their estrus phase, as described in the estrus_config.toml configuration file. 

The analysis can be done for a specific phase of the estrus cycle or all at once. The data can be displayed in a similar fashion as for the individual experiments processing. 