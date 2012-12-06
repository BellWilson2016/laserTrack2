function webUpdateTimerFcn(obj, event)

    global trackingParams;
       
        mirrors = trackingParams.scanMirrors;
        temp = trackingParams.mirrorTemp;
        fault = trackingParams.tempFault;
        
        if mirrors
            mirrorString = [' Mirrors on.  '];
        else
            mirrorString = [' Mirrors off. '];
        end
        tempString = [' t= ',num2str(temp,'%2.1f'),' C  '];
        if fault
            faultString = ' TEMP FAULT ';
        else
            faultString = ' Temp ok.   ';
        end
        
        % Push to web every tenth update     
        if (mod(obj.TasksExecuted,10) == 0)
            webPush = true;
        else
            webPush = false; 
        end
		
        disp([mirrorString,tempString,faultString]);
        updateWebStatus([mirrorString,tempString,faultString],webPush);
        
