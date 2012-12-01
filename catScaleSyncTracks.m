%% exp = catScaleSyncTracks(exp).m
%
% This function:
%   (1) Scales and orients rawTrack so + is up and right
%   (2) Scales track times into timeseries objects so they can be 
%           conveniently resampled in different timebases
%   (3) Synchronizes serialID time codes to videoID time codes and places
%           them in the videoTime timecode.
%   (4) Concatenates all data into a wholeTrack
%
% Need to compute angles AFTER interpolation!
% Compute the head angle over a range of 0-2pi
% ts5 = atan2(track(:,4,:),track(:,3,:));
% ix = find(track.angle < 0);
% track.angle(ix) = track.angle(ix) + 2*pi;
%
% JSB 12/2012
%%
function exp = catScaleSyncTracks(exp)

    wholeTrack.bodyX = [];
    wholeTrack.bodyY = [];
    wholeTrack.headX = [];
    wholeTrack.headY = [];
    wholeTrack.videoID = [];
    wholeTrack.videoTime = [];
    wholeTrack.serialID = [];
    wholeTrack.serialTime = [];

    % For each epoch extract and normalize data
    for epochN = 1:exp.nEpochs

        % Get the info from the rawTrack
        rawTrack = exp.epoch(epochN).rawTrack;
        serialRecord = exp.epoch(epochN).serialRecord;
        rawBodyX     = rawTrack(:,1,:);
        rawBodyY     = rawTrack(:,2,:);
        rawHeadX     = rawTrack(:,3,:);
        rawHeadY     = rawTrack(:,4,:);
        videoID      = rawTrack(:,5,1);
        rawVideoTime    = rawTrack(:,6,1);
        rawSerialID     = serialRecord(:,1);
        rawSerialTime   = serialRecord(:,2);

        % Normalize videoTime to start at 0, scale to seconds
        videoTime = (rawVideoTime - rawVideoTime(1)).*(24*60*60);
        % Scale coordinates to lane center, mm
        bodyX =  (rawBodyX - exp.trackingParams.laneCenterX)./exp.trackingParams.pxPerMM;
        bodyY = -(rawBodyY - exp.trackingParams.laneCenterY)./exp.trackingParams.pxPerMM;
        headX =  rawHeadX./exp.trackingParams.pxPerMM;
        headY = -rawHeadY./exp.trackingParams.pxPerMM;
        ts1 = timeseries(bodyX, videoTime, 'Name', 'bodyX');
        ts2 = timeseries(bodyY, videoTime, 'Name', 'bodyY');
        ts3 = timeseries(headX, videoTime, 'Name', 'headX');
        ts4 = timeseries(headY, videoTime, 'Name', 'headY');
        ts5 = timeseries(videoID, videoTime, 'Name', 'videoID');
        ts6 = timeseries(videoTime, videoTime, 'Name', 'videoTime');

        % Remove themometer ID codes because they don't carry time info
        ix = find(rawSerialID < hex2dec('fe'));
        serialID   = rawSerialID(ix);
        serialTime = rawSerialTime(ix);
        % Remove Time wraps so serialTime increases monotonically
        ix = find(diff(serialTime) < 0);
        while (size(ix,1) > 0)
            firstWrappedTime = ix(1) + 1;
            serialTime(firstWrappedTime:end) = serialTime(firstWrappedTime:end) + 16*10^6;
            ix = find(diff(serialTime) < 0);
        end

        % Fit a model to the times
        timeModel = fitTimeModel(videoID, videoTime, serialID, serialTime - serialTime(1));
        fitSerialTime = timeModel(serialTime - serialTime(1));

        % Remove temperature codes from the serial stream since the time field doesn't contain times
        ts7 = timeseries(serialID,fitSerialTime,'Name','serialID');

        % Collect the time series objects into a collection
        exp.epoch(epochN).track = tscollection({ts1 ts2 ts3 ts4 ts5 ts6 ts7});


        % Save variables to concatenated wholeTrack
        wholeTrack.bodyX = cat(1,wholeTrack.bodyX, bodyX);
        wholeTrack.bodyY = cat(1,wholeTrack.bodyY, bodyY);
        wholeTrack.headX = cat(1,wholeTrack.headX, headX);
        wholeTrack.headY = cat(1,wholeTrack.headY, headY);
        wholeTrack.videoID = cat(1,wholeTrack.videoID, videoID);
        wholeTrack.rawVideoTime  = cat(1,wholeTrack.rawVideoTime, rawVideoTime);
        wholeTrack.serialID   = cat(1,wholeTrack.serialID, serialID);
        wholeTrack.serialTime = cat(1,wholeTrack.serialTime, serialTime);

    end

    % Scale videoTime to start at 0, in seconds
    videoTime = (wholeTrack.rawVideoTime - wholeTrack.rawVideoTime(1)).*(24*60*60);
    % Refer wholeTrack timeseries to videoTime
    ts1 = timeseries(wholeTrack.bodyX, videoTime, 'Name', 'bodyX');
    ts2 = timeseries(wholeTrack.bodyY, videoTime, 'Name', 'bodyY');
    ts3 = timeseries(wholeTrack.headX, videoTime, 'Name', 'headX');
    ts4 = timeseries(wholeTrack.headY, videoTime, 'Name', 'headY');
    ts5 = timeseries(wholeTrack.videoID, videoTime, 'Name', 'videoID');
    ts6 = timeseries(videoTime, videoTime, 'Name', 'videoTime');

    serialTime = wholeTrack.serialTime;
    % Remove Time wraps so serialTime increases monotonically
    % This needs to be done again because epochs have been de-wrapped
    % independently (but not scaled to 0)
    ix = find(diff(serialTime) < 0);
    while (size(ix,1) > 0)
        firstWrappedTime = ix(1) + 1;
        serialTime(firstWrappedTime:end) = serialTime(firstWrappedTime:end) + 16*10^6;
        ix = find(diff(serialTime) < 0);
    end
    timeModel = fitTimeModel(wholeTrack.videoID, videoTime,...
                                wholeTrack.serialID, serialTime - serialTime(1));
    fitSerialTime = timeModel(serialTime - serialTime(1));
    ts7 = timeseries(wholeTrack.serialID, fitSerialTime,'Name','serialID');

    % Collect the time series objects into a collection
    exp.wholeTrack = tscollection({ts1 ts2 ts3 ts4 ts5 ts6 ts7});













