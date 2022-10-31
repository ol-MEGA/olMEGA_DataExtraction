
function stSubject = validatesubject(obj, configStruct)
%VALIDATESUBJECT returns whether the data of one subject are valid
%   The output struct is saved to the given path.
%
% INPUT:
%       szSubjectDir: string, full path of one subject directory
%
%       configStruct: struct, defines validation parameters
%               has to define:
%                       .lowerBinCohe: center frequency of the lower bin
%                                     of coherence which is used for averaging
%                                     over a number of bins
%                       .upperBinCohe: center frequency of the upper bin
%                                     of coherence which is used for averaging
%                                     over a number of bins
%                       .upperThresholdCohe: threshold for the mean between
%                                           the upper and lower bins of coherence
%                                           that should not be exceeded
%                       .lowerThresholdCohe: threshold for the mean between
%                                           the upper and lower bins of coherence
%                                           that should not be undercut
%                       .thresholdRMSforCohe: threshold of RMS that should
%                                            not be undercut for the
%                                            validation of the coherence
%                       .upperThresholdRMS: threshold of RMS that should
%                                           not be exceeded
%                       .lowerThresholdRMS: threshold of RMS that should
%                                           not be undercut
%                       .errorTolerance: percentage of allowed invalidity
%
% OUTPUT:
%       tableSubject: struct, contains:
%                       .FolderName: string, subject ID + extension
%                       .SubjectID: string
%                       .chunkID: struct, contains:
%                           .FileName: cell of strings
%                           .ErrorCode: cell, contais int/vector
%                                       respective error codes for each
%                                       file
%                                       Error codes can be:
%                            0: ok
%                           -1: at least one RMS value was too HIGH
%                           -2: at least one RMS value was too LOW
%                           -3: data is mono
%                           -4: Coherence (real part) is invalid
%                           -5: RMS feature file was not found

% Author: N.Schreiber (c)
% Version History:
% Ver. 0.01 initial create (empty) 14-Dec-2017 			 NS
% Ver. 0.02 first running version 04-Jan-2018 			 NS
% Ver. 0.03 added config struct 02-Feb-2018 			 NS
% Ver. 0.04 safety net for missing feature data          UK
% Ver  0.05 adaptation to matlab 2022                    JB
% ---------------------------------------------------------

% Parameters for version check
%yearNewData = 2018;
%monthNewData = 4;

% Get name of subject without any postfix
stSubject.FolderName = obj.stSubject.Folder;

% szSubjectID = szSubjectID{1};
stSubject.SubjectID = obj.stSubject.Name;

% Get into respective '_AkuData'-directory
% szAkuDataPath = fullfile(obj.stSubject.Folder, [obj.stSubject.Name '_AkuData']);
szAkuDataPath = fullfile(obj.stSubject.Folder, obj.stSubject.Name+"_AkuData");
% sz
% MatFile = fullfile(obj.stSubject.Folder, [obj.stSubject.Name '.mat']);
szMatFile = fullfile(obj.stSubject.Folder, obj.stSubject.Name);
szMatFile = szMatFile+'.mat';

if exist(szMatFile, 'file') ~= 2
    
    if ~exist(szAkuDataPath, 'dir')
        error('%s: Sub-directory ''_AkuData'' does not exist',obj.stSubject.Name)
    end
    
    % Get all .feat-file names
    listFeatFiles = listFiles(szAkuDataPath, '*.feat', 1);
    isInValidFile = arrayfun(@(x)(contains(x.name, '._')), listFeatFiles);
    listFeatFiles(isInValidFile) = [];
    
    % Store names in a cell array
    listFeatFiles = {listFeatFiles.name};
    
    % Get names without paths
    [~,listFeatFiles] = cellfun(@fileparts, listFeatFiles, 'UniformOutput', false);
    % listFeatFiles = strcat(listFeatFiles,'.feat');
    for kk = 1:length(listFeatFiles)
        OneFeatFileName = listFeatFiles{kk} + '.feat';
        onename = convertStringsToChars(OneFeatFileName);
        listFeatFiles2{kk} = onename;
    end
    listFeatFiles = listFeatFiles2;

        
    % Get dates of corrupt files to delete all features with that specific time stamp
    %corruptFiles = listFeatFiles(cellfun(@(x) (strcmpi(x(1),'a')), listFeatFiles));
    corruptTxtFile = fullfile(obj.stSubject.Folder, 'corrupt_files.txt');
    if ~exist(corruptTxtFile,'file')
        checkDataIntegrity(obj);
    end
    % if the file still doesn't exist, there is an error - e.g. no feature files
    % in presence of a valid log file
    if ~exist(corruptTxtFile,'file')
        stSubject = [];
        return;
    end

    fid = fopen(corruptTxtFile,'r');
    corruptFiles = textscan(fid,'%s\n');
    fclose(fid);
    corruptFiles = corruptFiles{:};
    
    % Delete names of corrupt files from the list with all feat file names
    [listFeatFiles] = setdiff(listFeatFiles,corruptFiles,'stable');
    
    % Get all features
    caFeatures = unique(cellfun(@(x) (x(1:3)), listFeatFiles, 'UniformOutput', false));
    NumFeatFiles = numel(listFeatFiles);

    % Check each chunk for validity via validatechunk.m
    caErrorCodes = cell(NumFeatFiles,1);
    caPercentErrors = cell(NumFeatFiles,1);
    
    if obj.isParallel
        
        parfor ii = 1 : NumFeatFiles
            
            % get current file
            currentFile = [szAkuDataPath filesep listFeatFiles{ii}];
            
            [caErrorCodes(ii), caPercentErrors(ii)] = validatechunk(currentFile, configStruct);
        end
        
    else
        
        for ii = 1:NumFeatFiles
            % get current file
            currentFile = szAkuDataPath+filesep+listFeatFiles{ii};
            
            [caErrorCodes(ii), caPercentErrors(ii)] = validatechunk(currentFile, configStruct);
        end
        
    end
    
    stSubject.chunkID = struct('FileName',{listFeatFiles'},'ErrorCode',{caErrorCodes}, 'PercentageError', {caPercentErrors});
    
    save(szMatFile,'stSubject');
end

% EOF validatesubject.m