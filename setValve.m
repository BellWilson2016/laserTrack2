function setValve(olfL, olfR)

disp('setValve(): Olfactometer control not implemented.');

% global daqInfo;

% % MockL = v1    MockR = v4
% % OdorL = v2    OdorR = v5
% % SolvL = v3    SolvR = v6
% 
% if (olfL == -1)
%     % Odor Off
%     Lbits = bin2dec('000');
% elseif (olfL == 0)
%     % Mock On
%     Lbits = bin2dec('001');
% elseif (olfL == 1)
%     % Odor On
%     Lbits = bin2dec('010');
% elseif (olfL == 2)
%     % Solvent On
%     Lbits = bin2dec('100');
% end
% 
% if (olfR == -1)
%     % Odor Off
%     Rbits = bin2dec('000000');
% elseif (olfR == 0)
%     % Mock On
%     Rbits = bin2dec('001000');
% elseif (olfR == 1)
%     % Odor On
%     Rbits = bin2dec('010000');
% elseif (olfR == 2)
%     % Solvent On
%     Rbits = bin2dec('100000');
% end
% 
% ardWriteParam2(1,Lbits+Rbits);
