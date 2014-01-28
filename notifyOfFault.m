function notifyOfFault(message)

	disp(['Fault Notification: ',message]);
	return;

    mail = 'rtfw.computer@gmail.com';
    password = 'ypkwdtvwxeoboehc';

    toMail = 'joe.bell@gmail.com';
    toCell = '6178218253@vtext.com';

    setpref('Internet','E_mail', mail);
    setpref('Internet','SMTP_Server', 'smtp.gmail.com');
    setpref('Internet','SMTP_Username', mail);
    setpref('Internet','SMTP_Password', password);

    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');

    sendmail(toCell,'RTFW Fault',[message]);
    sendmail(toMail,'RTFW Fault',[message]);

    disp('Text and email messages sent.');

