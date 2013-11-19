function exp = laser_adaptation2(exp)
   
	laserDistribution = exp.protocolArgs{1};
	laserParams       = exp.protocolArgs{2};

	powerL = laserParams(1);
	powerR = laserParams(2);
	adaptDelay = laserParams(3);
	adaptPower = laserParams(4);

    exp.laserDistribution = laserDistribution;
    exp.laserParams       = laserParams;
    exp.nullEpochs   = [1,3,5];
    exp.leftEpochs   = [4];
	exp.rightEpochs  =  [];

  
    setLaserOff = {@setLaserDistribution,{@laserOff,[]}};
	setLaserAll = {@setLaserDistribution,{laserDistribution,[adaptPower, adaptPower]}};
    setLaserL   = {@setLaserDistribution,{laserDistribution,[powerL, powerR]}};
    


% Times in minutes
    exp.protocolDesign = {...
        % Time (min), Odor left, odor right, laser left, laser right
[   0, setLaserOff];...
[  .5, setLaserAll];...
[   1, setLaserOff];...
[   1 + adaptDelay, setLaserL];...
[   1 + adaptDelay + .5, setLaserOff];...
[   1 + adaptDelay +  1, setLaserOff];...

};

    exp.nEpochs = size(exp.protocolDesign,1)-1;


