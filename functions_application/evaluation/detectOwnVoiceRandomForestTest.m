% script to predict own voice sequences based on 125ms frames with a
% pre-trained Random Forest
%
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 20-Feb-2020 	JP

clear; 
close all;

% path to main data folder (needs to be customized!)
szBaseDir = 'I:\olMEGA\TestData';

% name of one subject folder (needs to be customized!)
szCurrentFolder = 'SF170777_210720_SF';

% get object
[obj] = olMEGA_DataExtraction([szBaseDir filesep szCurrentFolder]);

% set desired time infos
stDate.StartDay = datetime(2021,7,19); % date format: year,month,day
stDate.EndDay = stDate.StartDay;
stDate.StartTime = duration(8,0,0); % time format: hour,min,sec; i.e. 8 am
stDate.EndTime = duration(9,0,0);   % time format: hour,min,sec; i.e. 9 am

% call OVD 
[vPredictedOVS, vTime] = detectOwnVoiceRandomForest(obj, stDate);