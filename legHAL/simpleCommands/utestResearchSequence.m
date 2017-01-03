
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/07/09$
%M-File utest.

%Create server
srv = remoteDefineServer('extern', '192.168.1.132', 9999);

%Research sequence available for user_fine and user_coarse level only
remoteSetLevel(srv, 'user_coarse');

%Freeze to set research sequence
remoteFreeze(srv, 1);

%Get all research settings available for the current probe plug on the system
clear seq;
seq = remoteGetUserSequence(srv);
disp(seq);

%First set the probe where you want to change settings
clear seq;
seq.research_probe_value = 'SLV16-5';
seq.research_probe_action = '1';

%Next change every parameter you want
seq.ultrafast_nb_half_cycle_value = '5';
seq.ultrafast_nb_half_cycle_action = '1';

seq.ultrafast_tx_freq_value = '7.5';
seq.ultrafast_tx_freq_action = '1';

seq.ultrafast_nb_firings_value = '50';
seq.ultrafast_nb_firings_action = '1';

seq.ultrafast_prf_value = '500';
seq.ultrafast_prf_action = '1';

%Send research sequence
remoteSetUserSequence(srv, seq);

%unFreeze to launch research sequence
remoteFreeze(srv, 0);

%Launch an ultrafast acquisition
clear msg;
msg.name = 'launch_ultrafast_acq';
remoteSendMessage(srv, msg);

%Freeze to dump research data
remoteFreeze(srv, 1);

%Dump research data on the hard drive
clear msg;
msg.name = 'dump_research_data';
remoteSendMessage(srv, msg);

%Export research data on a USB device
clear msg;
msg.name = 'export_research_data';
remoteSendMessage(srv, msg);

