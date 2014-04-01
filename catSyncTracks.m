%% exp = catSyncTracks(exp).m
%
% This function:
%   (1) Scales track times into timeseries objects so they can be 
%           conveniently resampled in different timebases
%   (2) Concatenates all data into a wholeTrack
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

    % For each epoch extract and normalize data
    for epochN = 1:exp.nEpochs


        % Get the info from the rawTrack
        rawTrack = exp.epoch(epochN).rawTrack;
        bodyX     = squeeze(rawTrack(:,1,:));
        bodyY     = squeeze(rawTrack(:,2,:));
        headX     = squeeze(rawTrack(:,3,:));
        headY     = squeeze(rawTrack(:,4,:));
        videoID           = rawTrack(:,5,1);
        rawVideoTime      = rawTrack(:,6,1);

        % Normalize videoTime to start at 0, scale to seconds
        videoTime = (rawVideoTime - rawVideoTime(1)).*(24*60*60);
        % Scale coordinates to lane center, mm
        ts1 = timeseries(  bodyX, videoTime, 'Name', 'bodyX');
        ts2 = timeseries(  bodyY, videoTime, 'Name', 'bodyY');
        ts3 = timeseries(  headX, videoTime, 'Name', 'headX');
        ts4 = timeseries(  headY, videoTime, 'Name', 'headY');
        ts5 = timeseries(videoID, videoTime, 'Name', 'videoID');

        % Collect the time series objects into a structure
        exp.epoch(epochN).track.bodyX           = ts1;
		exp.epoch(epochN).track.bodyY           = ts2;
		exp.epoch(epochN).track.headX           = ts3;
		exp.epoch(epochN).track.headY           = ts4;
		exp.epoch(epochN).track.videoID         = ts5;

        % Save variables to concatenated wholeTrack
        wholeRawTrack.bodyX = cat(1,wholeRawTrack.bodyX, bodyX);
        wholeRawTrack.bodyY = cat(1,wholeRawTrack.bodyY, bodyY);
        wholeRawTrack.headX = cat(1,wholeRawTrack.headX, headX);
        wholeRawTrack.headY = cat(1,wholeRawTrack.headY, headY);
        wholeRawTrack.videoID = cat(1,wholeRawTrack.videoID, videoID);
        wholeRawTrack.rawVideoTime  = cat(1,wholeRawTrack.rawVideoTime, rawVideoTime);

    end

    % Scale videoTime to start at 0, in seconds
    videoTime = (wholeRawTrack.rawVideoTime - wholeRawTrack.rawVideoTime(1)).*(24*60*60);
    % Refer wholeTrack timeseries to videoTime
    ts1 = timeseries(  wholeRawTrack.bodyX, videoTime, 'Name', 'bodyX');
    ts2 = timeseries(  wholeRawTrack.bodyY, videoTime, 'Name', 'bodyY');
    ts3 = timeseries(  wholeRawTrack.headX, videoTime, 'Name', 'headX');
    ts4 = timeseries(  wholeRawTrack.headY, videoTime, 'Name', 'headY');
    ts5 = timeseries(wholeRawTrack.videoID, videoTime, 'Name', 'videoID');

    % Collect the time series objects into a collection
    exp.wholeTrack.bodyX = ts1;
	exp.wholeTrack.bodyY = ts2;
	exp.wholeTrack.headX = ts3;
	exp.wholeTrack.headY = ts4;
	exp.wholeTrack.videoID = ts5;
















