% function softReset()

    a = timerfindall;
    for n=1:size(a,1)
        if isvalid(a(n))
            stop(a(n));
            delete(a(n));
        end
    end
    delete(timerfindall);
    clearPorts();
    close all;
    clear all;
	jDAQmx.jDAQmxReset('Dev1');
	imaqreset();
