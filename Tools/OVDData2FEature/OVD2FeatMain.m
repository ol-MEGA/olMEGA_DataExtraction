clear
close all

addpath("../../functions_dataHandling");

szOVDDataBaseDir = '/home/bitzer/Nextcloud/Shares/OVD_IHAB/';
szAcousticFeatureBaseDir = '/media/bitzer/Samsung_T5/IHAB_1_EMA2018/IHAB_Rohdaten_EMA2018/';

AllParticipantsOVD = getDirectoriesWithContentOnly(szOVDDataBaseDir);
AllParticipantsFeat = getDirectoriesWithContentOnly(szAcousticFeatureBaseDir);


% look for matching participants
kk = 1; % this will be the outer loop in the end over all participants

for nn = 1:length(AllParticipantsFeat)
    ind = strfind(AllParticipantsFeat(nn).name,AllParticipantsOVD(kk).name);
    if ~isempty(ind)
        break
    end
end
curDirFeat = [AllParticipantsFeat(nn).folder filesep AllParticipantsFeat(nn).name filesep AllParticipantsOVD(kk).name '_AkuData' filesep];
curDirOVD = [AllParticipantsOVD(kk).folder filesep AllParticipantsOVD(kk).name filesep 'OVD_PredictionResults' filesep];

AllOVDFiles = dir ([curDirOVD '*.mat']);

% load all OVD feaure files and add to one vector

AllOVDTimeVek = [];
AllOVDFeatVek = [];

for ovdf_count = 1:length(AllOVDFiles)
    load ([AllOVDFiles(ovdf_count).folder filesep AllOVDFiles(ovdf_count).name]);
    AllOVDTimeVek = [AllOVDTimeVek;vTime];
    AllOVDFeatVek = [AllOVDFeatVek;vOVS];
end



% get through the list of all psd file and look in the OVD vector for a
% corresponding starting time
% use this time to save 60s of OVD data


AllPSDFiles = dir ([curDirFeat 'PSD_*']);

[~,~] = mkdir([curDirFeat 'OVD']); % [~,~] removes warning of existing directory

%nn = length(AllPSDFiles)-1
for nn = 1:length(AllPSDFiles)
    curPSDFileName =  [AllPSDFiles(nn).folder filesep AllPSDFiles(nn).name];
    
    stInfoFile = GetFeatureFileInfo( curPSDFileName,0);
    idx = find(datetime(stInfoFile.StartTime)==AllOVDTimeVek);
    
    if (~isempty(idx))
        OVD_len_1s = 479;
        OVDexcerpt = AllOVDFeatVek(idx:idx+OVD_len_1s-1);
        
        if (OVD_len_1s == 479)
            OVDexcerpt(end+1) = OVDexcerpt(end); % extrapolation for missing block
        end
    
        % filename to save OVD feat Data
        outname = AllPSDFiles(nn).name;
        outname(1:3) = 'OVD';
        szOVD_featFile = [curDirFeat 'OVD' filesep outname];
        stInfo.fs = stInfoFile.fs;
        stInfo.HopsizeInSamples = stInfoFile.HopSizeInSamples;
        stInfo.blockStartTime = datenum(stInfoFile.StartTime);
        stInfo.FrameSizeInSamples = stInfoFile.FrameSizeInSamples;
    
        saveDroidFeatureFile(szOVD_featFile,stInfo,OVDexcerpt);
    end
end
% and read in again as test

[mFeatureDataNew, mFrameTimeNew, stInfoFileNew ] = LoadFeatureFileDroidAlloc( szOVD_featFile);


function cleandirs = getDirectoriesWithContentOnly(baseDir)
alldirs = dir(baseDir);
for kk = 1:length(alldirs)
    ind(kk) = (alldirs(kk).isdir == 0 || strcmp(alldirs(kk).name,'.') || strcmp(alldirs(kk).name ,'..'));
end

alldirs(ind) = [];
cleandirs = alldirs;
end

