function exp = laser_1_2L_1_2R(laserDistribution, laserParams)

    laserParams1     = laserParams(1);
    laserParams2     = laserParams(2);
    
    exp.protocolName      = 'laser_1_2L_1_2R';
    exp.laserDistribution = laserDistribution;
    exp.laserDistributionName = func2str(laserDistribution);
    exp.laserParams1      = laserParams1;
    exp.laserParams2      = laserParams2;
    exp.nullEpochs   = [1,3];
    exp.leftEpochs   = [2];
    exp.rightEpochs  = [4];
    
    setLaserOff = {@setLaserDistribution,{@laserOff,[]}};
    setLaserL   = {@setLaserDistribution,{laserDistribution,[laserParams1, laserParams2]}};
    setLaserR   = {@setLaserDistribution,{laserDistribution,[laserParams2, laserParams1]}};
    
% Times in minutes
    exp.protocolDesign = {...
        % Time (min), Odor left, odor right, laser left, laser right
[   0, setLaserOff];...
[   1, setLaserL];...
[   3, setLaserOff];...
[   4, setLaserR];...
[   6, setLaserOff];...

};

    exp.nEpochs = size(exp.protocolDesign,1);


