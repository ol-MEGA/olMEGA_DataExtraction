function [vPredictedOVS,vTime]=detectOwnVoiceRandomForest(obj,stDate)
% function to predict own voice sequences with a trained random forest
% processes intervalls of 1 hour duration
% Usage [vPredictedOVS,vTime]=detectOwnVoiceRandomForest(obj,stDate)
%
% Parameters
% ----------
% obj - class olMEGA_DataExtraction, contains all informations
%
% stDate - struct which contains valid date informations about the time
%          informations: start and end day and time; this struct could
%          result from calling checkInputFormat.m
%
% Returns
% -------
% vPredictedOVS - vector, contains frame based 1 (==voice) | 0 (==no voice)
%
% vTime - corresponding time vector
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 27-Nov-2019 JP

% load trained random forest (cave!)
szTreeDir = [obj.sFolderMain filesep 'functions_helper'];
szName = 'RandomForest_100Trees_OVD.mat';
load([szTreeDir filesep szName], 'szVarNames'); % first only names
szVarNames(end) = []; % exclude ground truth

% check number of 1h intervalls
nHours = hours(stDate.EndTime - stDate.StartTime);

if nHours > 1
    % adjust to 1h
    stDate.EndTime = stDate.StartTime + duration(1, 0, 0);

    % do calculation for 1h intervalls
    vPredictedOVS = [];
    vTime = [];
    for ii = 1:ceil(nHours)    
        % extract features needed for VD
        [mDataSet, vTimeTemp] = FeatureExtraction(obj, stDate, szVarNames);
        
        % check if for the given time interval data is available
        if size(mDataSet, 1) > 1

            % load random forest only once
            if ~exist('MRandomForest', 'var')
                load([szTreeDir filesep szName], 'MRandomForest');
            end
            
            % start prediction with trained ensemble of bagged classification trees
            vOVS = predict(MRandomForest, mDataSet);
            vOVS = str2num(cell2mat(vOVS));

            vPredictedOVS = [vPredictedOVS; vOVS];
            vTime = [vTime; vTimeTemp];
        end

        % adjust time frame
        stDate.StartTime = stDate.StartTime + duration(1, 0, 0.1);
        stDate.EndTime = stDate.EndTime + duration(1, 0, 0);
    end
else
    % extract features needed for VD
    [mDataSet, vTime] = FeatureExtraction(obj, stDate, szVarNames);
    
    % if for the given time interval no data is available, return empty vector
    if size(mDataSet, 1) == 1 || isempty(mDataSet)
        vPredictedOVS = [];
        return;
    end

    % if data found, load random forest
    load([szTreeDir filesep szName], 'MRandomForest');

    % start prediction with trained ensemble of bagged classification trees
    vPredictedOVS = predict(MRandomForest, mDataSet);
    vPredictedOVS = str2num(cell2mat(vPredictedOVS));
end


%--------------------Licence ---------------------------------------------
% Copyright (c) <2021> J. Pohlhausen
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