<img src="https://github.com/ol-MEGA/olMEGA_DataExtraction/blob/master/functions_reporting/latex/images/Logo.png" alt="olMEGA Logo" width="150">

# olMEGA_DataExtraction #

Matlab tool for automatic data extraction (and analysis) from smartphone.  
Version 2.0 

### Prerequisites: ###
* Matlab 2018b (or later)
* ADB (if used with smartphone)

### Usage: ###  

* Graphical User Interface:

```matlab
olMEGA_DataExtraction()
```


### For IHAB study only: ###

* Command Line:

```matlab
[obj] = olMEGA_DataExtraction([Path to data folder]);
```

* or in case of olMEGA_DataExtraction:

```matlab
[obj] = olMEGA_DataExtraction([Path to data folder], [#EMA run]);
```

* For complete analysis and PDF outptut:

```matlab
[obj].analyseData();
```

ICA_DataAnalysis

* For information on Device Parameters and/or objective Data, use:

```matlab
[obj].stAnalysis
```

### Own Voice Detection (OVD):
* Command Line:

```matlab
[vPredictedOVS, vTime] = detectOwnVoiceRandomForest(obj, [struct with time info]);
```
The folder `olMEGA_DataExtraction` contains the subfolders `functions_application > evaluation`.
The folder `evaluation` contains the function `detectOwnVoiceRandomForest` and its test-script `detectOwnVoiceRandomForestTest`.
For a simple test adjust `detectOwnVoiceRandomForestTest`:

1. `szBaseDir`: customize the path to your main data folder

2. `szCurrentFolder`: choose the name of one subject folder (e.g. SF170777_210720_SF)

3. `stDate`: adjust time informations for prediction: start and end day as datetime and start and end time as duration

 … and run. The function `detectOwnVoiceRandomForest` returns the vector `vPredictedOVS` containing the predicted OVS (1 = OVS, 0 = no OVS) and the corresponding time vector `vTime`.

The OVD calls a feature extraction, which processes data in 1 hour intervals and can take a while, if a longer time period is chosen. We recommend to call `detectOwnVoiceRandomForest` per day.
If for the given input day and time no feature files exist, a short warning occurs and `vPredictedOVS` and `vTime` are empty.


## License:

Copyright 2021 olMEGA

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
