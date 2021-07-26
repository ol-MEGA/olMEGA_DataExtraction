function vProceed = myPostProcessing(vPredicted, nSchutz)
% function to post process prediction results
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 21-Apr-2021 	JP

if nargin == 1 % easy version
    vProceed = vPredicted;
    
    idx = 1:3;
    
    while max(idx) < length(vProceed)
        if sum(vProceed(idx([1 3]))) == 2 % surrounded by OVS
            vProceed(idx(2)) = 1;
            %     elseif sum(vProceed(idx([1 3]))) == 0 % surrounded by no OVS
            %         vProceed(idx(2)) = 0;
        end
        idx = idx + 1;
    end
else % apply schutzintervall
    
    % get voice indices
    vIdxVS = find(vPredicted == 1);
    
    vProceed = zeros(size(vPredicted));
    
    % apply Schutzintervall
    vIdxSchutz = unique(vIdxVS + [-nSchutz:nSchutz]); % +-
    vIdxSchutz(vIdxSchutz <= 0) = [];
    vIdxSchutz(vIdxSchutz > length(vPredicted)) = [];
    
    vProceed(vIdxSchutz) = 1; 
end