function returnPower = laserLinearGrad(X,Y,args)  

    leftP  = args(1);
    rightP = args(2);
	Pgrad = (rightP - leftP)/50;  		% Power units / mm

	returnPower = leftP + (X + 25).*Pgrad;    


