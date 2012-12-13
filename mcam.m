% cam.m
%
% A wrapper function to set camera parameters.  Run without args to 
% set camera to auto-exposure mode. Else, argument sets exposure.
%
% JSB 11/2010
function mcam(varargin)

    global vid;
    
    brightness = 0;

    if (nargin < 1)
        shutter = 5000;
    else
        shutter = varargin{1};
    end
    
    % Remember, FrameRate only works in Format0
    if ispc()
      set(vid.Source,...
          'AutoExposure',0,...
          'Brightness',brightness,...
          'Gain', 80,...
          'Sharpness', 0,...
          'Shutter', shutter1394(shutter),...
          'ShutterMode','manual');
    elseif isunix()
        
        runningFlag = false;
        if strcmp(vid.Running,'on')
            runningFlag = true;
            stop(vid);
        end
        
       set(vid.Source,...
          'Exposure',0,...
          'Brightness',brightness,...
          'Gain', 80,...
          'Sharpness', 0,...
          'Shutter', shutter1394(shutter),...
          'ShutterMode','manual');
      
      if runningFlag
          start(vid);
		  if ispc()
          	trigger(vid);
		  end
      end
    end
              

