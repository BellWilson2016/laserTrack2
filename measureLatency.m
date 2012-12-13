function measureLatency()

	global trackingParams;

	% Frames to drop each time
	nFrames = 3;
	frameRate = 33.3;
	fileN = nextFileNumber();

	frameDropTimer = timer('ExecutionMode','fixedRate','Period',3,...
        'TimerFcn',{@dropFrameFcn, nFrames}, 'StartDelay',3,'TasksToExecute',180/3);

	doAnalysisTimer = timer('ExecutionMode','singleShot','StartDelay',190,...
		'TimerFcn',{@doAnalysisFcn,nFrames,frameRate,fileN});

	% Setup an experiment to run
	exp.experimentName = ['latencyMeasurement'];
	powerL = 0;
	powerR = 10;	
	exp.protocol	 = @laser_1_2L;
	exp.protocolArgs = {@laserFlatHalves, [powerL, powerR]};
	runLaserProtocol(exp);

	start(frameDropTimer);
	start(doAnalysisTimer);



function dropFrameFcn(obj,event,nFrames)

	setScanMode([3,nFrames,0]);

function doAnalysisFcn(obj,event,nFrames,frameRate,fileN)

	disp(fileN);

	
