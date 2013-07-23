function exp = laser_shock1_testHalf(exp)
   
	laserDistribution = exp.protocolArgs{1};
	laserParams       = exp.protocolArgs{2};

    exp.laserDistribution = laserDistribution;
    exp.laserParams       = laserParams;
    exp.nullEpochs   = [1,3,5];
    exp.leftEpochs   = [4];
	exp.rightEpochs  =  [];
	exp.trainingEpochs = [2];
  
    setLaserOff = {@setLaserDistribution,{@laserOff,[]}};
    setLaserL   = {@setLaserDistribution,{laserDistribution,[laserParams(1), laserParams(2)]}};
    setLaserR   = {@setLaserDistribution,{laserDistribution,[laserParams(2), laserParams(1)]}};

	setShockOff  = {@sendToShockController,{0,0}};
	setShockL  =   {@sendToShockController,{0,1}};
	setShockR  =   {@sendToShockController,{0,2}};

	if (laserParams(1) > laserParams(2))
		setShock = setShockR;
	else
		setShock = setShockL;
	end
    
% Times in minutes
    exp.protocolDesign = {...
        % Time (min), Odor left, odor right, laser left, laser right
[    0, setLaserOff];...
[   .5, [setLaserR,setShock]];...
[  1.5, [setLaserOff,setShockOff]];...
[    2, setLaserL];...
[  2.5, setLaserOff];...
[    3, setLaserOff];...


};

    exp.nEpochs = size(exp.protocolDesign,1)-1;


