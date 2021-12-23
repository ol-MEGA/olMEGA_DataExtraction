
function saveDroidFeatureFile (szFilename, stInfo, Data, TimeVek)
% function saveDroidFeatureFile (suFiename, stInfo, Data, mFrameTime)
% stData struct which must contain the following information
%   stInfo.fs : = the sampling rate of the original audiodata
%   stInfo.HopSizeInSamples := the hopsize of the feature 
%   stInfo.mBlockTime := the correspong datetime of the whole chunk in datenum format 
%   stInfo.frameSizeInSamples
% optional fields:
%   stInfo.SystemTime := real System Time (if it deviates from stInfo.mBlockTime)
%   stInfo.calibrationIndB := Vec with two Calibartion Values in dB
%   stInfo.AndroidID := String (maxLen = 16 Chars)
%   stInfo.BluetoothTransmitterMAC := String (maxLen = 17 Chars)

% v0.2 SF: 
%   adding Feature Header Format v4
%   change struct field names to stInfo from GetFeatureFileInfo()
%   preserve backward compatibility
% v0.3 SF: 
%   add TimeVek as optional parameter

cMachineFormat = 'b';
[stInfo.numFrames, stInfo.Dims] = size(Data);

if isfield(stInfo, 'HopsizeInSamples')
    stInfo.HopSizeInSamples = stInfo.HopsizeInSamples;
end
if isfield(stInfo, 'blockStartTime')
    stInfo.mBlockTime = stInfo.blockStartTime;
end
if ~isfield(stInfo, 'SystemTime')
    stInfo.SystemTime = stInfo.blockStartTime;
end
if ~isfield(stInfo, 'calibrationIndB')
    stInfo.calibrationIndB = [0 0];
end
if ~isfield(stInfo, 'AndroidID')
    stInfo.AndroidID = '';
end
if ~isfield(stInfo, 'BluetoothTransmitterMAC')
    stInfo.BluetoothTransmitterMAC = '';
end

if nargin < 4
    TimeVek(:,1) = 0:stInfo.HopSizeInSamples/stInfo.fs:stInfo.numFrames*stInfo.HopSizeInSamples/stInfo.fs - stInfo.HopSizeInSamples/stInfo.fs;
    TimeVek(:,2) = TimeVek(:,1) + stInfo.FrameSizeInSamples/stInfo.fs;
end

fid = fopen(szFilename,'w',cMachineFormat);

stInfo.AndroidID = sprintf('%16s', stInfo.AndroidID);
stInfo.BluetoothTransmitterMAC = sprintf('%17s', stInfo.BluetoothTransmitterMAC);

fwrite(fid, 4,'int32', 0, cMachineFormat); % protokoll format 4
fwrite(fid, stInfo.numFrames, 'int32', 0, cMachineFormat);
fwrite(fid, stInfo.Dims+2, 'int32', 0, cMachineFormat);
fwrite(fid, stInfo.FrameSizeInSamples, 'int32', 0, cMachineFormat);
fwrite(fid, stInfo.HopSizeInSamples, 'int32', 0, cMachineFormat);
fwrite(fid, stInfo.fs,'int32', 0, cMachineFormat);
fwrite(fid, datestr(stInfo.mBlockTime,'yymmdd_HHMMSSFFF'), 'char', 0, cMachineFormat);
fwrite(fid, datestr(stInfo.SystemTime,'yymmdd_HHMMSSFFF'), 'char', 0, cMachineFormat);
fwrite(fid, stInfo.calibrationIndB(1), 'float32', 0, cMachineFormat);
fwrite(fid, stInfo.calibrationIndB(2), 'float32', 0, cMachineFormat);
fwrite(fid, stInfo.AndroidID(1:16), 'char', 0, cMachineFormat);
fwrite(fid, stInfo.BluetoothTransmitterMAC(1:17), 'char', 0, cMachineFormat);
FullData = [TimeVek Data];
fwrite(fid, FullData', 'float', 0, cMachineFormat);

fclose(fid);

