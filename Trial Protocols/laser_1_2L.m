function exp = laser_1_2L(laserDistribution, laserParams)

    
    exp.protocolName      = 'laser_1_2L';
    exp.laserDistribution = laserDistribution;
    exp.laserDistributionName = func2str(laserDistribution);
    exp.laserParams      = laserParams;
    exp.nullEpochs   = [1];
    exp.leftEpochs   = [2];
	exp.rightEpochs   = [];

    
    setLaserOff = {@setLaserDistribution,{@laserOff,[]}};
    setLaserL   = {@setLaserDistribution,{laserDistribution,[laserParams(1), laserParams(2)]}};
    setLaserR   = {@setLaserDistribution,{laserDistribution,[laserParams(2), laserParams(1)]}};
    
% Times in minutes
    exp.protocolDesign = {...
        % Time (min), Odor left, odor right, laser left, laser right
[   0, setLaserOff];...
[   1, setLaserL];...
[   3, setLaserOff];...


};

    exp.nEpochs = size(exp.protocolDesign,1)-1;


