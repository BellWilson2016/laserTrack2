function scheduleEvent(timeDelay, cmdToRun);

	global allScheduledEvents;

	dispString = ['scheduleEvent() for ',num2str(timeDelay/60),' (min) =>  ',...
					func2str(cmdToRun{1}),'()\n'];
	fprintf(dispString); % disp(cmdToRun{2});

	nEvents = size(allScheduledEvents,2);
	allScheduledEvents{end+1} = nEvents + 1;
	aTimer = timer('ExecutionMode','singleShot',...
					'StartDelay', timeDelay,...
					'TimerFcn', {@doLater,cmdToRun,nEvents + 1});
	start(aTimer);
	

function doLater(obj,event,cmdToRun,eventN)
	
	global allScheduledEvents;

	totalEvents = size(allScheduledEvents,2);

	dispString = ['scheduleEvent() #',num2str(eventN),' of ',num2str(totalEvents),...
					'  =>  ',func2str(cmdToRun{1}),':\n'];
	fprintf(dispString); disp(cmdToRun{2});
	feval(cmdToRun{1},cmdToRun{2});


	
