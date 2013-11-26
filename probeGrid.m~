function probeGrid(letterCode)

	xDev = [-1:.1:1]; % mm
	yDev = [-1:.1:1];

%	xDev = [-5:1:5]+2; % mm
%	yDev = [-5:1:5];

	global gridDeviation;
	global trackingParams

	[xGrid,yGrid] = meshgrid(xDev,yDev);
	randOrder = randperm(length(xGrid(:)));

	for pointNn = 1:length(randOrder)
		disp([num2str(pointNn),' of ',num2str(length(randOrder))]);
		pointN = randOrder(pointNn);
		%disp(['X: ',num2str(xGrid(pointN)),'  Y: ',num2str(yGrid(pointN))]);
		gridDeviation.x = xGrid(pointN)*trackingParams.pxPerMM;
		gridDeviation.y = yGrid(pointN)*trackingParams.pxPerMM;
		pause(4);
		%powerAtPoint(pointN) = input(':');

	end

	save(['grid',letterCode,'.mat'],'xGrid','yGrid','randOrder');%,'powerAtPoint');

