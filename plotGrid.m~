function plotGrid()

	load('gridD.mat');
	figure;

	xPos = unique(xGrid);
	yPos = unique(yGrid);

	for n = 1:length(powerAtPoint)
		xIx = dsearchn(xPos,xGrid(n));
		yIx = dsearchn(yPos,yGrid(n));
		powerGrid(xIx,yIx) = powerAtPoint(n);
	end

	powerGrid = powerGrid./1000./(pi*.075^2);

	image(xPos,yPos,(powerGrid'),'CDataMapping','scaled');
	set(gca,'YDir','normal');
