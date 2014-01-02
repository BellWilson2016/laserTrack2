function exp = laser_1_halfL_1(exp)
   
	laserDistribution = exp.protocolArgs{1};
	laserParams       = exp.protocolArgs{2};

    exp.laserDistribution = laserDistribution;
    exp.laserParams       = laserParams;
    exp.nullEpochs   = [1,3];
    exp.leftEpochs   = [2];
	exp.rightEpochs  =  [];
  
    setLaserOff = {@setLaserDistribution,{@laserOff,[]}};
    setLaser   = {@setLaserDistribution,{laserDistribution,laserParams}};
    
% Times in minutes
    exp.protocolDesign = {...
        % Time (min), Odor left, odor right, laser left, laser right
[   0, setLaserOff];...
[   1, setLaser];...
[   1.5, setLaserOff];...
[   2.5, setLaserOff];...


};

    exp.nEpochs = size(exp.protocolDesign,1)-1;


