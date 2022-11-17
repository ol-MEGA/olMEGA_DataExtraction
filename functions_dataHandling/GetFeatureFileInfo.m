% Vers: v0.20
% Vers v0.3 JB, Vise deleted and new stInfo introduced
% v0.4 SK, force big endian for java compatability
% v0.5 SK, fork to read android data (multiple blocks with a header each)
%          changed naming convention, frames vs. blocks.
% v0.6 SK, fixed session detection
% v0.7 SF, new header version (for details see end of code)
% v0.8 SF, new V4 header version (for details see end of code)
% v0.9 UK, safety net for exceptionally high (erroneous) frame numbers
% v0.91 SF, new V5 header version (for details see end of code)

function stInfo = GetFeatureFileInfo(szFilename, bInfo)
%GetFeatureFileInfo  Extracts information of Android-generated Feature-Files
%   GetFeatureFileInfo('filename') extracts the metadata in "filename"
%   input:
%       szFilename          android feature file
%       bInfo               print detailed information
%
%   output:
%       stInfo              parameter and metadata
%
% Auth: Sven Fischer, Joerg Bitzer, Sven Franz

if nargin < 2
    bInfo = false;
end

cMachineFormat = {'b'};
veryOldHeaderSizes = [29, 36]; % Header Sized of V0 and V1

% Try to open the specified file for Binary Reading.
fid = fopen( szFilename );

