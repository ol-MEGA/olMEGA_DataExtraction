clear
close all

szBasePath = 'C:\Users\ju1064\Documents\Data REAL-HEARING';

addpath(genpath('C:\Users\ju1064\Documents\olMEGA_DataExtraction'));
addpath(szBasePath);

szUserPath = 'p001p002_220503_sv';

% get object
[obj] = olMEGA_DataExtraction([szBasePath filesep szUserPath]);

%% determine sample rate and time correction
szFeature = 'PSD';

% get feature dates
[dateVecAllFeat] = showAvailableFeatureDataOneTestSubject(obj, szFeature);
dateVecDayOnly= dateVecAllFeat-timeofday(dateVecAllFeat);

for curDate = obj.stAnalysis.Dates
    PartCounter = 0;
    idxDay = find(dateVecDayOnly == curDate);
    if ~isempty(idxDay) && length(idxDay) > 1
        % get time difference between files in minutes
        dtMinutes = minutes(diff(dateVecAllFeat(idxDay)));

        % detect continuous segments or interruptions
        idxSeg = find(dtMinutes > 1.1);
        if isempty(idxSeg)
            [nSampleRate, vShift]=determineSampleRate(obj,szFeature,'startDay',curDate);
        else
            % append beginning and end
            idxSeg = [0 idxSeg length(dateVecDayOnly)];

            % loop over all parts
            for pp = 1:length(idxSeg)-1
                PartCounter = PartCounter+1;
                startTime = timeofday(dateVecAllFeat(idxSeg(pp)+1));
                endTime = timeofday(dateVecAllFeat(idxSeg(pp+1)));
                [nSampleRate, vShift]=determineSampleRate(obj,szFeature, ...
                    'startDay',curDate, 'startTime', startTime, 'endTime', endTime);
            end
        end
    end
end

%% plot
% figure;
% plot(vShift);
% datetickzoom(gca,'y','MM:SS');
% ylim([vShift(1) vShift(end)]);
% xlabel('# feature file');
% ylabel('time shift MM:SS');
% title('BlockTime - SystemTime');
% grid on;
