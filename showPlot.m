function showPlot(list,plotColor)

	pQ = 'PI';

	dM = makeDataMatrix(list);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,plotColor,false,false,false,true,true,false);


