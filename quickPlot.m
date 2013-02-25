function quickPlot(dM, pQ)

%	list = returnFileList(experiment);
%	dM = makeDataMatrix(list);
	subplot(3,1,1);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,false,false,true,true,true);
	subplot(3,1,2);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,true,false,false,false,false);
	subplot(3,1,3);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,false,true,false,false,false);

