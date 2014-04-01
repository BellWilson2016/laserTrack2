function setColorSwitch(csArray)

global trackingParams;

cs1 = sum(bitshift(csArray(1:4),[0 2 4 6]));
cs2 = sum(bitshift(csArray(5:8),[0 2 4 6]));

trackingParams.colorSwitch = [cs1,cs2];
