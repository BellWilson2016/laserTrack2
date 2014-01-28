% function softReset()

	stopSoftwareWatchdog();	
	
    a = timerfindall;
    for n=1:size(a,1)
        if isvalid(a(n))
            stop(a(n));
            delete(a(n));
        end
    end
    delete(timerfindall);

	if (~isempty(instrfind))
		fclose(instrfind);      % Closes any MATLAB open serial ports
	end

    close all;
    clear all;
	jDAQmx.jDAQmxReset('Dev1');
	
	warning('off','MATLAB:JavaEDTAutoDelegation');
	imaqreset();
