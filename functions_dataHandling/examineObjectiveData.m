function [] = examineObjectiveData(obj)


%% Generate questionnaires table
%fprintf('\t.importing questionnaires -');

%obj.hProgressCommandLine.startTimer();
%import_EMA2018(obj);
%obj.hProgressCommandLine.stopTimer();


%% Validate data

fprintf('Analysing objective data:\n');

fprintf('\t.checking data integrity -');

% First: Check for broken data
obj.hProgressCommandLine.startTimer();
corruptTxtFile = fullfile(obj.stSubject.Folder, 'corrupt_files.txt');
if ~exist(corruptTxtFile,'file')
    checkDataIntegrity(obj);
end
obj.hProgressCommandLine.stopTimer();


% These parameters are for the validation check
% CHANGE PARAMETERS IF NECESSARY
configStruct.lowerBinCohe = 1100;
configStruct.upperBinCohe = 3000;
configStruct.upperThresholdCohe = 0.9;
configStruct.upperThresholdRMS = -6; % -6 dB
configStruct.lowerThresholdRMS = -70; % -70 dB
configStruct.errorTolerance = 0.05; % 5 percent

fprintf('\t.validating subject -');

obj.hProgressCommandLine.startTimer();
validatesubject(obj, configStruct);
obj.hProgressCommandLine.stopTimer();
end

% EOF