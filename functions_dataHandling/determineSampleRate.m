function [nSampleRate, vShift]=determineSampleRate(obj,szFeature,varargin)
% function to determine the sample rate for a specific time frame
% Usage [Data,TimeVec,stInfoFile]=getObjectiveData(obj,szFeature,varargin)
%
% Parameters
% ----------
% obj : class olMEGA_DataExtraction, contains all informations
%
% szFeature : string, specifies which feature data should be read in
%             possible: 'PSD', 'RMS', 'ZCR'
%
% varargin :  specifies optional parameter name/value pairs.
%             getObjectiveData(obj 'PARAM1', val1, 'PARAM2', val2, ...)
%  'StartTime'          duration to specify the start time of desired data
%                       syntax duration(H,MI,S);
%                       or a number between [0 24], which will be
%                       transformed to a duration;
%
%  'EndTime'            duration to specify the end time of desired data
%                       syntax duration(H,MI,S);
%                       or a number between [0 24], which will be
%                       transformed to a duration;
%                       obviously EndTime should be greater than StartTime;
%
%  'StartDay'           to specify the start day of desired data, allowed
%                       formats are datetime, numeric (i.e. 1 for day one),
%                       char (i.e. 'first', 'last')
%
%  'EndDay'             to specify the end day of desired data, allowed
%                       formats are datetime, numeric (i.e. 1 for day one),
%                       char (i.e. 'first', 'last'); obviously EndDay
%                       should be greater than or equal to StartDay;
%
%  'stInfo'             struct which contains valid date informations about
%                       the aboved named 4 parameters; this struct results
%                       from calling checkInputFormat.m
%
% Returns
% -------
% Data :  a matrix containg the feature data
%
% TimeVec :  a date/time vector with the corresponding time information
%
% stInfoFile : a struct containg infos about the feature files, e.g. fs,
%              frame size in samples...
%
% Author: J.Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 03-Nov-2022 JP

% check for valid feature data
vFeatureNames = {'RMS', 'PSD', 'ZCR'};
szFeature = upper(szFeature); % convert to uppercase characters
if ~any(strcmp(vFeatureNames,szFeature))
    error('input feature string should be RMS, PSD or ZCR');
end

% parse input arguments
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('obj', @(x) isa(x,'olMEGA_DataExtraction') && ~isempty(x));
p.addParameter('StartTime', 0, @(x) isduration(x) || isnumeric(x));
p.addParameter('EndTime', 24, @(x) isduration(x) || isnumeric(x));
p.addParameter('StartDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('EndDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('stInfo', [], @(x) isstruct(x));
p.parse(obj,varargin{:});

% Re-assign values
stInfo = p.Results.stInfo;

if isempty(stInfo)
    % call function to check input date format and plausibility
    stInfo = checkInputFormat(obj, p.Results.StartTime, p.Results.EndTime, ...
        p.Results.StartDay, p.Results.EndDay);
end

% check if the day has objective data
% build the full directory
szDir = [obj.stSubject.Folder filesep obj.stSubject.Name '_AkuData'];

% List all feat files
AllFeatFiles = listFiles(szDir,'*.feat');
AllFeatFiles = {AllFeatFiles.name}';
isInValidFile = contains(AllFeatFiles, '._');
AllFeatFiles(isInValidFile) = [];

% Get names wo. path
[~,AllFeatFiles] = cellfun(@fileparts, AllFeatFiles,'UniformOutput',false);

% Append '.feat' extension for comparison to corrupt file names
AllFeatFiles = strcat(AllFeatFiles,'.feat');

% Load txt file with corrupt file names
corruptTxtFile = fullfile(obj.stSubject.Folder,'corrupt_files.txt');
if ~exist(corruptTxtFile,'file')
    checkDataIntegrity(obj);
end
fid = fopen(corruptTxtFile,'r');
corruptFiles = textscan(fid,'%s\n');
fclose(fid);

% Textscan stores all lines into one cell array, so you need to unpack it
corruptFiles = corruptFiles{:};

% Delete names of corrupt files from the list with all feat file names
[featFilesWithoutCorrupt] = setdiff(AllFeatFiles,corruptFiles,'stable');

% isFeatFile filters for the wanted feature dates, such as all of 'RMS'
[dateVecAll,isFeatFile] = Filename2date(featFilesWithoutCorrupt,szFeature);

% Also filter the corresponding file list
featFilesWithoutCorrupt = featFilesWithoutCorrupt(logical(isFeatFile));

% split dateVecAll into times and dates
timeVecAll = timeofday(dateVecAll);
dateVecDayOnly = dateVecAll - timeVecAll;

% check for dates in desired start-end day interval
idxDay = dateVecDayOnly >= stInfo.StartDay & dateVecDayOnly <= stInfo.EndDay;

% read the data
if isempty(idxDay)
    warning('off','backtrace');
    warning(['For the given input day (' datestr(stInfo.StartDay) ') no feature files exist!']);
    nSampleRate = [];
    return;
end

% filter for desired start and end day
dateVecAll(~idxDay) = [];
timeVecAll(~idxDay) = [];
featFilesWithoutCorrupt(~idxDay) = [];

% check for times in desired start-end time interval
idxTime = timeVecAll >= stInfo.StartTime & timeVecAll <= stInfo.EndTime;

% filter for desired start and end time
featFilesWithoutCorrupt(~idxTime) = [];
dateVecAll(~idxTime)= [];

% get number of available feature files in current time frame
NrOfFiles = numel(featFilesWithoutCorrupt);

if isempty(featFilesWithoutCorrupt)
    warning('off','backtrace');
    warning(['For the given input day (' datestr(stInfo.StartDay) ') and time (' ...
        datestr(stInfo.StartTime, 'HH') '-' datestr(stInfo.EndTime, 'HH') ') no feature files exist!']);
    nSampleRate = [];
    return;
end


% loop over each feature file
vShift = zeros(NrOfFiles, 1);
for fileIdx = 1:NrOfFiles

    szFileName = featFilesWithoutCorrupt{fileIdx};

    % load data from feature file
    [~, ~, stFileInfo] = LoadFeatureFileDroidAlloc([szDir filesep szFileName]);

    vShift(fileIdx) = datenum(stFileInfo.mBlockTime - stFileInfo.SystemTime);

    if fileIdx == 1
        startTime = stFileInfo.mBlockTime;
        startTimeSys = stFileInfo.SystemTime;
    elseif fileIdx == NrOfFiles
        endTime = stFileInfo.mBlockTime;
        endTimeSys = stFileInfo.SystemTime;
    end
end

% determine true sample rate!!!
nRecLen = datenum(endTime - startTime) * 24 * 60 * 60; % in sec
nRecLenSys = datenum(endTimeSys - startTimeSys)* 24 * 60 * 60; % in sec
nSampleRate = nRecLenSys/nRecLen*stFileInfo.fs;

end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2022> J.Pohlhausen
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