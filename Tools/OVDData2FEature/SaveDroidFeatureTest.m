clear 
close all

% read original data
onefeaturefile = 'RMS_010902_20180614_235620221.feat';
[mFeatureData, mFrameTime, stInfoFile ] = LoadFeatureFileDroidAlloc( onefeaturefile);

addpath('../../functions_dataHandling');
% test script to save a droid feature file

% copy data to new structure

stInfo.fs = stInfoFile.fs;
stInfo.HopsizeInSamples = stInfoFile.HopSizeInSamples;
stInfo.blockStartTime = now;
stInfo.FrameSizeInSamples = stInfoFile.FrameSizeInSamples; % 50% overlap

szFileName = ['dataTemp.feat'];

%nroffeatures = 3;

%data = randn(floor(60*stInfo.fs/(stInfo.hopsizeInSamples))-1,nroffeatures);
%data(:,1) = 1:size(data(:,1));

data = mFeatureData;

saveDroidFeatureFile(szFileName,stInfo,data);

% and read in again as test

stInfoIn = GetFeatureFileInfo( szFileName, 1 );

[mFeatureDataNew, mFrameTimeNew, stInfoFileNew ] = LoadFeatureFileDroidAlloc( szFileName);
