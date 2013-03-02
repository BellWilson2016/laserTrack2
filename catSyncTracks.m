%% exp = catSyncTracks(exp).m
%
% This function:
%   (1) Scales track times into timeseries objects so they can be 
%           conveniently resampled in different timebases
%   (2) Synchronizes serialID time codes to videoID time codes and places
%           them in the videoTime timecode.
%   (3) Concatenates all data into a wholeTrack
%
% Need to compute angles AFTER interpolation!
% Compute the head angle over a range of 0-2pi
% ts5 = atan2(track(:,4,:),track(:,3,:));
% ix = find(track.angle < 0);
% track.angle(ix) = track.angle(ix) + 2*pi;
%
% JSB 12/2012
%%
function exp = catSyncTracks(exp)

	disp(' '); % For aesthetics

    wholeRawTrack.bodyX = [];
    wholeRawTrack.bodyY = [];
    wholeRawTrack.headX = [];
    wholeRawTrack.headY = [];
    wholeRawTrack.videoID = [];
    wholeRawTrack.rawVideoTime = [];
    wholeRawTrack.serialID = [];
    wholeRawTrack.serialTimeCode = [];

    % For each epoch extract and normalize data
    for epochN = 1:exp.nEpochs


        % Get the info from the rawTrack
        rawTrack = exp.epoch(epochN).rawTrack;
        serialRecord = exp.epoch(epochN).serialRecord;
        bodyX     = squeeze(rawTrack(:,1,:));
        bodyY     = squeeze(rawTrack(:,2,:));
        headX     = squeeze(rawTrack(:,3,:));
        headY     = squeeze(rawTrack(:,4,:));
        videoID      = rawTrack(:,5,1);
        rawVideoTime    = rawTrack(:,6,1);
        rawSerialID         = serialRecord(:,1);
        rawSerialTimeCode   = serialRecord(:,2);


        % Normalize videoTime to start at 0, scale to seconds
        videoTime = (rawVideoTime - rawVideoTime(1)).*(24*60*60);
        % Scale coordinates to lane center, mm
        ts1 = timeseries(  bodyX, videoTime, 'Name', 'bodyX');
        ts2 = timeseries(  bodyY, videoTime, 'Name', 'bodyY');
        ts3 = timeseries(  headX, videoTime, 'Name', 'headX');
        ts4 = timeseries(  headY, videoTime, 'Name', 'headY');
        ts5 = timeseries(videoID, videoTime, 'Name', 'videoID');


        % Remove themometer ID codes and errors because they don't carry time info
        ix = find(rawSerialID < hex2dec('fd'));
        serialID   = rawSerialID(ix);
        wrappedSerialTimeCode = rawSerialTimeCode(ix);
		serialTimeCode = wrappedSerialTimeCode;
        % Remove Time wraps so serialTime increases monotonically
        ix = find(diff(serialTimeCode) < 0);
        while (size(ix,1) > 0)
            firstWrappedTime = ix(1) + 1;
            serialTimeCode(firstWrappedTime:end) = serialTimeCode(firstWrappedTime:end) + 16*10^6;
            ix = find(diff(serialTimeCode) < 0);
        end


		% Scale to seconds
		serialTime = serialTimeCode ./ (16*10^6);

        % Fit a model to the times
        timeModel = fitTimeModel(videoID, videoTime, serialID, serialTime - serialTime(1));
        fitSerialTime = timeModel(serialTime - serialTime(1));


        % Remove temperature codes from the serial stream since the time field doesn't contain times
        ts6 = timeseries(             serialID, fitSerialTime,'Name','serialID');
		ts7 = timeseries(wrappedSerialTimeCode, fitSerialTime,'Name','serialTime');


        % Collect the time series objects into a structure
        exp.epoch(epochN).track.bodyX           = ts1;
		exp.epoch(epochN).track.bodyY           = ts2;
		exp.epoch(epochN).track.headX           = ts3;
		exp.epoch(epochN).track.headY           = ts4;
		exp.epoch(epochN).track.videoID         = ts5;
		exp.epoch(epochN).track.serialID        = ts6;
		exp.epoch(epochN).track.serialTimeCode  = ts7;



        % Save variables to concatenated wholeTrack
        wholeRawTrack.bodyX = cat(1,wholeRawTrack.bodyX, bodyX);
        wholeRawTrack.bodyY = cat(1,wholeRawTrack.bodyY, bodyY);
        wholeRawTrack.headX = cat(1,wholeRawTrack.headX, headX);
        wholeRawTrack.headY = cat(1,wholeRawTrack.headY, headY);
        wholeRawTrack.videoID = cat(1,wholeRawTrack.videoID, videoID);
        wholeRawTrack.rawVideoTime  = cat(1,wholeRawTrack.rawVideoTime, rawVideoTime);
        wholeRawTrack.serialID   = cat(1,wholeRawTrack.serialID, serialID);
        wholeRawTrack.serialTimeCode = cat(1,wholeRawTrack.serialTimeCode, wrappedSerialTimeCode);


    end

    % Scale videoTime to start at 0, in seconds
    videoTime = (wholeRawTrack.rawVideoTime - wholeRawTrack.rawVideoTime(1)).*(24*60*60);
    % Refer wholeTrack timeseries to videoTime
    ts1 = timeseries(  wholeRawTrack.bodyX, videoTime, 'Name', 'bodyX');
    ts2 = timeseries(  wholeRawTrack.bodyY, videoTime, 'Name', 'bodyY');
    ts3 = timeseries(  wholeRawTrack.headX, videoTime, 'Name', 'headX');
    ts4 = timeseries(  wholeRawTrack.headY, videoTime, 'Name', 'headY');
    ts5 = timeseries(wholeRawTrack.videoID, videoTime, 'Name', 'videoID');

    wrappedSerialTimeCode = wholeRawTrack.serialTimeCode;
    serialTimeCode = wrappedSerialTimeCode;
    % Remove Time wraps so serialTime increases monotonically
    % This needs to be done again because epochs have been de-wrapped
    % independently (but not scaled to 0)
    ix = find(diff(serialTimeCode) < 0);
    while (size(ix,1) > 0)
        firstWrappedTime = ix(1) + 1;
        serialTimeCode(firstWrappedTime:end) = serialTimeCode(firstWrappedTime:end) + 16*10^6;
        ix = find(diff(serialTimeCode) < 0);
    end

	% Scale to seconds
	serialTime = serialTimeCode ./ (16*10^6);

    timeModel = fitTimeModel(wholeRawTrack.videoID, videoTime,...
                                wholeRawTrack.serialID, serialTime - serialTime(1));
    fitSerialTime = timeModel(serialTime - serialTime(1));
    ts6 = timeseries(wholeRawTrack.serialID, fitSerialTime,'Name','serialID');
	ts7 = timeseries( wrappedSerialTimeCode, fitSerialTime,'Name','serialTime');

    % Collect the time series objects into a collection
    exp.wholeTrack.bodyX = ts1;
	exp.wholeTrack.bodyY = ts2;
	exp.wholeTrack.headX = ts3;
	exp.wholeTrack.headY = ts4;
	exp.wholeTrack.videoID = ts5;
	exp.wholeTrack.serialID = ts6;
	exp.wholeTrack.serialTimeCode = ts7;



