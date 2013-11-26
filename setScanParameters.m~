function setScanParameters()

global USBscanController;

% Total cycle time is sum of mirrorMoveTimes + 8*scanTime
% Laser has 12 usec latency to start of rising phase
% 
% Min largest jump: 575 - 12
% Min small jump:   250 - 12
largeJump = 575-12;
smallJump = 250-12;
cyclePeriod = 10000;
laserEndPad = 95;

mirrorMoveTime = uint16([largeJump,smallJump,smallJump,smallJump,...
    smallJump,smallJump,smallJump,smallJump]);
scanTime = uint16((cyclePeriod - sum(mirrorMoveTime))/8);
extraTime = cyclePeriod - sum(mirrorMoveTime) - 8*scanTime;
mirrorMoveTime(1) = mirrorMoveTime(1) + extraTime;
totalCycle = sum(mirrorMoveTime) + 8*scanTime;
maxDuty = 8*double(scanTime - laserEndPad)*(255/256)./double(totalCycle);
maxLaser = double(scanTime - laserEndPad)*(255/256);

scanOrder = [0,1,2,3,4,5,6,7];
numZones = 8;

disp(' ');
disp(['Setting scan time: ',num2str(scanTime),' us']);
disp(['Mirror move times: ',num2str(mirrorMoveTime)]);
disp(['Scan order: ',num2str(scanOrder)]);
disp(['Total cycle: ',num2str(totalCycle),' us']);
disp(['Max laser time: ', num2str(maxLaser),' us']);
disp(['Laser max duty: ',num2str(maxDuty)]);
disp(' ');



list = [27,bitshift(scanTime,-8), bitand(scanTime,255),...
    zeros(1,16),scanOrder,numZones];

for n = 1:8
    list(4 + (n-1)*2) = bitshift(mirrorMoveTime(n),-8);
    list(5 + (n-1)*2) = bitand(mirrorMoveTime(n),255);
end

    % Write them all to USB if idle, otherwise drop
    transmitted = false;
    while ~transmitted
        if strcmp(USBscanController.TransferStatus,'idle') 
            fwrite(USBscanController, [uint8(list)],  'uint8','async');
            transmitted = true;
        end
    end
