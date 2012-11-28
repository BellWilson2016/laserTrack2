function analyzeLatency(nSamples)

    global trackingParams;

    LL = measureLatency(nSamples); 
    frameIntervalHistogram(nSamples*5);
    pause(nSamples*5 / 30 + 5);
    figure(trackingParams.otherFig);
    subplot(2,1,1); 
    title('Windows Body Tracking Latency')
    subplot(2,1,2);
    N = hist(LL*1000,30:1:120);
    plot(30:1:120,N./max(N),'r'); hold on;
    plot(30:1:120,cumsum(N)./sum(N),'b');
    xlabel('Response latency (ms)');
    ylabel('P');
    xlim([30 120]);
    ylim([0 1]);


