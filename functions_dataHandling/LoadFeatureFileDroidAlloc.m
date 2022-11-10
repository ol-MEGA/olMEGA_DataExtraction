% v0.2
% v0.3 JB,  Vise deleted and new stInfo introduced
% v0.4 SK,  force big endian for java compatability
% v0.5 SK   fork to read android data (multiple blocks with a header each)
%           changed naming convention, frames vs. blocks.
% v0.6 SK   invoke GetFeatureFileInfo.m to properly allocate memory.
%           implement access to specified block range
% v0.7 SK   fix reading of specified blocks if data is not continuous (WIP!)
% v0.8 SK   fixed indexing for different frames/block
% v0.9 SK   mFrameTime now contains absolute start and end time of each
%           rame as serial date
% v0.10 JP  optional time correction to system time and hardware sample  
%           rate, excluded start and stop index as input for reading data

function [mFeatureData, mFrameTime, stInfo] = LoadFeatureFileDroidAlloc(szFilename, bTimeCorrection)
%LOADFEATUREFILE  Loads a feature file, created by FEATUREEXTRACTION.
%   LOADFEATUREFILEALLOC('filename') loads all data saved in "filename"
%   and returns it as column vector, containing one feature frame per row.
%   So the number of rows equals the number of avaliable feature frames
%   and the number of columns matches the feature dimension.
%
%   input:
%       szFilename          Android feature file
%       bTimeCorrection     boolean to apply time corretion to system time 
%                           and hardware sample rate (default false)
%
%   output:
%       mFeatureData        What we're after (nFrames x nFeatures)
%       mFrameTime          Frames' absolute start time, datevec.
%                           get desired format using e.g. datestr():
%                           datestr(mFrameTime,'dd-mmm-yyyy HH:MM:SS:FFF')
%       stInfo              Parameter and metadata
%
% Auth: Sven Fischer, Joerg Bitzer

if nargin == 1
    bTimeCorrection = 0;
end

cMachineFormat = {0, 'b'};

% Get information about feature file for preallocation
stInfo = GetFeatureFileInfo(szFilename, 0);

% Try to open the specified file for Binary Reading.
fid = fopen( szFilename, 'rb' );

% If the file could be opened successfully...
%if fid >= 1 && stInfo.nFrames == 480
if (fid)
    idxStart = 1;
    idxStop = stInfo.nBlocks;
    nFrames = stInfo.nFrames;
    
    mFeatureData = zeros(nFrames,stInfo.nDimensions-2);
    mFrameTime_rel = zeros(nFrames,2); % seconds, beginning and end of frame
    
    for iBlock = idxStart:idxStop        
        fseek(fid, stInfo.nBytesHeader, 0);  % skip header
        
        tempData = fread(fid, [stInfo.nDimensions, stInfo.vFrames], 'float', cMachineFormat{:});
        
        if iBlock == idxStart
            % idx = 1:stInfo.vFrames(iBlock);
            idx = 1:size(tempData, 2);
        else
            % idx = idx(end) + (1:stInfo.vFrames(iBlock));
            idx = idx(end) + (1:size(tempData, 2));
        end
        
        mFeatureData(idx,:) = tempData(3:end,:).';
        mFrameTime_rel(idx,:) = tempData(1:2,:).';
        
    end % for iBlock
    
    fclose( fid );
        
    % optional apply time corretion to system time and hardware fs
    if bTimeCorrection
        % convert syste,time to serial date
        systime = datenum(stInfo.SystemTime);
        corrFactor = stInfo.fs/stInfo.HardwareSampleRate;
        mFrameTime = corrFactor*mFrameTime_rel(:, 1)/(24*60*60) + systime;
    else
        % convert blocktime to serial date
        blocktime = datenum(stInfo.mBlockTime);
        mFrameTime = mFrameTime_rel(:, 1)/(24*60*60) + blocktime;
    end
    
    stInfo.mFrameTime_rel = mFrameTime_rel;
    
else
    % If the "fopen" command has failed...
    error('Unable to open file "%s".\n', szFilename);
end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2005- 2012> J.Bitzer, Sven Fischer
% Institute for Hearing Technology and Audiology
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
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
% eof