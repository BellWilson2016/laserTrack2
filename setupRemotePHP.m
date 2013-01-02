function setupRemotePHP()

	if isunix()
		[status, currentIP] = system('ip addr show eth0 | grep -Po ''(?<=inet )[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*''');
	else
		disp('Local webserving not setup in Windows, not pushing PHP script.');
		return;
	end
