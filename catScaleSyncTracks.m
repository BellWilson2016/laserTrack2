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
	bodyX     = rawTrack(:,1,:);
	bodyY     = rawTrack(:,2,:);
	headX     = rawTrack(:,3,:);
	headY     = rawTrack(:,4,:);
	transID   = rawTrack(:,5,:);
	videoTime = rawTrack(:,6,:);

	% Scale coordinates to lane center, mm
	track.bodyX(:,:) =  (bodyX - exp.trackingParams.laneCenterX)./exp.trackingParams.pxPerMM;
	track.bodyY(:,:) = -(bodyY - exp.trackingParams.laneCenterY)./exp.trackingParams.pxPerMM;
	track.headX(:,:) = headX./exp.trackingParams.pxPerMM;
	track.headY(:,:) = -headY./exp.trackingParams.pxPerMM;
	% Compute the head angle over a range of 0-2pi
	track.angle(:,:) = atan2(track(:,4,:),track(:,3,:));
	ix = find(track.angle < 0);
	track.angle(ix) = track.angle(ix) + 2*pi;
	% Keep the video tracking codes
	% Normalize video time to the beginning of the epoch.
	track.transID = transID;
	track.videoTime = videoTime - videoTime(1,:);


	% Save info to the wholeTrack
	wholeTrack.bodyX = cat(1,wholeTrack.bodyX,track.bodyX);
	wholeTrack.bodyY = cat(1,wholeTrack.bodyY,track.bodyY);
	wholeTrack.headX = cat(1,wholeTrack.headX,track.headX);
	wholeTrack.headY = cat(1,wholeTrack.headY,track.headY);
	wholeTrack.angle = cat(1,wholeTrack.angle,track.angle);
	wholeTrack.transID = cat(1,wholeTrack.transID, transID(:,:));
	wholeTrack.videoTime = cat(1,wholeTrack.videoTime, videoTime(:,:));







