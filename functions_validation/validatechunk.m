function [errorCodes, percentErrors] = validatechunk(szChunkName,configStruct)
%VALIDATECHUNK returns whether a chunk/feature-file is valid
%
% INPUT:
%       szChunkName: string, full path of one chunk
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
%                                           the upper and lower bins of
%                                           coherence                                           that should not be exceeded
%                       .lowerThresholdCohe: threshold for the mean between
%                                           the upper and lower bins of
%                                           coherence that should not be
%                                           undercut
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
%       errorCodes: cell, contains int/vector, assessment of validation;
%                    error codes can be:
%                            0: ok
%                           -1: at least one RMS value was too HIGH
%                           -2: at least one RMS value was too LOW
%                           -3: data is mono
%                           -4: Coherence (real part) is invalid

% Author: N.Schreiber (c)
% Version History:
% Ver. 0.01 initial create (empty) 11-Dec-2017                           NS
% Ver. 0.02 added MSC validation 31-Jan-2018                             NS
% Ver. 0.03 added config struct 02-Feb-2018                              NS
% Ver. 0.04 changed MSC to real part of coherence March 2018 			 NS
% ---------------------------------------------------------

% Error codes
isTooLoud = -1;
isTooQuiet = -2;
isMono = -3;
isInvalidCoherence = -4;

errorCodes = [];
percentErrors = [];
if contains(szChunkName, 'RMS')
    [RMSFeatData]= LoadFeatureFileDroidAlloc(szChunkName);
    
    RMSFeatData = 20*log10(RMSFeatData);
    
    %
    fThresholdLoud = configStruct.upperThresholdRMS;
    fThresholdQuiet = configStruct.lowerThresholdRMS;
    
    tooLoudPercent = sum(RMSFeatData(:) > fThresholdLoud) / length(RMSFeatData(:));
    tooQuietPercent = sum(RMSFeatData(:) < fThresholdQuiet) / length(RMSFeatData(:));
    monoPercent = sum((RMSFeatData(:,1) -min(RMSFeatData(:,1)))...
        ./max((RMSFeatData(:,1) -min(RMSFeatData(:,1)))) ...
        == (RMSFeatData(:,2) -min(RMSFeatData(:,2)))...
        ./max((RMSFeatData(:,2) -min(RMSFeatData(:,2)))))...
        / length(RMSFeatData(:,1));
    
    if tooLoudPercent > configStruct.errorTolerance
        errorCodes(end+1) = isTooLoud;
        percentErrors(end+1) = tooLoudPercent;
    end
    if tooQuietPercent > configStruct.errorTolerance
        errorCodes(end+1) = isTooQuiet;
        percentErrors(end+1) = tooQuietPercent;
    end
    if monoPercent > configStruct.errorTolerance
        errorCodes(end+1) = isMono;
        percentErrors(end+1) = monoPercent;
    end
    
elseif contains(szChunkName, 'PSD')
    [PSDFeatData] = LoadFeatureFileDroidAlloc(szChunkName);
    [Cxy,Pxx,Pyy] = get_psd(PSDFeatData);
    
    % Compute the magnitude squared coherence
    Cohe = real(Cxy./(sqrt(Pxx.*Pyy) + eps));
    
    % Define parameters for plotting
    FftSize = size(Pxx,2);
    stBandDef.StartFreq = 125;
    stBandDef.EndFreq = 8000;
    stBandDef.Mode = 'onethird';
    stBandDef.fs = 16000;
    [stBandDef]=fftbin2freqband(FftSize,stBandDef);
    stBandDef.skipFrequencyNormalization = 1;
    
    % Calculate the indices of the bins over which the mean is taken
    lowBounds = ...
        floor([configStruct.lowerBinCohe configStruct.upperBinCohe]...
        .*FftSize/(stBandDef.fs/2));
    
    % Take the mean from the lower to the upper defined bin
    meanLowFreqBinsCohe = mean(Cohe(lowBounds(1):lowBounds(2),:),1);
    
    % Definition of invalidity
    invalidCoherence = (meanLowFreqBinsCohe > configStruct.upperThresholdCohe);
    invalidCoherencePercent = sum(invalidCoherence) / length(invalidCoherence);
    
    if invalidCoherencePercent > configStruct.errorTolerance
        errorCodes(end+1) = isInvalidCoherence;
        percentErrors(end+1) = invalidCoherencePercent;
    end
end

errorCodes = {errorCodes};
percentErrors = {percentErrors};


% EOF validatechunk.m