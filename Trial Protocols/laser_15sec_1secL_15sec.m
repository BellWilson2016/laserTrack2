function exp = laser_15sec_1secL_15sec(exp)
   
	laserDistribution = exp.protocolArgs{1};
	laserParams       = exp.protocolArgs{2};

    exp.laserDistribution = laserDistribution;
    exp.laserParams       = laserParams;
    exp.nullEpochs   = [1,3];
    exp.leftEpochs   = [2];
	exp.rightEpochs  =  [];
  
    setLaserOff = {@setLaserDistribution,{@laserOff,[]}};
    setLaserL   = {@setLaserDistribution,{laserDistribution,[laserParams(1), laserParams(2)]}};
    setLaserR   = {@setLaserDistribution,{laserDistribution,[laserParams(2), laserParams(1)]}};
    
% Times in minutes
    exp.protocolDesign = {...
        % Time (min), Odor left, odor right, laser left, laser right
[             0, setLaserOff];...
[           .25, setLaserL];...
[    .25+(1/60), setLaserOff];...
[.25+(1/60)+.25, setLaserOff];...


};

    exp.nEpochs = size(exp.protocolDesign,1)-1;


