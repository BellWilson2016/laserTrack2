function serialReceiver(obj,event)


	tic();

    global trackingParams;

    displayTemp = false;
    
    bytesHere = obj.BytesAvailable;
	if (bytesHere >= obj.InputBufferSize)
		disp(['SERIAL INPUT BUFFER FULL']);
	end
    blocksHere = floor(bytesHere/5);
    if ( (blocksHere > 0) )
		% disp(['Reading ',num2str(blocksHere)]);
       	x = fread(obj,blocksHere*5);
        for n = 1:blocksHere
            code = x((n-1)*5+1);
            time =  bitshift(x((n-1)*5+2),24) + ...
                    bitshift(x((n-1)*5+3),16) + ...
                    bitshift(x((n-1)*5+4), 8) + ...
                    bitshift(x((n-1)*5+5), 0);
            if isfield(trackingParams,'recordingSerial')  
                if trackingParams.recordingSerial
                    trackingParams.serialRecord(end+1,:) = [code,time];
                end
            end
			switch (code)
				case 253 % hex2dec('fd')
					disp(['Serial alarm code: ',dec2hex(time)]);
				case 254 % hex2dec('fe')
		            trackingParams.mirrorTemp = (bitshift(x((n-1)*5+2),24) + ...
		                bitshift(x((n-1)*5+3),16) + ...
		                bitshift(x((n-1)*5+4),8) + ...
		                bitshift(x((n-1)*5+5),0))/2;
                	alertString = ['Mirrors locked at t= ',num2str(trackingParams.mirrorTemp,'%2.1f'),...
                     	' C    ',datestr(now)];
		            % Only send the alert on the first occurence
		            if (~trackingParams.tempFault)
		                trackingParams.scanMirrors = false;
		                trackingParams.tempFault = true;
		                notifyOfFault(alertString);
		                pushNow = true;
		                updateWebStatus(alertString, pushNow);
		            end
				case 255 % hex2dec('ff')
		            trackingParams.mirrorTemp = (bitshift(x((n-1)*5+2),24) + ...
		                bitshift(x((n-1)*5+3),16) + ...
		                bitshift(x((n-1)*5+4),8) + ...
		                bitshift(x((n-1)*5+5),0))/2;

            end
        end
    end

toc

