% File to check all feature data if data are corrupt
% J. Bitzer @TGM @ Jade Hochschule
% V 1.0 May 2017
% 21-12-02, UK: Some comments added after reported error
% 21-12-15, UK: Exchanged VALIDBLOCKS for VTB to prevent
%               mis-classificaation of error blocks


function checkDataIntegrity(obj)

szCurrentDir = [obj.stSubject.Folder, filesep, obj.stSubject.Name, '_AkuData' ];

% obtains list of all files
AllDataEntries = listFiles(szCurrentDir,'*.feat');
% checks whether files are valid on first glance
isInValidFile = arrayfun(@(x)(contains(x.name, '._')), AllDataEntries);
% checks if files are of intermediat "VALIDBLOCKS" format
isVALIDBLOCKS = arrayfun(@(x)(contains(x.name, 'VTB')), AllDataEntries);
% neither are needed here, so the lists are combined... 
isInValidFile = logical(sign(isInValidFile + isVALIDBLOCKS));
% and the files discarded from list
AllDataEntries(isInValidFile) = [];

if isempty(AllDataEntries)
    return;
end

% how big are the files in terms of space in memory
SizeOfData = cell2mat({AllDataEntries.bytes});
% histogram over file sizes to exclude eratic sizes
[NrOfOccurances,Values] = hist(SizeOfData,unique(SizeOfData));
% sorting histogram from highest occurrence to lowest...
[~,idxSort] = sort(NrOfOccurances,'descend');
% ...to find common filesizes of all 3 features
TrueValues = Values(idxSort(1:3));

fid = fopen(fullfile(obj.stSubject.Folder, 'corrupt_files.txt'), 'w');

corruptFileCounter = 0;

for nn = 1:length(AllDataEntries)
    
    if all(TrueValues ~= AllDataEntries(nn).bytes)
        [~,szNameofFile] = fileparts(AllDataEntries(nn).name);
        fprintf(fid,'%s.feat\n', szNameofFile);
        corruptFileCounter = corruptFileCounter + 1;
    end
    
end

%fprintf('%t-%i of %i files are corrupt\n', corruptFileCounter, length(AllDataEntries));
fclose(fid);

end





