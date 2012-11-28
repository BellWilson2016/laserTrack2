function setLaserDistribution(args)

    global trackingParams;

    handle =     args{1};
    parameters = args{2};
    trackingParams.laseredZoneFcn = {handle, parameters};