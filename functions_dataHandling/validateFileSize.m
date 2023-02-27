% checks for valid filesize in case header wasn't updated properly on close 
% and offer a value to use for further processing.
% sk_01/23

function [nFrames, nDim] = validateFileSize(sFilename, fileSize)

[~, filenameonly] = fileparts(sFilename);

% valid values for default feature configuration
stValidValues = struct( ...
    'name', {'PSD', 'RMS', 'ZCR', 'VTB'}, ...
    'nFrames', {480, 4800, 4800, 15000}, ...
    'nFramesPerBlock', {480, 4800, 4800, 15000}, ...
    'vFrames', {480, 4800, 4800, 15000}, ...
    'nDim', {1030, 4, 6, nan} ...
    );

% 1,2: old headers w/o version field 
vHeaderSizes = [36, 48, 64, 97, 101];

% Calculate valid filesize w/o header
[~, name] = fileparts(sFilename);
idxFeat = find(count({stValidValues.name}, name(1:3)));
validSize = stValidValues(idxFeat).nFrames ...
    * stValidValues(idxFeat).nDim * 4;

% the remaining bytes must be the header
headerSize = fileSize - validSize;

% check header size and and set to valid values
if sum(headerSize == vHeaderSizes)
    % set number of frames assumed for a valid file
    nFrames = stValidValues(idxFeat).nFrames;
    nDim = stValidValues(idxFeat).nDim;
    warning(['feature file %s has missing metadata. Filesize is ' ...
        'plausible, assuming standard values.'], filenameonly);
else
    nFrames = 0; nDim = 0;
    warning(['feature file %s has missing metadata. Filesize does not ' ...
        'match, setting frames to zero.'], filenameonly);
end






 