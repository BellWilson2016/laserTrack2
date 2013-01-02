% This writes a PHP script to the server that will pull data from a local
% webserver.
function setupRemotePHP()

	if isunix()
		[status, currentIP] = system('ip addr show eth0 | grep -Po ''(?<=inet )[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*''');
	else
		disp('Local webserving not setup in Windows, not pushing PHP script.');
		return;
	end

	fileID = fopen('rtfwURL.php','w');
	fprintf(fileID,'%s','<?php ');
	fprintf(fileID,'%s',['$rtfwURL = ''http://',currentIP,'/rtfw.html '';']);
	fprintf(fileID,'%s','?> ');
	fclose(fileID);

	cmd = 'scp ./rtfwURL.php jsb38@orchestra.med.harvard.edu:/www/wilson.med.harvard.edu/docroot/';
    [status,result] = system(cmd);
	if status == 0
		disp('Set up remote PHP script to pull data.');
	else
		disp('Command line error: ');
		disp(result);
	end