% If the file could be opened successfully...
if( fid ) && fid ~= -1
    
    nBlocks = 0;            % # blocks
    
    while ~feof(fid)
        
        if nBlocks == 0
            fseek(fid, 0, 'eof');
            fileSize = ftell(fid);
            fseek(fid, 0, 'bof');
            vFrames = double(fread( fid, 1, 'int32', cMachineFormat{:}));
            nDim = double(fread( fid, 1, 'int32', cMachineFormat{:}));
            ProtokollVersion = find(vFrames * nDim * 4 + veryOldHeaderSizes(1:2) == fileSize, 1, 'first') - 1;
            if isempty(ProtokollVersion)
                fseek(fid, 0, 'bof');
                ProtokollVersion = double(fread( fid, 1, 'int32', cMachineFormat{:}));
                vFrames = double(fread( fid, 1, 'int32', cMachineFormat{:}));
                nDim = double(fread( fid, 1, 'int32', cMachineFormat{:}));
            end
            stInfo.FrameSizeInSamples = double( fread(fid, 1, 'int32', cMachineFormat{:}));
            stInfo.HopSizeInSamples = double( fread(fid, 1, 'int32', cMachineFormat{:}));
            stInfo.fs = double( fread(fid, 1, 'int32', cMachineFormat{:}));
            if ProtokollVersion == 0
                mBlockTime = datevec(fread(fid, 9, '*char', cMachineFormat{:})','HHMMSSFFF');
            else
                mBlockTime = datevec(fread(fid, 16, '*char', cMachineFormat{:})','yymmdd_HHMMSSFFF');
                if ProtokollVersion >= 3
                    stInfo.SystemTime = datevec(fread(fid, 16, '*char', cMachineFormat{:})','yymmdd_HHMMSSFFF');
                else
                    stInfo.SystemTime = mBlockTime;
                end
            end
            stInfo.calibrationInDb = [0 0];
            if ProtokollVersion >= 2
                stInfo.calibrationInDb = [double(fread(fid, 1, 'float32', cMachineFormat{:})) double(fread(fid, 1, 'float32', cMachineFormat{:}))];
            end 
            stInfo.AndroidID = '';
            stInfo.BluetoothTransmitterMAC = '';
            stInfo.TransmitterSamplingrate = -1;
            if ProtokollVersion >= 4
                stInfo.AndroidID = strtrim(fread(fid, 16, '*char', cMachineFormat{:})');
                stInfo.BluetoothTransmitterMAC = strtrim(fread(fid, 17, '*char', cMachineFormat{:})');
            end
            if ProtokollVersion >= 5
                stInfo.TransmitterSamplingrate = double(fread(fid, 1, 'float32', cMachineFormat{:}));
            end
            stInfo.nBytesHeader = ftell(fid);
            stInfo.ProtokollVersion = ProtokollVersion;
            %             mBlockTime = datevec(fread(fid, 9, '*char', cMachineFormat{:})','HHMMSSFFF');
            fseek(fid, vFrames(1)*nDim*4, 0);
        else
            try
                vFrames(nBlocks+1) = double( fread( fid, 1, 'int32', cMachineFormat{:}) );
                fseek(fid, 16, 0);
                if ProtokollVersion == 0
                    mBlockTime(nBlocks+1,:) = datevec(fread(fid, 9, '*char', cMachineFormat{:})','HHMMSSFFF');
                else
                    mBlockTime(nBlocks+1,:) = datevec(fread(fid, 16, '*char', cMachineFormat{:})','yymmdd_HHMMSSFFF');
                end
                fseek(fid, vFrames(nBlocks+1)*nDim*4, 0);
                %
            catch
                break;
            end
        end
        
        nBlocks = nBlocks + 1;
        
    end
    
    fclose( fid );
    
    % add correct date to blocktime
    [~, szFilename] = fileparts(szFilename);
    if ProtokollVersion == 0
        vDate = datevec( szFilename(5:end), 'yyyymmdd' ); %+7 f�r neue
        mBlockTime(:,1:3) = repmat(vDate(1:3),size(mBlockTime,1),1);
    end
    stInfo.nDimensions = nDim; % including time
    stInfo.nBlocks = nBlocks;
    stInfo.StartTime = mBlockTime;
    stInfo.nFramesPerBlock = vFrames(1);
    stInfo.nFrames = sum(vFrames);
    stInfo.vFrames = vFrames;
    
    % Safety net to catch exceptionally high frame numbers - probably
    % overflow during write process?
    if (stInfo.nFrames>60*stInfo.fs)
        if contains(szFilename, 'PSD')
            stInfo.nFrames = 480;
            stInfo.nFramesPerBlock = 480;
            stInfo.vFrames = 480;
        elseif contains(szFilename, 'RMS')
            stInfo.nFrames = 4800;
            stInfo.nFramesPerBlock = 4800;
            stInfo.vFrames = 4800;
        elseif contains(szFilename, 'ZCR')
            stInfo.nFrames = 4800;
            stInfo.nFramesPerBlock = 4800;
            stInfo.vFrames = 4800;
        elseif contains(szFilename, 'VTB')
            stInfo.nFrames = 15000;
            stInfo.nFramesPerBlock = 15000;
            stInfo.vFrames = 15000;
        end
        warning('feature file %s is corrupt. Assuming standard length.',szFilename);
    end
    
    stInfo.BlockSizeInSamples = (vFrames(1)-1) * stInfo.HopSizeInSamples + stInfo.FrameSizeInSamples;
    stInfo.mBlockTime = mBlockTime;
    
    % continuity analysis, find pauses longer than blocksize/10
    BlockSizeInSeconds = stInfo.BlockSizeInSamples / stInfo.fs;
    idx = [1; diff(datenum(mBlockTime)*24*60*60) > BlockSizeInSeconds + (BlockSizeInSeconds/10); size(mBlockTime,1)];
    
    resIdx = 1;
    
    if idx(2)
        resIdx(end+1) = 1;
    end
    
    for kk = 2:length(idx)-1
        if idx(kk)
            if idx(kk+1)
                resIdx(end+[1:2]) = deal(kk);
            else
                resIdx(end+1) = kk;
            end
        elseif ~idx(kk) && idx(kk+1)
            resIdx(end+1) = kk;
        end
    end
    
    mSessionTime = mBlockTime(resIdx,:);
    nSessions = size(mSessionTime,1)/2;
    
    if bInfo
        % show data
        fprintf('\n**************************************************************\n');
        fprintf(' Feature-File Analysis for     %s\n\n', szFilename);
        fprintf(' Feature dimensions:           %d\n', nDim-2);
        fprintf(' System Time:                  %s\n', datestr(stInfo.SystemTime,'HH:MM:SS.FFF'));
        fprintf(' Start 1st block:              %s\n', datestr(mBlockTime(1,:),'HH:MM:SS.FFF'));
        fprintf(' Start last block:             %s\n', datestr(mBlockTime(nBlocks,:),'HH:MM:SS.FFF'));
        fprintf(' Number of sessions:           %i\n', nSessions);
        fprintf(' Number of blocks:             %i\n', nBlocks);
        fprintf(' Number of frames/block:       %i\n', vFrames(1));
        fprintf(' Number of total frames:       %i\n', stInfo.nFrames);
        fprintf(' Samplingrate:                 %i Hz\n', stInfo.fs);
        fprintf(' Blocksize:                    %i Samples / %0.3f s\n', stInfo.BlockSizeInSamples, BlockSizeInSeconds);
        fprintf(' Framesize:                    %i Samples / %0.3f s\n', stInfo, stInfo.FrameSizeInSamples / stInfo.fs);
        fprintf(' Hopsize:                      %i Samples / %0.3f s\n', stInfo.HopSizeInSamples, stInfo.HopSizeInSamples / stInfo.fs);
        fprintf(' Calibration Values:           %f dB, %f dB\n', stInfo.calibrationInDb(1), stInfo.calibrationInDb(2));
        fprintf(' Android ID:                   %s\n', stInfo.AndroidID);
        fprintf(' Bluetooth Transmitter MAC:    %s\n', stInfo.BluetoothTransmitterMAC);
        fprintf(' Transmitter Samplingrate:     %s\n', stInfo.TransmitterSamplingrate);
        fprintf('\n');
        fprintf(' Session information \n\n');
        for iSession = 1:nSessions
            fprintf('   Session %i\n', iSession);
            fprintf('     First:   %s (Block #%i)\n', ...
                datestr(mSessionTime(iSession*2-1,:),'HH:MM:SS.FFF'), ...
                resIdx(iSession*2-1) );
            fprintf('     Last :   %s (Block #%i)\n', ...
                datestr(mSessionTime(iSession*2,:),'HH:MM:SS.FFF'), ...
                resIdx(iSession*2) );
            fprintf('     Blocks:  %i\n', resIdx(iSession*2) - resIdx(iSession*2-1) + 1);
            fprintf('     Frames:  %i\n', sum(vFrames(resIdx(iSession*2-1):resIdx(iSession*2))));
        end % for iSession
        fprintf('**************************************************************\n\n\n');
    end
    
else
    % If the "fopen" command has failed...
    warning('Unable to open file "%s".\n', szFilename);
end

%% Feature Header Protokoll-Version 1
% Byte  1 - Byte  4: Block Count (Integer)
% Byte  5 - Byte  8: Feature Dimensions (Integer)
% Byte  9 - Byte 12: Block Size (Integer)
% Byte 13 - Byte 16: Hop Size (Integer)
% Byte 17 - Byte 20: Samplingrate (Integer)
% Byte 21 - Byte 36: Timestamp (YYMMDD_hhmmssSSS)
% Byte 37 - EOF    : FEATRUE-DATA
% 
%% Feature Header Protokoll-Version 2
% Byte  1 - Byte  4: Protokoll Version (Integer)
% Byte  5 - Byte  8: Block Count (Integer)
% Byte  9 - Byte 12: Feature Dimensions (Integer)
% Byte 13 - Byte 16: Block Size (Integer)
% Byte 17 - Byte 20: Hop Size (Integer)
% Byte 21 - Byte 24: Samplingrate (Integer)
% Byte 25 - Byte 40: Timestamp (YYMMDD_hhmmssSSS)
% Byte 41 - Byte 44: Calibration Value in dB, Channel 1 (Float)
% Byte 45 - Byte 48: Calibration Value in dB, Channel 2 (Float)
% Byte 49 - EOF    : FEATRUE-DATA
% 
%% Feature Header Protokoll-Version 3
% Byte  1 - Byte  4: Protokoll Version (Integer)
% Byte  5 - Byte  8: Block Count (Integer)
% Byte  9 - Byte 12: Feature Dimensions (Integer)
% Byte 13 - Byte 16: Block Size (Integer)
% Byte 17 - Byte 20: Hop Size (Integer)
% Byte 21 - Byte 24: Samplingrate (Integer)
% Byte 25 - Byte 40: Sample-Timestamp (YYMMDD_hhmmssSSS)
% Byte 41 - Byte 56: SystemClock-Timestamp (YYMMDD_hhmmssSSS)
% Byte 57 - Byte 60: Calibration Value in dB, Channel 1 (Float)
% Byte 61 - Byte 64: Calibration Value in dB, Channel 2 (Float)
% Byte 65 - EOF    : FEATRUE-DATA

%% Feature Header Protokoll-Version 4
% Byte  1 - Byte  4: Protokoll Version (Integer)
% Byte  5 - Byte  8: Block Count (Integer)
% Byte  9 - Byte 12: Feature Dimensions (Integer)
% Byte 13 - Byte 16: Block Size (Integer)
% Byte 17 - Byte 20: Hop Size (Integer)
% Byte 21 - Byte 24: Samplingrate (Integer)
% Byte 25 - Byte 40: Sample-Timestamp (YYMMDD_hhmmssSSS)
% Byte 41 - Byte 56: SystemClock-Timestamp (YYMMDD_hhmmssSSS)
% Byte 57 - Byte 60: Calibration Value in dB, Channel 1 (Float)
% Byte 61 - Byte 64: Calibration Value in dB, Channel 2 (Float)
% Byte 65 - Byte 80: Android ID
% Byte 81 - Byte 97: Bluetooth Transmitter MAC
% Byte 98 - EOF    : FEATRUE-DATA

%% Feature Header Protokoll-Version 5
% Byte  1 - Byte  4: Protokoll Version (Integer)
% Byte  5 - Byte  8: Block Count (Integer)
% Byte  9 - Byte 12: Feature Dimensions (Integer)
% Byte 13 - Byte 16: Block Size (Integer)
% Byte 17 - Byte 20: Hop Size (Integer)
% Byte 21 - Byte 24: Samplingrate (Integer)
% Byte 25 - Byte 40: Sample-Timestamp (YYMMDD_hhmmssSSS)
% Byte 41 - Byte 56: SystemClock-Timestamp (YYMMDD_hhmmssSSS)
% Byte 57 - Byte 60: Calibration Value in dB, Channel 1 (Float)
% Byte 61 - Byte 64: Calibration Value in dB, Channel 2 (Float)
% Byte 65 - Byte 80: Android ID
% Byte 81 - Byte 97: Bluetooth Transmitter MAC
% Byte 98 - Byte 101: Transmitter Samplingrate (Float)
% Byte 102 - EOF    : FEATRUE-DATA

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
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
% eof
