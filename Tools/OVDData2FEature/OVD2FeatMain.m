clear
close all

szOVDDataBaseDir = '/home/bitzer/Nextcloud/Shares/OVD_IHAB/';
szAcousticFeatureBaseDir = '/media/bitzer/Samsung_T5/IHAB_1_EMA2018/IHAB_Rohdaten_EMA2018/';


AllParticipantsOVD = getDirectoriesWithContentOnly(szOVDDataBaseDir);
AllParticipantsFeat = getDirectoriesWithContentOnly(szAcousticFeatureBaseDir);

kk = 1

for nn = 1:length(AllParticipantsFeat)
   ind = strfind(AllParticipantsFeat(nn).name,AllParticipantsOVD(kk).name);
   if ~isempty(ind)
       break
   end
end
curDirFeat = [AllParticipantsFeat(nn).folder filesep AllParticipantsFeat(nn).name filesep AllParticipantsOVD(kk).name '_AkuData' filesep];
curDirOVD = [AllParticipantsOVD(kk).folder filesep AllParticipantsOVD(kk).name filesep 'OVD_PredictionResults' filesep];

AllOVDFiles = dir ([curDirOVD '*.mat']);
AllPSDFiles = dir ([curDirFeat 'PSD_*']);


load ([AllOVDFiles(1).folder filesep AllOVDFiles(1).name])

function saveDroidFeatureFile (szFilename, stInfo, Data)
% function saveDroidFeatureFile (suFiename, stInfo, Data)
% stData struct which must contain the following information
% stData.fs : = the sampling rate of the original audiodata
% stData.hopsizeInSamples := the hopsize of the feature 
% stData.blockStartTime := the correspong datetime of the whole chunk in
% datenum format 
% stInfo.FrameSizeInSamples

cMachineFormat = {'b'};
stInfo.calibrationInDb = [0 0];
[stInfo.numFrames, stInfo.Dims] = size(Data);

fid = fopen(szFilename,'w',cMachineFormat);

fwrite(fid,2,'int32',[],cMachineFormat); % protokoll format 2
fwrite(fid,stInfo.numFrames,'int32',[],cMachineFormat);
fwrite(fid,stInfo.Dims,'int32',[],cMachineFormat);
fwrite(fid,stInfo.FrameSizeInSamples,'int32',[],cMachineFormat);
fwrite(fid,stInfo.hopsizeInSamples,'int32',[],cMachineFormat);
fwrite(fid,stInfo.fs,'int32',[],cMachineFormat);
fwrite(fid, datestr(stInfo.blockStartTime,'yymmdd_HHMMSSFFF'),'char',[],cMachineFormat);


fclose(fid);

end




function cleandirs = getDirectoriesWithContentOnly(baseDir)
alldirs = dir(baseDir);
for kk = 1:length(alldirs)
    ind(kk) = (alldirs(kk).isdir == 0 || strcmp(alldirs(kk).name,'.') || strcmp(alldirs(kk).name ,'..'));
end

alldirs(ind) = [];
cleandirs = alldirs;
end

