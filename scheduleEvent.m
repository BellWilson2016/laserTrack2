function scheduleEvent(timeDelay, cmdToRun);

	global allScheduledEvents;

	disp(['scheduleEvent() for ',num2str(timeDelay/60),' (min) =>  ',cmdToRun,]);

	nEvents = size(allScheduledEvents,2);
	allScheduledEvents(end+1) = timer('ExecutionMode','singleShot',...
					'Period', timeToRun,...
					'TimerFcn', {@doLater,cmdToRun,nEvents + 1});
	start(allScheduledEvents(nEvents + 1));

	

function doLater(obj,event,cmdToRun,eventN)
	
	global allScheduledEvents;

	totalEvents = size(allScheduledEvents,2);

	disp(['scheduleEvent() is running event #',num2str(eventN),' of ',num2str(totalEvents)]);
	eval(cmdToRun);

	
