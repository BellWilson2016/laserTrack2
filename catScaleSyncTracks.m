function exp = catScaleSyncTracks(exp)



wholeTrack.bodyX = [];
wholeTrack.bodyY = [];
wholeTrack.headX = [];
wholeTrack.headY = [];
wholeTrack.angle = [];
wholeTrack.transID = [];
wholeTrack.videoTime = [];

for epochN = 1:exp.nEpochs

	% Get the info from the rawTrack
	rawTrack = exp.epoch(epochN).rawTrack;
	rawBodyX     = rawTrack(:,1,:);
	rawBodyY     = rawTrack(:,2,:);
	rawHeadX     = rawTrack(:,3,:);
	rawHeadY     = rawTrack(:,4,:);
	transID      = rawTrack(:,5,:);
	videoTime    = rawTrack(:,6,:);

	% Normalize videoTime to start at 0, scale to seconds
	videoTime = (videoTime - videoTime(1,:)).*(24*60*60);
	% Scale coordinates to lane center, mm
	bodyX =  (rawBodyX - exp.trackingParams.laneCenterX)./exp.trackingParams.pxPerMM;
	bodyY = -(rawBodyY - exp.trackingParams.laneCenterY)./exp.trackingParams.pxPerMM;
	headX =  rawHeadX./exp.trackingParams.pxPerMM;
	headY = -rawHeadY./exp.trackingParams.pxPerMM;
	ts1 = timeseries(ts1d, videoTime, 'Name', 'bodyX');
	ts2 = timeseries(ts2d, videoTime, 'Name', 'bodyY');
	ts3 = timeseries(ts3d, videoTime, 'Name', 'headX');
	ts4 = timeseries(ts4d, videoTime, 'Name', 'headY');



	track = tscollection({ts1 ts2 ts3 ts4});

	% Need to compute angles AFTER interpolation!
	% Compute the head angle over a range of 0-2pi
	% ts5 = atan2(track(:,4,:),track(:,3,:));
	% ix = find(track.angle < 0);
	% track.angle(ix) = track.angle(ix) + 2*pi;

	% Save info to the wholeTrack
	wholeTrack.bodyX = cat(1,wholeTrack.bodyX, bodyX);
	wholeTrack.bodyY = cat(1,wholeTrack.bodyY, bodyY);
	wholeTrack.headX = cat(1,wholeTrack.headX, headX);
	wholeTrack.headY = cat(1,wholeTrack.headY, headY);
	wholeTrack.angle = cat(1,wholeTrack.angle,track.angle);
	wholeTrack.transID = cat(1,wholeTrack.transID, transID(:,:));
	wholeTrack.videoTime = cat(1,wholeTrack.videoTime, videoTime(:,:));







