function [vMeanLevel,vOVGT,vTimeBlock] = calcMeanLevel(vLevel,nBlockSize,vLabels,vTime,useMean)
% calculate blockwise mean level, optional with OVS exclusion
% option1: use timestamps; option2 just buffer...
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Ver. 0.01 initial create 26-May-2021  JP

if nargin <= 4
    useMean = false;
end

% optional: exclude OVS
if nargin >= 3
    vLevel(vLabels == 1) = NaN;
end

if nargin >= 4
    % set params for blockwise OV
    dDurBlock = duration(0,nBlockSize,0); % min
    iFrameLen = 0.125;
   
    % define prctiles
    if useMean
        nPrctiles = 1;
    else
        vPrc = [10 50 90];
        nPrctiles = numel(vPrc);
    end

    % init
    vTimeBlock = vTime(1)+dDurBlock/2:dDurBlock/2:vTime(end)-dDurBlock/2;
    vMeanLevel = NaN(length(vTimeBlock), nPrctiles);
    vOVGT = NaN(length(vTimeBlock), 1);
    for ii = 1:length(vTimeBlock)
        idxTime = vTime >= vTimeBlock(ii)-dDurBlock/2 & vTime <= vTimeBlock(ii)+dDurBlock/2;
        if sum(idxTime) > 0
            vLevelTemp = vLevel(idxTime);
            
            % calculate mean or percentiles
            if useMean
                vMeanLevel(ii) = nanmean(vLevelTemp);
            else
                vMeanLevel(ii, :) = prctile(vLevelTemp, vPrc);
            end
            
            % count OV
            if ~isempty(vLabels)
                vOVGT(ii) = sum(vLabels(idxTime))/sum(idxTime);
            end
        end
    end
else
    iFrameLen = 0.125;
    nLen = nBlockSize/iFrameLen;
    nOverlap = nLen/2;
    
    remStart = false;
    remEnd = false;
    
    % divide into blocks with 50% overlap
    mL10 = buffer(vLevel, nLen, nOverlap);
    
    % check for too less values
    if sum(mL10(1:nOverlap, 1)) == 0
        mL10(:, 1) = [];
        remStart = true;
    end
    
    if find(mL10(:, end) ~= 0, 1, 'last') < 0.9*nLen
        mL10(:, end) = [];
        remEnd = true;
    end
    
    % calc mean
    vMeanLevel = nanmean(mL10);
    
    % optional: count OVS
    if nargout == 2
        mOV = buffer(vLabels, nLen, nOverlap);
        
        if remStart
            mOV(:, 1) = [];
        end
        if remEnd
            mOV(:, end) = [];
        end
        
        % count
        vOVGT = sum(mOV)/nLen;
    end
end