
function saveDroidFeatureFile (szFilename, stInfo, Data)
% function saveDroidFeatureFile (suFiename, stInfo, Data)
% stData struct which must contain the following information
% stData.fs : = the sampling rate of the original audiodata
% stData.hopsizeInSamples := the hopsize of the feature 
% stData.blockStartTime := the correspong datetime of the whole chunk in
% datenum format 
% stInfo.frameSizeInSamples

cMachineFormat = 'b';
stInfo.calibrationIndB = [0 0];
[stInfo.numFrames, stInfo.Dims] = size(Data);



TimeVek(:,1) = 0:stInfo.HopsizeInSamples/stInfo.fs:stInfo.numFrames*stInfo.HopsizeInSamples/stInfo.fs - stInfo.HopsizeInSamples/stInfo.fs;
TimeVek(:,2) = TimeVek(:,1) + stInfo.FrameSizeInSamples/stInfo.fs;

fid = fopen(szFilename,'w',cMachineFormat);

fwrite(fid,2,'int32',0,cMachineFormat); % protokoll format 2
fwrite(fid,stInfo.numFrames,'int32',0,cMachineFormat);
fwrite(fid,stInfo.Dims+2,'int32',0,cMachineFormat);
fwrite(fid,stInfo.FrameSizeInSamples,'int32',0,cMachineFormat);
fwrite(fid,stInfo.HopsizeInSamples,'int32',0,cMachineFormat);
fwrite(fid,stInfo.fs,'int32',0,cMachineFormat);
fwrite(fid, datestr(stInfo.blockStartTime,'yymmdd_HHMMSSFFF'),'char',0,cMachineFormat);
fwrite(fid,stInfo.calibrationIndB,'int32',0,cMachineFormat);
FullData = [TimeVek Data];
fwrite(fid,FullData','float',0,cMachineFormat);

fclose(fid);

