function scheduleEvent(timeDelay, cmdToRun);

	global allScheduledEvents;

	disp(['scheduleEvent() for ',num2str(timeDelay/60),' (min) =>  ',cmdToRun]);

	nEvents = size(allScheduledEvents,2);
	allScheduledEvents{end+1} = nEvents + 1;
	aTimer = timer('ExecutionMode','singleShot',...
					'StartDelay', timeDelay,...
					'TimerFcn', {@doLater,cmdToRun,nEvents + 1});
	start(aTimer);
	

function doLater(obj,event,cmdToRun,eventN)
	
	global allScheduledEvents;

	totalEvents = size(allScheduledEvents,2);

	disp(['scheduleEvent() #',num2str(eventN),' of ',num2str(totalEvents),...
					'  =>  ',cmdToRun]);
	feval(cmdToRun{1},cmdToRun{2});


	
