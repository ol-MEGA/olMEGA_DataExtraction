% test script belonging to getObjectiveData.m
%
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 26-Sep-2019 	JP
% Ver. 0.02 adaptation to new data structure 24-Jan-2022 UK

% clear;
close all;

% path to data folder (needs to be customized, i.e. 'C:/User/Name/Subject')
% use single quotation marks
szBaseDir = 'D:\olMEGA_TestData\Linköping\AE210070_220804_uk';

% get all subject directories
subjectDirectories = dir(szBaseDir);

% get object
[obj] = olMEGA_DataExtraction([szBaseDir]);

% Specify the feature you would like to extract [PSD, RMS, ZCR]
szFeature = 'ZCR';

% define figure width full screen in pixels
stRoots = get(0);

% get plot width
iPlotWidth = stRoots.ScreenSize(3);

% [Data,TimeVec,stInfo] = getObjectiveData(obj, szFeature, ...
%     'startDay','first', 'endDay', 'last');

% [Data,TimeVec,stInfo] = getObjectiveData(obj, szFeature, ...
%     'startDay','first','endDay','last', ...
%     'StartTime',duration(8,0,0),'EndTime',duration(13,0,0), ...
%     'PlotWidth',iPlotWidth);

[Data,TimeVec,stInfo] = getObjectiveData(obj, szFeature, ...
    'startDay','first', 'endDay', 'last', ...
    'PlotWidth',iPlotWidth);

if strcmp(szFeature, 'PSD')
    imagesc(10*log10(abs(flipud(Data'))));
    title(sprintf('PSD/CPSD between %s and %s', TimeVec(1), TimeVec(end)));
    colorbar;
elseif strcmp(szFeature, 'RMS')
    plot(TimeVec, 10*log10(Data));
    axis tight;
    ylabel('RMS level [dB]');
    legend({'Left', 'Right'})
    title(sprintf('RMS level (uncalibrated) between %s and %s', TimeVec(1), TimeVec(end)))
elseif strcmp(szFeature, 'ZCR')
    plot(TimeVec, Data);
    ylabel('Zero-crossing rate [1/s]');
    axis tight;
    legend({'Left', '\Delta Left', 'Right', '\Delta Right'})
    title(sprintf('ZCR between %s and %s', TimeVec(1), TimeVec(end)))
end

disp(stInfo);

fprintf('Feature extraction complete.\n');

%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> J. Pohlhausen
% Jade University of Applied Sciences
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.