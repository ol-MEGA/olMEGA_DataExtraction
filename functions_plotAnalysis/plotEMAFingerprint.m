function [] = plotEMAFingerprint(obj, varargin)
% function to plot a fingerprint for a specific time frame
% analyse data recorded with olMEGA
% shows results of Own Voice Detection (OVD) 
% Usage: plotEMAFingerprint(obj, varargin)
%
% Parameters
% ----------
% obj : class olMEGA_DataExtraction, contains all informations
%
% varargin :  specifies optional parameter name/value pairs.
%             getObjectiveData(obj 'PARAM1', val1, 'PARAM2', val2, ...)
%  'StartTime'          duration to specify the start time of desired data
%                       syntax duration(H,MI,S);
%                       or a number between [0 24], which will be 
%                       transformed to a duration;
%
%  'EndTime'            duration to specify the end time of desired data
%                       syntax duration(H,MI,S);
%                       or a number between [0 24], which will be 
%                       transformed to a duration; 
%                       obviously EndTime should be greater than StartTime;
%
%  'StartDay'           to specify the start day of desired data, allowed
%                       formats are datetime, numeric (i.e. 1 for day one),
%                       char (i.e. 'first', 'last')
%
%  'EndDay'             to specify the end day of desired data, allowed
%                       formats are datetime, numeric (i.e. 1 for day one),
%                       char (i.e. 'first', 'last'); obviously EndDay 
%                       should be greater than or equal to StartDay;
%
%  'stInfo'             struct which contains valid date informations about 
%                       the aboved named 4 parameters; this struct results 
%                       from calling checkInputFormat.m
%
%  'PlotWidth'          number that speciefies the width of the desired 
%                       figure in pixels; by default it is set to full 
%                       screen
%
%  'SamplesPerPixel'    number that speciefies the data point resolution in
%                       samples per pixel; by default it is 5 samples/pixel
%
% 'HigherFreqResolution' logical whether to plot with a low frequency 
%                        resolution (=false) or with the highest possible
%                        frequency resolution (=true)
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% based on:  main.m and plotAllDayFingerprints.m,
% mainly computeDayFingerprintData.m by Nils Schreiber
% Version History:
% Ver. 1.0 updated version 26-May-2021  JP

% define figure width to full screen in pixels
stRoots = get(0);
% default plot width in pixels
iDefaultPlotWidth = stRoots.ScreenSize(3);

% default plot resolution in samples (data points) per pixel
iDefaultSamplesPerPixel = 5;

% parse input arguments
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('obj', @(x) isa(x,'olMEGA_DataExtraction') && ~isempty(x));

p.addParameter('StartTime', 0, @(x) isduration(x) || isnumeric(x));
p.addParameter('EndTime', 24, @(x) isduration(x) || isnumeric(x));
p.addParameter('StartDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('EndDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('PlotWidth', iDefaultPlotWidth, @(x) isnumeric(x));
p.addParameter('SamplesPerPixel', iDefaultSamplesPerPixel, @(x) isnumeric(x));
p.parse(obj,varargin{:});

% Re-assign values
iPlotWidth = p.Results.PlotWidth;
iSamplesPerPixel = p.Results.SamplesPerPixel;

% call function to check input date format and plausibility
stInfo = checkInputFormat(obj, p.Results.StartTime, p.Results.EndTime, ...
    p.Results.StartDay, p.Results.EndDay);


%% lets start with reading objective data
disp('*** importing olMEGA data');

% desired feature PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD,vTimePSD,stInfoFile] = getObjectiveData(obj, szFeature, 'stInfo', stInfo, ...
    'PlotWidth',iPlotWidth, 'SamplesPerPixel', iSamplesPerPixel, 'useCompression', true);


version = 1; % JP modified get_psd
[Cxy,Pxx,Pyy] = get_psd(DataPSD, version);
% clear DataPSD;
Cohe = Cxy./(sqrt(Pxx.*Pyy) + eps);

% set frequency specific parameters
fs = stInfoFile.fs;
nFFT = (stInfoFile.nDimensions - 2 - 4)/2;
vFreq = 0 : fs/nFFT : fs/2;
vFreqRange  = [400 1000]; % frequency range in Hz
vFreqIdx = round(nFFT*vFreqRange./fs);

% averaged Coherence
MeanCohe = mean(real(Cohe(:,vFreqIdx(1):vFreqIdx(2))),2);

