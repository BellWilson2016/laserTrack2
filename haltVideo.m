% haltVideo.m
%
% Use  this to stop the running video object.  This is called automatically
% when the video preview window is closed.
%
% JSB 11/2010
function haltVideo(obj, event)

    global vid;
    global trackingParams;
    
    if isfield(trackingParams,'statusMonitorTimer')
        if isvalid(trackingParams.statusMonitorTimer)
            stop(trackingParams.statusMonitorTimer);
            delete(trackingParams.statusMonitorTimer);
        end
    end
        
    stop(vid);
    flushdata(vid);
    delete(gcf);
