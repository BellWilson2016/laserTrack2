% cam.m
%
% A wrapper function to set camera parameters.  Run without args to 
% set camera to auto-exposure mode. Else, argument sets exposure.
%
% JSB 11/2010
function visCam(varargin)

    global vid;
    
    brightness = 0;

    if (nargin < 1)
        shutter = 5000;
    else
        shutter = varargin{1};
    end
  
    runningFlag = false;
    if strcmp(vid.Running,'on')
            runningFlag = true;
            stop(vid);
    end
       
     % Gain was 80, set to zero for laser cal. 
      set(vid.Source,...
          'Exposure',0,...
          'Brightness',brightness,...
          'Gain', 0,...
          'Sharpness', 0,...
          'Shutter', shutter1394(shutter),...
          'ShutterMode','manual');
      
     if runningFlag
     	start(vid);
     end
      

