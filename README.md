<img src="https://github.com/ol-MEGA/olMEGA_DataExtraction/blob/master/functions_reporting/latex/images/Logo.png" alt="olMEGA Logo" width="150">

# IHAB_DataExtraction #

Matlab tool for automatic data extraction and analysis from smartphone.

### Usage: ###  

* Graphical User Interface:

```matlab
IHABdata()
```

* Command Line:

```matlab
[obj] = IHABdata([Path to data folder]);
```

* or in case of IHAB-rl:

```matlab
[obj] = IHABdata([Path to data folder], [#EMA run]);
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

### Prerequisites: ###
* Matlab 2018b (or later)
* ADB (if used with smartphone)

Version 1.0
