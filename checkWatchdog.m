function checkWatchdog(obj, event)
	
	global trackingParams;

	% Don't update the tracking parameters during latency critical segments.
	if trackingParams.bestLatency
		return;
	end
	
	WDS = getWatchdogStatus();
	trackingParams.WDS = WDS;
	if (WDS.statusByte == 0)
		disp(['Watchdog ok, Mirrors @ ',num2str(WDS.mirrorTemp,'% 10.2f'),' C, Room @ ',num2str(WDS.roomTemp,'% 10.2f'),' C']);
	end	
