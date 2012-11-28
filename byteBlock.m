function arrayOut = byteBlock(arrayIn)

arrayOut = [];
for i=1:size(arrayIn,2)
    newVal = -arrayIn(i) + 2^15;
    if (newVal < 0) 
        oldVal = newVal;
        newVal = 0;
        disp(['Data truncated in byteBlock() ',num2str(oldVal),...
            ' -> ',num2str(newVal)]);
    elseif (newVal > (2^16 - 1))
        oldVal = newVal;
        newVal = 2^16 - 1;
        disp(['Data truncated in byteBlock() ',num2str(oldVal),...
            ' -> ',num2str(newVal)]);
    end
    newVal = round(newVal);
    arrayOut(end+1) = bitshift(newVal,-8);
    arrayOut(end+1) = bitand(newVal,255);
end