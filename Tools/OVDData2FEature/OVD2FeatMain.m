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




function cleandirs = getDirectoriesWithContentOnly(baseDir)
alldirs = dir(baseDir);
for kk = 1:length(alldirs)
    ind(kk) = (alldirs(kk).isdir == 0 || strcmp(alldirs(kk).name,'.') || strcmp(alldirs(kk).name ,'..'));
end

alldirs(ind) = [];
cleandirs = alldirs;
end

