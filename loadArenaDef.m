function loadArenaDef()

global trackingParams;

load('savedParams.mat');


trackingParams.laneCenterX = savedParams.laneCenterX;
trackingParams.laneCenteY = savedParams.laneCenterY;
trackingParams.pxPerMM = savedParams.pxPerMM;
trackingParams.reg = savedParams.reg;
trackingParams.xTarget = savedParams.xTarget;
trackingParams.yTarget = savedParams.yTarget;
trackingParams.bodyX = savedParams.bodyX;
trackingParams.bodyY = savedParams.bodyY;
trackingParams.nPixels = savedParams.nPixels;
trackingParams.power = savedParams.power;
trackingParams.calPoints = savedParams.calPoints;
trackingParams.calMarks = savedParams.calMarks;