CohTimeSmoothing_s = 0.1;
fs_cohdata = 1/0.125;

alpha = exp(-1./(CohTimeSmoothing_s*fs_cohdata));
MeanCoheTimeSmoothed = filter([1-alpha], [1 -alpha], MeanCohe);


% desired feature RMS
szFeature = 'RMS';

% get all available feature file data
[mRMS,vTimeRMS] = getObjectiveData(obj, szFeature, 'stInfo', stInfo, ...
    'PlotWidth',iPlotWidth, 'SamplesPerPixel', iSamplesPerPixel, 'useCompression', false);

% convert to dB SPL just one channel
vLevel = 20*log10(mRMS(:, 1)); 

% calculate 5min Level
disp('*** calculate blockwise level');
nBlockSize = 5; % min
[mPercLevel,~,vTimeBlock] = calcMeanLevel(vLevel,nBlockSize,[],vTimeRMS);
vTimeBlock = datenum(vTimeBlock);


%% VOICE DETECTION: predict voice sequences with a trained random forest
disp('*** voice detection: feature extraction and prediction');

% check for 1h intervalls
nHours = hours(stInfo.EndTime - stInfo.StartTime);

if nHours > 1
    stDate = stInfo;
    stDate.EndTime = stDate.StartTime + duration(1, 0, 0);
    
    % do calculation for 1h intervalls
    vOVS = [];
    vTime = [];
    for ii = 1:ceil(nHours)
        [vOVSTemp, vTimeTemp] = detectOwnVoiceRandomForest(obj, stDate);
        vOVS = [vOVS; vOVSTemp];
        vTime = [vTime; vTimeTemp];
        
        % adjust time frame
        stDate.StartTime = stDate.StartTime + duration(1, 0, 0.1);
        stDate.EndTime = stDate.EndTime + duration(1, 0, 0);
    end
else
    [vOVS, vTime] = detectVoiceRandomForest(obj, stInfo);
end

% add post processing
vOVS = myPostProcessing(vOVS, 1);


%% plot objective Data
disp('*** plotting...');
% define figure height full screen in pixels
iPlotHeight = stRoots.ScreenSize(4)*0.75;

figure('PaperPosition',[0 0 1 1],'Position',[1 stRoots.ScreenSize(4)-iPlotHeight iPlotWidth iPlotHeight]);
GUI_xStart = 0.075;
GUI_xAxesWidth = 0.9;
mTextTitle = uicontrol(gcf,'style','text');
if stInfo.StartDay ~= stInfo.EndDay
    szTitle = [obj.stSubject.Name ' ' datestr(stInfo.StartDay) ' : ' datestr(stInfo.EndDay)];
else
    szTitle = [obj.stSubject.Name ' ' datestr(stInfo.StartDay)];
end
set(mTextTitle,'Units','normalized','Position', [0.2 0.93 0.6 0.05], 'String', szTitle,'FontSize',16);


%% Pxx
% find time gaps and fill them with NaNs
PxxLog = 10*log10(abs(Pxx))';

% define minimum value for plotting reasons
minPxx = -70;
PxxLog(PxxLog < minPxx) = minPxx;
[vTimeGaps, PxxLog, hasGap] = FillTimeGaps(vTimePSD, PxxLog);
vTimeGaps = datenum(vTimeGaps);

axPxx = axes('Position',[GUI_xStart 0.3 GUI_xAxesWidth 0.26]);
imagesc(vTimeGaps,vFreq,PxxLog);
axis xy;
ylim([0 8000]);
ylabel('frequency in Hz');
c = colorbar;
ylabel(c, 'PSD in dB');
yaxisLabels = strrep(axPxx.YTickLabel,'000', 'k');
yaxisLabels = strrep(yaxisLabels, 'kk', '0k');
set(axPxx,'CLim',[minPxx-5 20],'XTickLabel',[],'YTickLabel',yaxisLabels);
if hasGap
    axPxx.Colormap = parula(256); % increase resolution of colormap
    axPxx.Colormap(1,:) = [1 1 1]; % set darkest blue to white for time gaps
end
drawnow;
vPosition = get(axPxx,'Position');


%% Level
axRMS = axes('Position',[GUI_xStart 0.06 vPosition(3) 0.22]);
hold on;
% find gaps
vDiff = diff(~isnan(mPercLevel(:, 1)));
idxOn = find(vDiff == 1) + 1;
idxOff = find(vDiff == -1);
if length(idxOn) < length(idxOff)
    idxOn = [1; idxOn];
