%% 
%	reGen.m
%
%	This class implements dynamically updatable regenerating output for driving scan mirrors. 
%	The software buffer is dynamically updated (FIFO buffers can't be manually modified once
%	a task has started in DAQmx), and DAQmx takes care of loading the hardware FIFO.
%
%	There are 3 tasks:
%		(1) AO - Analog output for X and Y mirror positions.
%				This has its own clock and trigger.
%		(2) DO - Digital output for lasers
%				This takes its clock and trigger from AO.
%		(3) CO - Counter output for driving the camera frame rate.
%				This divides its own clock from the 100 kHz subclock. This allows the video
%				trigger to run at arbitrary frame rates that are not necessarily an even
%				multiple of the mirror rate. It triggers off of the ao/StartTrigger.
%
%	Methods:
%
%		RG = reGen()
%		RG.start()
%
%



classdef reGen < handle

	properties
		libName
		deviceName
		AOtaskHandle
		DOtaskHandle
		COtaskHandle
		repRate			= 20;	  % Hz
		sampPerRep	    = 2500;
		sampleRate
		lookAheadAO		= .02;
		lookAheadDO		= .04;	  % Write to buffer this far ahead of current point in cycle
		timeOut			= .005;	  % Seconds. 	

		videoRate  =  40;		  % Hz
		AOFIFOSize = 500;
		DOFIFOSize = 500;

		nPoints = 8;
		scanTimes = [.000500, .000230, .000230, .000230,...
					 .000230, .000230, .000230, .000230];
		preBeam1  = .000025;
		postBeam1 = .000100;
		preBeam2  = .000025;
		postBeam2 = .000100;
		beamGap   = .000050;
		simultaneousLasers = false;

		preBeam1S
		postBeam1S
		preBeam2S
		postBeam2S
		beamGapS

		scanStarts
		beam1WindowStarts
		beam1WindowEnds
		beam2WindowStarts
		beam2WindowEnds
		beamTimeEnds

	end

	methods

		function RG = reGen(deviceName)

			% Platform specific library locations
			RG.libName = 'libnidaqmx';
			libFile = [RG.libName,'.so'];
			headerFile = '/usr/local/include/NIDAQmx.h';

			% Load the library if necessary
			if ~libisloaded(RG.libName)
				warning('off','all');
				disp(['Loading ', RG.libName, '...']);
				fList = loadlibrary(libFile,headerFile);
				warning('on','all');
			end

			% Get paramters
			RG.deviceName = deviceName;

			% Setup scan timing parameters
			RG.setupTiming();

			% Setup output tasks
			RG.setupAO();
			RG.setupDO();
			RG.setupCO();
			
		end

		function setupTiming(RG)
			
			RG.sampleRate = RG.repRate*RG.sampPerRep;

			% After accounting for mirror movement scanTimes, distribute
			% remaining time among all lanes. Give extra time to the 1st scan.
			scanSamples = ceil(RG.scanTimes*RG.sampleRate);
			beamTimeSamp = floor((RG.sampPerRep - sum(scanSamples))/RG.nPoints);
			extraSamples = RG.sampPerRep - sum(scanSamples) - RG.nPoints*beamTimeSamp;
			scanSamples(1) = scanSamples(1) + extraSamples;

			% Calculate when each scan should start
			RG.scanStarts(1) = 1;
			for pointN = 2:RG.nPoints
				RG.scanStarts(pointN) = 1 + (pointN-1)*beamTimeSamp + sum(scanSamples(1:(pointN-1)));
			end
			beamTimeStarts = RG.scanStarts + scanSamples;
			RG.beamTimeEnds   = beamTimeStarts + beamTimeSamp - 1;

			% Get samples #s for component times
			RG.preBeam1S  = ceil( RG.preBeam1*RG.sampleRate);
			RG.postBeam1S = ceil(RG.postBeam1*RG.sampleRate);
			RG.preBeam2S  = ceil( RG.preBeam2*RG.sampleRate);
			RG.postBeam2S = ceil(RG.postBeam2*RG.sampleRate);
			RG.beamGapS   = ceil(  RG.beamGap*RG.sampleRate);

			% Find suitable start and end windows
			% (These will get overwritten if lasing is sequential
			RG.beam1WindowStarts = beamTimeStarts - RG.preBeam1S;
			RG.beam1WindowEnds   = RG.beamTimeEnds - RG.postBeam1S;

			RG.beam2WindowStarts = beamTimeStarts - RG.preBeam2S;
			RG.beam2WindowEnds   = RG.beamTimeEnds - RG.postBeam2S;

		end

		function updateOutput(RG, X, Y, CMD1, CMD2)

			% Find the commanded end. Clip it to the window if it's too long.
			beam1Ends = RG.beam1WindowStarts + CMD1;
			ix = find(beam1Ends > RG.beam1WindowEnds);
			beam1Ends(ix) = RG.beam1WindowEnds(ix);

			if RG.simultaneousLasers
				% Find the commanded end. Clip it to the window if it's too long.
				beam2Ends = RG.beam2WindowStarts + CMD2;
				ix = find(beam2Ends > RG.beam2WindowEnds);
				beam2Ends(ix) = RG.beam2WindowEnds(ix);
			else
				% Now put beam2 after beam1
				RG.beam2WindowStarts = beam1Ends + RG.postBeam1S + RG.beamGapS - RG.preBeam2S;
				RG.beam2WindowEnds   = RG.beamTimeEnds - RG.postBeam2S;

				% Find the commanded end, clip if necessary.
				beam2Ends = RG.beam2WindowStarts + CMD2;
				ix = find(beam2Ends > RG.beam2WindowEnds);
				beam2Ends(ix) = RG.beam2WindowEnds(ix);
			end


			% Make the waveforms
			Xwave      = zeros(RG.sampPerRep,1);
			Ywave	   = zeros(RG.sampPerRep,1);
			laser1wave = zeros(RG.sampPerRep,1);
			laser2wave = zeros(RG.sampPerRep,1);
			for laneN = 1:RG.nPoints
				Xwave(RG.scanStarts(laneN):RG.beamTimeEnds(laneN)) = X(laneN);
				Ywave(RG.scanStarts(laneN):RG.beamTimeEnds(laneN)) = Y(laneN);
				laser1wave(RG.beam1WindowStarts(laneN):beam1Ends(laneN)) = 1;
				laser2wave(RG.beam2WindowStarts(laneN):beam2Ends(laneN)) = 1;
			end
			



			
			%% Update the AO buffer	
			% Set offset to zero
			err = calllib(RG.libName, 'DAQmxSetWriteOffset',RG.AOtaskHandle,...
								0);
			RG.errorCheck(err);
						
			% Check how much buffer available from 0
			% Note that DAQmxGetWriteCurrWritePos returns a value that increases monotonically			
			buffSize0 = int32(1);
			[err, buffSize0] = calllib(RG.libName, 'DAQmxGetWriteSpaceAvail',RG.AOtaskHandle,...
				buffSize0);
			RG.errorCheck(err);
			
			% Set write offset past the end of the available buffer	
			writeStart = round(buffSize0 + RG.lookAheadAO*RG.sampPerRep);	
			% Set offset ahead to maximize writing.
			err = calllib(RG.libName, 'DAQmxSetWriteOffset',RG.AOtaskHandle,...
							writeStart);
			RG.errorCheck(err);
			writeStart = mod(writeStart,RG.sampPerRep) + 1;
					
			timeOut = RG.timeOut;	% Use -1 for indefinite, 0 to try once	
			DAQmx_Val_GroupByChannel = 0;
			scanOrder = [writeStart:RG.sampPerRep,1:(writeStart-1)];
			dataOut = [Xwave(scanOrder),...
					   Ywave(scanOrder)];	
			dataOut = dataOut(:); 
			sampsWritten = uint32(1);
			autoStart = 0;
			[err, dataOut, sampsWritten, d]  = calllib(RG.libName, 'DAQmxWriteAnalogF64', RG.AOtaskHandle,...
					RG.sampPerRep, autoStart, timeOut, DAQmx_Val_GroupByChannel, dataOut, sampsWritten, []);
			RG.errorCheck(err); % Don't throw an error, just return;
				
			
			
			%% Update the DO buffer	
			% Set offset to zero
			err = calllib(RG.libName, 'DAQmxSetWriteOffset',RG.DOtaskHandle,...
								0);
			RG.errorCheck(err);
						
			% Check how much buffer available from 0
			% Note that DAQmxGetWriteCurrWritePos returns a value that increases monotonically			
			buffSize0 = int32(1);
			[err, buffSize0] = calllib(RG.libName, 'DAQmxGetWriteSpaceAvail',RG.DOtaskHandle,...
				buffSize0);
			RG.errorCheck(err);
			
			% Set write offset past the end of the available buffer	
			writeStart = round(buffSize0 + RG.lookAheadDO*RG.sampPerRep);	
			% Set offset ahead to maximize writing.
			err = calllib(RG.libName, 'DAQmxSetWriteOffset',RG.DOtaskHandle,...
							writeStart);
			RG.errorCheck(err);
			writeStart = mod(writeStart,RG.sampPerRep) + 1;

% Buffer size diagnostics			
%			buffSizePost = int32(1);
%			[err, buffSizePost] = calllib(RG.libName, 'DAQmxGetWriteSpaceAvail',RG.DOtaskHandle,...
%				buffSizePost);
%			RG.errorCheck(err);
%			buffSizePost
			
			timeOut = RG.timeOut;	% Use -1 for indefinite, 0 to try once		
			DAQmx_Val_GroupByChannel = 0;
			scanOrder = [writeStart:RG.sampPerRep,1:(writeStart-1)];
			dataOut = [laser1wave(scanOrder),...
					   laser2wave(scanOrder)];	
			dataOut = dataOut(:); 
			sampsWritten = uint32(1);
			autoStart = 0;
			[err, dataOut, sampsWritten, d]  = calllib(RG.libName, 'DAQmxWriteDigitalLines', RG.DOtaskHandle,...
					RG.sampPerRep, autoStart, timeOut, DAQmx_Val_GroupByChannel, dataOut, sampsWritten, []);
			RG.errorCheck(err); % Don't throw an error, just return;
			
		end


		function setupAO(RG)

			% Create the analog out task
			taskName = ['AO-',datestr(now,'MMSS')];
			RG.AOtaskHandle = uint32(1);
			[err,b,RG.AOtaskHandle] = calllib(RG.libName,...
					'DAQmxCreateTask', taskName, RG.AOtaskHandle);
			RG.errorCheck(err);

			% Add AO channels
			DAQmx_Val_Volts =  10348;
			channelList = [RG.deviceName,'/ao0:1'];
			err = calllib(RG.libName, 'DAQmxCreateAOVoltageChan',RG.AOtaskHandle,...
					channelList,'',-10,10, DAQmx_Val_Volts,'');
			RG.errorCheck(err);

			% Configure clock
			DAQmx_Val_Rising = 10280;
			DAQmx_Val_ContSamps = 10123;
			err = calllib(RG.libName, 'DAQmxCfgSampClkTiming',RG.AOtaskHandle,...
				'OnboardClock', RG.sampleRate, DAQmx_Val_Rising,...
			   	DAQmx_Val_ContSamps, RG.sampPerRep);
			RG.errorCheck(err);

			% Configure software buffer
			err = calllib(RG.libName, 'DAQmxCfgOutputBuffer', RG.AOtaskHandle,...
					RG.sampPerRep);
			RG.errorCheck(err);	

			% Configure hardware FIFO - This is throwing an error -200077
			%err = calllib(RG.libName, 'DAQmxSetBufOutputOnbrdBufSize',RG.AOtaskHandle,...
			%	uint32(RG.AOFIFOSize));
			%RG.errorCheck(err);

			% Configure regeneration
			DAQmx_Val_AllowRegen = 10097;
			err = calllib(RG.libName, 'DAQmxSetWriteRegenMode',RG.AOtaskHandle,...
				DAQmx_Val_AllowRegen);
			RG.errorCheck(err);

			% Configure write relative to 0
			DAQmx_Val_FirstSample = 10424;
			err = calllib(RG.libName, 'DAQmxSetWriteRelativeTo',RG.AOtaskHandle,...
				DAQmx_Val_FirstSample);
			RG.errorCheck(err);

			% Ensure offset is 0
			err = calllib(RG.libName, 'DAQmxSetWriteOffset',RG.AOtaskHandle,...
				0);
			RG.errorCheck(err);

			% Write zeros to buffer
			timeOut = 0;
			DAQmx_Val_GroupByScanNumber = 1;
			data = zeros(RG.sampPerRep,2); data = data(:);
			sampsWritten = uint32(1);
			autoStart = 0;
			[err, dataOut, sampsWritten, d]  = calllib(RG.libName, 'DAQmxWriteAnalogF64', RG.AOtaskHandle,...
				RG.sampPerRep, autoStart, timeOut, DAQmx_Val_GroupByScanNumber, data, sampsWritten, []);
		end


		function setupDO(RG)

			% Create the digital out task
			taskName = ['DO-',datestr(now,'MMSS')];
			RG.DOtaskHandle = uint32(1);
			[err,b,RG.DOtaskHandle] = calllib(RG.libName,...
					'DAQmxCreateTask', taskName, RG.DOtaskHandle);
			RG.errorCheck(err);

			% Add DO channels
			DAQmx_Val_ChanPerLine = 0;
			channelList = [RG.deviceName,'/port0/line0:1'];
			err = calllib(RG.libName, 'DAQmxCreateDOChan',RG.DOtaskHandle,...
					channelList,'', DAQmx_Val_ChanPerLine);
			RG.errorCheck(err);

			% Configure clock, use ao/SampleClock
			DAQmx_Val_Rising = 10280;
			DAQmx_Val_ContSamps = 10123;
			err = calllib(RG.libName, 'DAQmxCfgSampClkTiming',RG.DOtaskHandle,...
				'ao/SampleClock', RG.sampleRate, DAQmx_Val_Rising,...
			   	DAQmx_Val_ContSamps, RG.sampPerRep);
			RG.errorCheck(err);

			% Configure software buffer
			err = calllib(RG.libName, 'DAQmxCfgOutputBuffer', RG.DOtaskHandle,...
					RG.sampPerRep);
			RG.errorCheck(err);	

			% Configure FIFO - Throwing error -200077
			%err = calllib(RG.libName, 'DAQmxSetBufOutputOnbrdBufSize',RG.DOtaskHandle,...
			%	RG.DOFIFOSize);
			%RG.errorCheck(err);

			% Configure regeneration
			DAQmx_Val_AllowRegen = 10097;
			err = calllib(RG.libName, 'DAQmxSetWriteRegenMode',RG.DOtaskHandle,...
				DAQmx_Val_AllowRegen);
			RG.errorCheck(err);

			% Configure write relative to 0
			DAQmx_Val_FirstSample = 10424;
			err = calllib(RG.libName, 'DAQmxSetWriteRelativeTo',RG.DOtaskHandle,...
				DAQmx_Val_FirstSample);
			RG.errorCheck(err);

			% Ensure offset is 0
			err = calllib(RG.libName, 'DAQmxSetWriteOffset',RG.DOtaskHandle,...
				0);
			RG.errorCheck(err);

			% Write zeros to buffer
			timeOut = 0;
			DAQmx_Val_GroupByScanNumber = 1;
			data = uint8(zeros(RG.sampPerRep,2)); data = data(:);
			sampsWritten = uint32(1);
			autoStart = 0;
			[err, dataOut, samplesWritten, d]  = calllib(RG.libName, 'DAQmxWriteDigitalLines',RG.DOtaskHandle,...
				RG.sampPerRep, autoStart, timeOut, DAQmx_Val_GroupByScanNumber, data, sampsWritten, []);

			% Start the task!
			err = calllib(RG.libName, 'DAQmxStartTask', RG.DOtaskHandle);
			RG.errorCheck(err);
		end

		function setupCO(RG)
		
			

			% Create the counter out task
			taskName = ['CO-',datestr(now,'MMSS')];
			RG.COtaskHandle = uint32(1);
			[err,b,RG.COtaskHandle] = calllib(RG.libName,...
					'DAQmxCreateTask', taskName, RG.COtaskHandle);
			RG.errorCheck(err);
			
			% Set to generate short pulses at the video rate
			DAQmx_Val_Hz  = 10373; 
			DAQmx_Val_Low = 10214;	% For idle state
			initDelay = 0;
			err = calllib(RG.libName, 'DAQmxCreateCOPulseChanFreq', RG.COtaskHandle,...
						[RG.deviceName,'/ctr0'],'', DAQmx_Val_Hz, DAQmx_Val_Low,...
						initDelay, RG.videoRate, .25);
			RG.errorCheck(err);
												
			% Pulse on PFI0 to allow BNC connection
			err = calllib(RG.libName, 'DAQmxSetCOPulseTerm', RG.COtaskHandle,...
						[RG.deviceName,'/ctr0'],['/',RG.deviceName,'/PFI0']);
			RG.errorCheck(err);

			% Configure for continuous generation
			DAQmx_Val_ContSamps = 10123;
			err = calllib(RG.libName, 'DAQmxCfgImplicitTiming', RG.COtaskHandle,...
						DAQmx_Val_ContSamps, 1000);
			RG.errorCheck(err);

			% Start the task immediately so camera is being triggered all the time.
			err = calllib(RG.libName, 'DAQmxStartTask', RG.COtaskHandle);
			RG.errorCheck(err);
		end

		% This should also trigger start of DO task; CO task is started on creation.
		function start(RG)
			err = calllib(RG.libName, 'DAQmxStartTask', RG.AOtaskHandle);
			RG.errorCheck(err);
		end

		function stop(RG)

			% Set all output to zero
			RG.updateOutput(zeros(1,8),zeros(1,8),zeros(1,8),zeros(1,8));

			% Wait for outputs to update to zero before stopping tasks.
			pause(.1);

			% Stop all the tasks
			err = calllib(RG.libName, 'DAQmxStopTask', RG.AOtaskHandle);
			RG.errorCheck(err);
			err = calllib(RG.libName, 'DAQmxStopTask', RG.DOtaskHandle);
			RG.errorCheck(err);
			err = calllib(RG.libName, 'DAQmxStopTask', RG.COtaskHandle);
			RG.errorCheck(err);
		end

		function clear(RG)
			err = calllib(RG.libName, 'DAQmxClearTask', RG.AOtaskHandle);
			RG.errorCheck(err);
			err = calllib(RG.libName, 'DAQmxClearTask', RG.DOtaskHandle);
			RG.errorCheck(err);
			err = calllib(RG.libName, 'DAQmxClearTask', RG.COtaskHandle);
			RG.errorCheck(err);
		end


		function errorCheck(RG, err)

			if err ~= 0
				disp(['Error: ',num2str(err)]);
			end
		end
	end
end	
