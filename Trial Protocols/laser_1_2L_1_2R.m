function exp = laser_1_2L_1_2R(laserDistribution, laserParams)

    
    exp.protocolName      = 'laser_1_2L_1_2R';
    exp.laserDistribution = laserDistribution;
    exp.laserDistributionName = func2str(laserDistribution);
    exp.laserParams      = laserParams;
    exp.nullEpochs   = [1,3];
    exp.leftEpochs   = [2];
    exp.rightEpochs  = [4];
    
    setLaserOff = {@setLaserDistribution,{@laserOff,[]}};
    setLaserL   = {@setLaserDistribution,{laserDistribution,[laserParams(1), laserParams(2)]}};
    setLaserR   = {@setLaserDistribution,{laserDistribution,[laserParams(2), laserParams(1)]}};
    
% Times in minutes
    exp.protocolDesign = {...
        % Time (min), Odor left, odor right, laser left, laser right
[   0, setLaserOff];...
[   1, setLaserL];...
[   3, setLaserOff];...
[   4, setLaserR];...
[   6, setLaserOff];...

};

    exp.nEpochs = size(exp.protocolDesign,1) - 1;


