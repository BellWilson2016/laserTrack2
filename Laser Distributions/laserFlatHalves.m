%%
% Returns flat laser distributions on each half.
%
function returnPower = laserFlatHalves(X,Y,args)  

    
    leftP  = args(1);
    rightP = args(2);
    
    returnPower = (X < 0).*leftP + (X >= 0).*rightP;