% All of the rawSerialTimes must contain valid time info and not wrap
% Both times should start at 0
function timeModel = fitTimeModel(videoID, videoTime, serialID, serialTime) 


	% Find serial data transmission codes
	ix = find( (serialID >= hex2dec('24')) & (serialID < (hex2dec('24') + 64)) );
	transSerialID = serialID(ix) - hex2dec('24');
	transSerialTime = serialTime(ix);


	% For each ID, find the closest video time for each serial time
	% Fit to a linear model
	allVideoTimes = [];
	allTransSerialTimes = [];
	for ID = 0:63
		vIx = find(videoID == ID);
		sIx = find(transSerialID == ID);
		% Only fit the times if you find some
		if ((length(vIx)>0)&(length(sIx)>0))
			vT = videoTime(vIx);
			sT = transSerialTime(sIx);
			% Find the closest video time to each serial time
			ix = dsearchn(vT,sT);
			allVideoTimes = [allVideoTimes; vT(ix)];
			allTransSerialTimes = [allTransSerialTimes; sT];
		end
	end


	% Fit a linear time model, remember that model.p1 coefficients refer to the normalized
	% values
	timeModel = fit(allTransSerialTimes,allVideoTimes,'poly1',...
			'Robust','Bisquare','Normalize','on');
	disp(['Fit clock model - M: ',num2str(timeModel(1)-timeModel(0),8),...
		' B: ',num2str(timeModel(0),8)]);













