function [mfcc]=calcMFCC(data, SampleRate,  nFFT, isPowerSpec, isFullBandwidth)
% function to calculate 'Mel Frequency Cepstral Coefficients'
% Calculation is based on 125ms time frames
% If input data contains the time signal, it is possible to use a
% pre-emphasis filter ('to reduce spectral roll-off of the signal'), set
% logical isPreEmphFilt to true
%
% Parameters
% ----------
%   data - vector that contains either the time signal or the power
%          spectral density (dimension: frequency x time)
%
%   SampleRate - sampling frequency in Hz
%
%   nFFT - number of fast Fourier transform points
%
%   isPowerSpec - logical whether data contains the time signal (== false)
%                 or the power spectral density (== true)
%
%   isFullBandwidth - logical whether the full bandwidth (default 
%                SampleRate/2) or just the reduced bandwidth (4kHz) is used
%
% Returns
% -------
%   mfcc - vector that contains for each time frame the 13 first MFCCs
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Source: Mfcc_LLF - low level feature implements the MFCC feature
% introduced by Davis and Mermelstein around 1980
% Version History:
% Ver. 0.01 initial create (empty) 22-Nov-2019  JP

if nargin == 4
    isFullBandwidth = true;
end

if ~isPowerSpec
    % only account for one channel
    if size(data, 2) > 1
        data = data(:, 1);
    end
    data = data(:);
    
    % calculate frame based power spectrum
    
    BlockSizeSec = 0.125;
    BlockSizeSample = round(BlockSizeSec * SampleRate);
    lOverlap = BlockSizeSample/2;
    lFeed = BlockSizeSample - lOverlap;
    nFrames = floor((size(data, 1)-lOverlap)/(lFeed));
    
    % pre allocate
    singleSidedPower = zeros(nFFT/2+1, nFrames);
    
    % Function handle of the desired window function for the DFT
    WindowFunction = @(x) hamming(x, 'periodic');
    
    % initialize all properties which depend on the sample rate
    vWindow = WindowFunction(BlockSizeSample); % Window vector
    
    % logical to use PreEmphasisFilter or not
    isPreEmphFilt = false;
    
    if isPreEmphFilt
        % following the default pre-emph. filter with alpha = 0.95@16e3
        cutoff = -log(0.95) * 16e3 / (2*pi);
        
        % Coeffs. of the pre-emphasis filter
        PreEmphasisCoefficient = exp(-2*pi * cutoff / SampleRate);
        
        % pre-emphasis filter to reduce spectral roll-off of the signal
        [data, PreEmphasisFilterStates] = filter([1, -PreEmphasisCoefficient], 1, data);
    end
    
    % loop through all time frames
    for iFrame = 1:nFrames
        
        vIDX    = ((iFrame-1)*lFeed+1):((iFrame-1)*lFeed+BlockSizeSample);
        
        % single sided power spectrum of windowed time frame
        spec = fft(data(vIDX) .* vWindow, nFFT);
        singleSidedPower(:, iFrame) = abs(spec(1:nFFT/2+1)).^2;
    end
else
    singleSidedPower = data;
end

% Number of MFC coefficients (from which IndexUsedCoefficients are picked)
NumDefaultCoefficients = 23;

% Index of the desired output coefficients
IndexUsedCoefficients = 1:13;

% frequency vector
vFreq = linspace(0, SampleRate / 2, nFFT / 2 + 1);

% Filterbank matrix
MelFilterbank = melfilter(NumDefaultCoefficients, vFreq);

if ~isFullBandwidth
    MelFilterbank = MelFilterbank(1:16, :);
    MelFilterbank(:, vFreq > 4000) = 0;
end

% transform to mel bands and account for digital zeros (bad for log(.))
melBandEnergy = MelFilterbank * singleSidedPower;
melBandEnergy(melBandEnergy == 0) = realmin;

% transform into cepstral domain using the DCT
mfcc = dct(log10(melBandEnergy));

% pick the desired coeffs
mfcc = mfcc(IndexUsedCoefficients, :);
%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> J. Pohlhausen
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