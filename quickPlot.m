function quickPlot(experiment)

	list = returnFileList(experiment);
	dM = makeDataMatrix(list);
	figure();
	laserPowerSeriesFlex(dM,1:8,'PI',20,'b',false,false,false,true,true,true);

