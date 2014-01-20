%% Calculates the argument for a shutter time in us
function cmd = shutter1394(shutterTime)

%% Shutter table
%    1- 500 = n*(1 us)                      1- 500 us
%  501-1000 = 500 us + (n-500)*(10 us)    510-5500 us
% 1001-1705 = 5.5 ms + (n-1000)*(100 us)  5.6-  76 ms
% 1706-2399 = 76 ms + (n-1705)*(1 ms)      77- 770 ms
%%

if (shutterTime < 1)
    cmd = 1;
    actShutter = cmd;
elseif ((1 <= shutterTime) && (shutterTime < 510))
    cmd = round(shutterTime);
    actShutter = cmd;
elseif ((510 <= shutterTime) && (shutterTime  < 5600))
    cmd = round((shutterTime - 500)/10 + 500);
    actShutter = 500 + (cmd-500)*10;
elseif ((5600 <= shutterTime) && (shutterTime  < 77000))
    cmd = round((shutterTime-5500)/100 + 1000);
    actShutter = 5500 + (cmd-1000)*100;
elseif ((77000 <= shutterTime) && (shutterTime  < 780000))
    cmd = round((shutterTime-76000)/1000 + 1705);
    actShutter = 76000 + (cmd - 1705)*1000;
else
    cmd = 2400;
    actShutter = 780000;
end

disp(['Set shutter to: ',num2str(actShutter),' us']);
