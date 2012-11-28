function zoneOut(c)

global trackingParams;

trackingParams.runningAvg((c(1,1):c(2,1)),(c(1,2):c(2,2))) = 255;

