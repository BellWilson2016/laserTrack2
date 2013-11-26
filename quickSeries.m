function quickSeries(dM, textCode, plotColor)

	pQ = 'PI';
	subplot(3,3,1);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,false,false,true,true,true);
	subplot(3,3,4);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,plotColor,false,true,false,false,false,false);
	subplot(3,3,7);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,false,true,false,false,false);

	pQ = 'decPI';
	subplot(3,3,2);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,false,false,true,true,true);
	title(textCode);
	subplot(3,3,5);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,true,false,false,false,false);
	subplot(3,3,8);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,false,true,false,false,false);
	pQ = 'dTraveled';
	subplot(3,3,3);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,false,false,true,true,true);
	subplot(3,3,6);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,true,false,false,false,false);
	subplot(3,3,9);
	laserPowerSeriesFlex(dM,1:8,pQ,20/4,'b',false,false,true,false,false,false);

	% saveTallPDF([textCode,'.pdf']);
