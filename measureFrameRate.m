function measureFrameRate()

	global trackingParams;
	
	trackingParams.measureFrameRate = true;
	trackingParams.frameLengthList = [];
	measureTime = 5;
	
	TF = timer('ExecutionMode','singleShot','StartDelay',measureTime,'TimerFcn', @finishFrameRate);
	start(TF);
	disp('Measuring real frame rate for 5 sec ...');
	
	
function finishFrameRate(obj,event)

	global trackingParams;
	
	trackingParams.measureFrameRate = false;
	
	
	figure;
	hist(trackingParams.frameLengthList(2:end),[0:.001:.1]);
	set(gca,'XTick',[1/80,1/60,1/50,1/40,1/30,1/25,1/20,1/15]);
	set(gca,'XTickLabel',{'80','60','50','40','30','25','20','15'});
	
	trackingParams.frameLengthList = [];
