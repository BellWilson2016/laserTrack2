% setAvg.m
%
% Sets whether the algorithm is updating it's running avg (true) or 
% freezing the running avg. (false).
%
% JSB 11/2010
function setAvg(trueOrFalse)

    global trackingParams;
    
    trackingParams.updateAvg = trueOrFalse;