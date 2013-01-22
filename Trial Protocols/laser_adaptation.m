function exp = laser_adaptation(exp)
   
	laserDistribution = exp.protocolArgs{1};
	laserParams       = exp.protocolArgs{2};

    exp.laserDistribution = laserDistribution;
    exp.laserParams       = laserParams;
    exp.nullEpochs   = [1,2,3,5,6];
    exp.leftEpochs   = [4];
	exp.rightEpochs  =  [];
  
    setLaserOff = {@setLaserDistribution,{@laserOff,[]}};
	setLaserAll = {@setLaserDistribution,{laserDistribution,[48, 48]}};
    setLaserL   = {@setLaserDistribution,{laserDistribution,[laserParams(1), laserParams(2)]}};
    setLaserR   = {@setLaserDistribution,{laserDistribution,[laserParams(2), laserParams(1)]}};
    
	delayTime = laserParams(3);

% Times in minutes
    exp.protocolDesign = {...
        % Time (min), Odor left, odor right, laser left, laser right
[   0, setLaserOff];...
[   1, setLaserAll];...
[   1.5, setLaserOff];...
[   1.5 + delayTime, setLaserL];...
[   1.5 + delayTime + .5, setLaserOff];...
[   1.5 + delayTime + .5 + 1, setLaserOff];...


};

    exp.nEpochs = size(exp.protocolDesign,1)-1;


