function [vCalibConst]=getCalibConst(obj)
% function to get the system specific calibration constant
% informations are based on calibration measurements, the
% returned calibration constant is channel (right+left) dependent
%
% Usage [vCalibConst]=getCalibConst(obj)
%
% Parameters
% ----------
% obj - class olMEGA_DataExtraction, contains all informations
%
% Returns
% -------
% vCalibConst - vector, contains system specific calibration constants 
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 16-Jul-2021 JP

% get log file from subject folder
sLogFile = fullfile(obj.stSubject.Folder, obj.sLogFile);

% if log file does not exist, return default
if isempty(sLogFile)
    warning('No log-file was found, used default calibration values.');
    vCalibConst = [122.847707; 123.023176]; % MAC: 20_FA_BB_0E_9A_44
    return;
end

% read log file
cLog = fileread(sLogFile);
cLog = splitlines(cLog);

% get bluetooth device mac address from log file
idxMAC = find(contains(cLog, 'Bluetooth: Device'), 1);
sMAC = cLog{idxMAC(1)}(end-17:end-1);

% load specific calibration constant
sCalibDir = '/Volumes/Samsung_T5/olMEGA/olMEGA_Calibration_files';
sCalibFile = fullfile(sCalibDir, [strrep(sMAC, ':', '_') '.txt']);

% if log file does not exist, return default
if ~exist(sCalibFile, 'file')
    warning('No system-specific calibration data was found, used default calibration values.');
    vCalibConst = [122.847707; 123.023176]; % MAC: 20_FA_BB_0E_9A_44
else
    vCalibConst = importdata(sCalibFile);
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

% eof