clear 
close all

szBasePath = 'C:\Users\ju1064\Documents\Data REAL-HEARING';

addpath(genpath('C:\Users\ju1064\Documents\olMEGA_DataExtraction'));
addpath(szBasePath);

szUserPath = 'p001p002_220503_sv';

% get object
[obj] = olMEGA_DataExtraction([szBasePath filesep szUserPath]);

%% get RMS
szFeature = 'RMS';

[nSampleRate, vShift]=determineSampleRate(obj,szFeature,'startDay','first', 'endDay', 'last');
%%
figure;
plot(vShift);
datetickzoom(gca,'y','MM:SS');
ylim([vShift(1) vShift(end)]);
xlabel('# feature file');
ylabel('time shift MM:SS');
title('BlockTime - SystemTime');
grid on;
