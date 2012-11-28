function latencyList = measureLatency(numSamples)

global trackingParams;

trackingParams.invert = true;

latencyList = [];

% Measure multiple times
for i=1:numSamples
    disp(i);
    setLaserDistribution({@laserOff,[]});
    trackingParams.serialRecord = [];
    trackingParams.recordingSerial = true;
    % disp('L off');
    pause(.5);
    setLaserDistribution({@laserLatencyMeasure,[]});
    % disp('L meas');
    pause(.25);
%     % Trigger the laser
    setScanMode([2,1,0]);
    % disp('Trigger');
    pause(.5);
    trackingParams.recordingSerial = false;
    setLaserDistribution({@laserOff,[]});
    % disp('L off');
    pause(.5);

    record = trackingParams.serialRecord;
    trackingParams.serialRecord = [];
    if (size(record,1) > 0)
        modeSends = find(record(:,1) == hex2dec('22'));
        laserOns  = find((record(:,1) >= hex2dec('10')) & ...
                         (record(:,1) <= hex2dec('17')));

        if ((size(laserOns,1) > 0) && (size(modeSends,1) > 0))
             firstLatency =  (record(laserOns(1),2) - record(modeSends(1),2))  / (16*10^6);
             disp(firstLatency );
             latencyList(end+1) = firstLatency;
        else
             disp('Missed');
        end
    else
        disp('Missed record');
    end
end