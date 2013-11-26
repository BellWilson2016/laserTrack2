function runLaserProtocol(exp)

	runString = ['Running protocol: ',func2str(exp.protocol)];
	disp(runString);
	pushNow = false;
	updateWebStatus(runString,pushNow);

    global trackingParams;

	% Unpack the protocol by running its handle
    exp = feval(exp.protocol, exp);

	% Store a copy of the tracking parameters
    exp.trackingParams = trackingParams;     
  
	% Clear the recording buffers
	trackingParams.recording = false;
	trackingParams.recordingSerial = false;
	trackingParams.tempData = [];
	trackingParams.serialRecord = [];

    epoch = 1;
    startEpoch(exp, epoch);
    
%%   
function startEpoch(exp, epochN)
        
		global trackingParams;

        % Grab what to do now
        protocolFrame = exp.protocolDesign{epochN};
        endFrame = exp.protocolDesign{end};
        
        disp(['Starting epoch: ',num2str(epochN),' of ',num2str(exp.nEpochs),...
            ' at minute ',num2str(protocolFrame{1}),' of ',...
            num2str(endFrame{1})]);
                      
        % Execute all the commands in the list
        nCommands = (size(protocolFrame,2)-1)/2;
        for n = 1:nCommands
            cmd = protocolFrame{2*(n-1)+2};
            args = protocolFrame{2*(n-1)+3};
            feval(cmd,args);
        end

        % Set recording on.
		trackingParams.recording = true;
		trackingParams.recordingSerial = true;
     
        % Figure out how long to wait before finishing the epoch
        startTime = protocolFrame{1};
        endFrame = exp.protocolDesign{epochN+1};
        endTime = endFrame{1};
        lengthToRun = 60*(endTime - startTime);
        
		% Start a timer to finish up the epoch
        finishEpochTimer = timer('ExecutionMode','singleShot',...
            'StartDelay',lengthToRun,...
            'TimerFcn',{@finishEpoch, exp, epochN});  

        start(finishEpochTimer);

        
%%    
function finishEpoch(obj, event, exp, epochN)
       
    	global trackingParams;    
      
		% If there's another epoch to do, do it
		% Temember there are n+1 entries for nEpochs
        if (epochN + 1 <= exp.nEpochs)

			% Log data outof the temporary buffer, clear it.
		    exp.epoch(epochN).rawTrack = trackingParams.tempData(1:end,1:6,:);
			trackingParams.tempData = [];
			exp.epoch(epochN).serialRecord = trackingParams.serialRecord;
			trackingParams.serialRecord = [];

            % Do another epoch
            startEpoch(exp, epochN + 1);
        else % Finish up     

			% Stop updating the data buffers
			% Log data outof the temporary buffer, clear it.
			trackingParams.recording = false;
		    exp.epoch(epochN).rawTrack = trackingParams.tempData(1:end,1:6,:);
			trackingParams.tempData = [];
			% Wait to unload the serial buffer...
            
			% Get the last frame of the protocol
		    protocolFrame = exp.protocolDesign{epochN+1};
		    % Execute all the commands in the list
		    nCommands = (size(protocolFrame,2)-1)/2;
		    for n = 1:nCommands
		    	cmd = protocolFrame{2*(n-1)+2};
		    	args = protocolFrame{2*(n-1)+3};
		    	feval(cmd,args);
		    end

			% Pause to allow serial buffers to empty
			pause(.5);
			trackingParams.recordingSerial = false;
			exp.epoch(epochN).serialRecord = trackingParams.serialRecord;
			trackingParams.serialRecord = [];  

			% Notify of finish
			disp('Finishing up protocol...');
			disp(' ');
			% Synchronize clocks and concatenate data epochs.
			exp = catSyncTracks(exp);

		    % Save data
		    filename = ['RTFW',datestr(now,'yymmdd'),'/','RTFW', datestr(now,'yymmdd'),'-',datestr(now,'HHMMSS'),'.mat'];
		    expName  = exp.experimentName;
			% Use evalc to suppress commandline output
			T = evalc('saveExperimentData(expName,filename, ''exp'')');
			listRecent(0);

			% Update website
			runString = ['Finished protocol, wrote: ',num2str(nextFileNumber() - 1)];
			pushNow = false;
			updateWebStatus(runString,pushNow);
		end


%%

        



    
    

