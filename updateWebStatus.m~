%%
% Linux setup:
%
% 'ssh-keygen -t dsa'
%    Use defaults, don't enter a passphrase
% 'chmod 755 .ssh'
% 'scp ~/.ssh/id_dsa.pub jsb38@orchestra.med.harvard.edu:.ssh/authorized_keys'
% SSH to orchestra,
%   'chmod 600 ~/.ssh/authorized_keys'
% 'exec /usr/bin/ssh-agent $SHELL'
% 'ssh-add'
% Now add the line 'ssh-add' to .bashrc

function updateWebStatus(alertString, pushNow)

% Keep a list of the messages in a .mat file
load('statusData.mat');
messageList{end+1,1} = datestr(now);
messageList{end,2}   = alertString;
save('statusData.mat','messageList');

% Now make an html version
% First, write a header
maxMessages = 100;
fileID = fopen('rtfw.html','w');

header = ['<style type="text/css"><!-- body, div, table, span { font-size: 32px;}',...
          '--> </style>'];
tableTop = ['<table border="1"><CAPTION><EM>RTFW Status:</EM></CAPTION>',...
          '<tr><th>Time: </th><th>Message:</th></tr>'];
if isunix()
	linkToVPN = ['<a href="https://secure.med.harvard.edu/dana/home/index.cgi">VPN</a><br>'];
	[status, currentIP] = system('ip addr show eth0 | grep -Po ''(?<=inet )[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*''');
	linkToSSH = ['<a href="chrome-extension://pnhechapfaindjhompbnflcldabbghjo/html/nassh.html#joe@',currentIP,'"> SSH to RTFW </a>'];	
else 
	linkToSSH = '';
	linkToVPN = '';
end

fprintf(fileID,'%s',[header,linkToVPN,linkToSSH,tableTop]);
if size(messageList,1) < maxMessages
    maxMessages = size(messageList,1);
end
for n = 1:maxMessages
    line = ['<tr> <td>',messageList{end-(n-1),1},'</td><td>',...
        messageList{end-(n-1),2},'</td> </tr>'];
    fprintf(fileID,'%s',line);
end
footer = '</table></p>';
fprintf(fileID,'%s',footer);
fclose(fileID);


if pushNow
    if ispc()
        cmd = 'WinSCP\WinSCP.com /script="statusUpdateScriptPC.txt"';
    elseif isunix()
        cmd = 'scp ./rtfw.html jsb38@orchestra.med.harvard.edu:/www/wilson.med.harvard.edu/docroot/';
    end

    % [status,result] = system(cmd);
	if status == 0
		disp('Pushed Web Update');
	else
		disp('Command line error: ');
		disp(result);
	end
end
        
