function exp = laser_preAdapt(exp)
   
	laserDistribution = exp.protocolArgs{1};
	laserParams       = exp.protocolArgs{2};

    exp.laserDistribution = laserDistribution;
    exp.laserParams       = laserParams;
    exp.nullEpochs   = [1,3,5];
    exp.leftEpochs   = [2,6];
	exp.rightEpochs  =  [4];
  
    setLaserOff = {@setLaserDistribution,{@laserOff,[]}};
    setLaserL   = {@setLaserDistribution,{laserDistribution,[laserParams(1), laserParams(2)]}};
    setLaserR   = {@setLaserDistribution,{laserDistribution,[laserParams(2), laserParams(1)]}};
    
% Times in minutes
    exp.protocolDesign = {...
        % Time (min), Odor left, odor right, laser left, laser right
[   0, setLaserOff];...
[  .5, setLaserL];...
[   1, setLaserOff];...
[ 1.5, setLaserR];...
[   2, setLaserOff];...
[ 2.5, setLaserL];...
[   3, setLaserOff];...


};

    exp.nEpochs = size(exp.protocolDesign,1)-1;


