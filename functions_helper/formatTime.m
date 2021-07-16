function cDates = formatTime(vDates)

% Function that receives a value in milliseconds and outputs a formatted
% string containing hours and minutes (unless minutes is zero)

nDates = length(vDates);
cDates = cell(nDates, 1);


for iDate = 1 : nDates
    
    nHours = floor(vDates(iDate) / (60 * 60 * 1000));
    nMinutes = floor(floor(vDates(iDate) - nHours * 60 * 60 * 1000) / (60 * 1000));
    
    cDates{iDate} = sprintf('%dh%dm', nHours, nMinutes);
    
end

end