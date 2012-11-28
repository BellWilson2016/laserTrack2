function runLaserProtocol(protocol, laserDistribution, parameters)

    global trackingParams;

    exp = feval(protocol, laserDistribution, parameters);

    exp.genotype     = 'ChR-Ctrl';
    exp.flyAge       = 10;    % Days
    exp.sex          = 'M';
    exp.odor         = 'none';
    exp.odorConc     = 0;          % log10
    exp.flowRate     = 300;        % mL/side

    
    exp.comment      = ['-',exp.protocolName,...
                        '-',exp.laserDistributionName];
    exp.expName = ['RTFW',exp.comment];
    exp.trackingParams = trackingParams;
    
    % Set for periodic acquisiton
    exp.acquisitionPeriod = .1;        % sec
    
    epoch = 1;
    startEpoch(exp, epoch);
    
 %%   
       function startEpoch(exp, epochN)
        
        global tempData;
        tempData = [];
        tempData(1,1:2,:) = zeros(2,8);
        
        % Grab what to do now
        protocolFrame = exp.protocolDesign{epochN};
        endFrame = exp.protocolDesign{end};
        
        disp(['Starting epoch: ',num2str(epochN),' of ',num2stR(exp.nEpochs),...
            ' at minute ',num2str(protocolFrame{1}),' of ',...
            num2str(endFrame{1})]);
               
        
        % Execute all the commands in the list
        nCommands = (size(protocolFrame,2)-1)/2;
        for n = 1:nCommands
            cmd = protocolFrame{2*(n-1)+2};
            args = protocolFrame{2*(n-1)+3};
            feval(cmd,args);
        end

        % Setup the acquisition timer
        acqTimer = timer('ExecutionMode','fixedRate',...
            'Period',exp.acquisitionPeriod,...
            'TimerFcn',{@grabSample});
        
        % Figure out how long to wait before finishing the epoch
        startTime = protocolFrame{1};
        endFrame = exp.protocolDesign{epochN+1};
        endTime = endFrame{1};
        lengthToRun = 60*(endTime - startTime);
        
        finishEpochTimer = timer('ExecutionMode','singleShot',...
            'StartDelay',lengthToRun,...
            'TimerFcn',{@finishEpoch, exp, epochN, acqTimer});
        
        start(acqTimer);        
        start(finishEpochTimer);

        
%%    
    function finishEpoch(obj, event, exp, epochN, acqTimer)
        
        global tempData;
        global trackingParams;    
 
        stop(acqTimer);
        exp.epoch(epochN).track = tempData(2:end,1:2,:);
        
        if (epochN + 1 < exp.nEpochs)
            % Do another epoch
            startEpoch(exp, epochN + 1);
        else % Finish up       
            
            epochN = epochN + 1;
            protocolFrame = exp.protocolDesign{epochN};
            % Execute all the commands in the list
            nCommands = (size(protocolFrame,2)-1)/2;
            for n = 1:nCommands
                cmd = protocolFrame{2*(n-1)+2};
                args = protocolFrame{2*(n-1)+3};
                feval(cmd,args);
            end

            % Save data
            filename = ['RTFW\','RTFW', datestr(now,'yymmdd'),'-',datestr(now,'HHMMSS'),'.mat'];
            expName  = exp.expName;
            saveExperimentData(expName,filename,'exp');
            disp(['Saved: ',filename]);

        end

        
%%
    function grabSample(obj, event)
            
        global trackingParams;
        global tempData;

        sample = [trackingParams.xPos;trackingParams.yPos]; 
        tempData(end+1,1:2,:) = sample;
    
    

