<img src="https://github.com/ol-MEGA/olMEGA_DataExtraction/blob/master/functions_reporting/latex/images/Logo.png" alt="olMEGA Logo" width="150">

# olMEGA_DataExtraction #

Matlab tool for automatic data extraction and analysis from smartphone.  
Version 1.0  

### Prerequisites: ###
* Matlab 2018b (or later)
* ADB (if used with smartphone)

### Usage: ###  

* Graphical User Interface:

```matlab
olMEGA_DataExtraction()
```

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


## License:

Copyright 2020 olMEGA

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