elseif length(idxOff) < length(idxOn)
    idxOff = [idxOff; size(mPercLevel, 1)];
elseif any(idxOff < idxOn) || (isempty(idxOn) && isempty(idxOff))
    idxOn = [1; idxOn];
    idxOff = [idxOff; size(mPercLevel, 1)];
end
for jj = 1:length(idxOn) % plot each patch
    idx = idxOn(jj):idxOff(jj);
    vT = [vTimeBlock(idx) fliplr(vTimeBlock(idx))];
    patch(vT, [mPercLevel(idx, 1)' fliplr(mPercLevel(idx, 3)')], 'b', 'FaceAlpha', .3, 'EdgeColor', 'none');
end
plot(vTimeBlock, mPercLevel(:, 2), 'b-', 'LineWidth', 1.2);

ylim([30 100]);
yticks([30 50 70 90]);
axRMS.YLabel = ylabel('L_{5min} in dB SPL');
axRMS.XLabel = xlabel('time in HH:MM');
set(axRMS, 'YGrid', 'on', 'YMinorTick', 'on', 'YMinorGrid', 'on')
datetickzoom(axRMS,'x','HH:MM');
xlim(vTimeGaps([1 end]));


%% Results Voice Detection
vOVS = double(vOVS);
vOVS(vOVS == 0) = NaN;

% find time gaps and fill them with NaNs
[~, MeanCoheTimeSmoothed] = FillTimeGaps(vTimePSD, MeanCoheTimeSmoothed');

axOVD = axes('Position',[GUI_xStart 0.7 vPosition(3) 0.22]);
hold on;
plot(vTimeGaps, MeanCoheTimeSmoothed, 'k');
% view estimated own voice sequences (red)
plot(datenum(vTime), 1.1*vOVS, 'r', 'LineWidth', 10);
axOVD.YLabel = ylabel('avg. Re\{Coherence\}');
xlim(vTimeGaps([1 end]));
ylim ([-0.5 1.2]);
set(axOVD, 'YTick', [-0.5 0 0.5 1], 'YTickLabels', {'-0.5','0', '0.5', '1'});
axOVD.XTickLabel = [];


%% get and plot subjective data
[vTimeStamps] = getTimeStampQuest(obj);

% filter for time frame
idxTime = isbetween(vTimeStamps, vTimePSD(1), vTimePSD(end));

if ~isempty(idxTime)
    hasQuestData = true;
    vTimeStamps = datenum(vTimeStamps(idxTime));
    axQ = axes('Position',[vPosition(1) 0.58  vPosition(3) 0.1]);
    scatter(vTimeStamps, ones(size(vTimeStamps)), 30, 'filled', 'ok');
    text(vTimeStamps, 0.98*ones(size(vTimeStamps)), 'Q', 'FontSize', 14);
    xlim(vTimeGaps([1 end]));
    ylim([0.9 1.1]);
    ylabel('quest.');
    set(axQ, 'XTickLabel', [], 'YTick', []);
else
    hasQuestData = false;
end

%% assign annotation
annotationOVD =annotation(gcf,'textbox','String',{'OVD'},'FitBoxToText','off');
annotationOVD.LineStyle = 'none';
annotationOVD.FontSize = 12;
annotationOVD.Color = [1 0 0];
annotationOVD.Position = [0.96 0.89 0.0251 0.0411];


%% save figure
bPrint = 1;

set(gcf,'PaperPositionMode', 'auto');
if hasQuestData
    linkaxes([axOVD,axRMS,axPxx,axQ],'x');
    % dynamicDateTicks([axOVD,axRMS,axPxx,axQ],'linked','HH:mm');
else
    linkaxes([axOVD,axRMS,axPxx],'x');
    % dynamicDateTicks([axOVD,axRMS,axPxx],'linked');
end


if bPrint
    disp('*** export figure');
    set(0,'DefaultFigureColor','remove')
    exportName = [obj.stSubject.Folder filesep ...
        'Fingerprint_VD_Update_' obj.stSubject.Name '_' datestr(stInfo.StartDay,'yymmdd')];
    
    export_fig(exportName);
    %     saveas(gcf, exportName,'pdf')
end

disp('Finished');
%--------------------Licence ---------------------------------------------
% Copyright (c) <2021> Jule Pohlhausen
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