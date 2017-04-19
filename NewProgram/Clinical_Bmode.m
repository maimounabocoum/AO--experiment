%%%%%%%%%%%%% clinical B mode %%%%%%%%%%%%%%%
% Maïmouna Bocoum 21-03-2017
clearvars

AixplorerIP    = '192.168.0.20'; % IP address of the Aixplorer device
addpath('D:\legHAL')
addpath('D:\legHAL\simpleCommands')
addPathLegHAL;
%%
%init
srv = remoteDefineServer('extern',AixplorerIP, 9999);
remoteSetLevel(srv, 'user_coarse');

%%
%Unfreeze
remoteFreeze(srv, 0);

%%
%Freeze
remoteFreeze(srv, 1);

%%
remoteGetUserSequence(srv)

%%
msg.name        = 'get_status';
status = remoteSendMessage(srv, msg);
status
clear msg;

%%
msg.name        = 'select_probe';
msg.probe='A';
status = remoteSendMessage(srv, msg);
status
clear msg;


%%
% =============== 2D ECHO ==================
msg.name        = 'set_user_sequence';
msg.mode_action = 'value';
msg.mode_value  = 'B';
remoteSendMessage(srv, msg);
clear msg;

%%
%change focal zone
msg.name        = 'set_user_sequence';
msg.twod_echo_focal_zone_action = 'decrease';
msg.twod_echo_focal_zone_value = '100';
remoteSendMessage(srv, msg);
clear msg;

%%
%change focal zone nb
msg.name        = 'set_user_sequence';
msg.twod_echo_focal_nb_zones_action = 'increase';
msg.twod_echo_focal_nb_zones_value = '100';
remoteSendMessage(srv, msg);
clear msg;

%%
%change 2d echo gain
msg.name        = 'set_user_sequence';
msg.twod_echo_gain_action = 'value';
msg.twod_echo_gain_value  = '100';
remoteSendMessage(srv, msg);
clear msg;

%%
%change 2d echo tgc
msg.name        = 'set_user_sequence';
msg.twod_echo_tgc_action = 'value';
msg.twod_echo_tgc_value  = '0 100 100 100 100 100 100 100';
remoteSendMessage(srv, msg);
clear msg;

%%
%change 2d echo resolution
msg.name        = 'set_user_sequence';
msg.twod_echo_resolution_action = 'value';
msg.twod_echo_resolution_value  = 'res';
remoteSendMessage(srv, msg);
clear msg;

%%
%change 2d echo framerate
msg.name        = 'set_user_sequence';
msg.twod_echo_framerate_action = 'value';
msg.twod_echo_framerate_value  = 'low';
remoteSendMessage(srv, msg);
clear msg;

%%
%change depth
msg.name        = 'set_user_sequence';
msg.depth_action = 'value';
msg.depth_value  = 'low';
remoteSendMessage(srv, msg);
clear msg;

%%
%go to COLOR
msg.name        = 'set_user_sequence';
msg.mode_action = 'value';
msg.mode_value  = 'COL';
remoteSendMessage(srv, msg);
clear msg;

%%
% % =============== 2D SWE ==================
msg.name        = 'set_user_sequence';
msg.mode_action = 'value';
msg.mode_value  = 'SWE';
remoteSendMessage(srv, msg);
clear msg;

%%
%change 2d swe resolution
msg.name        = 'set_user_sequence';
msg.twod_swe_framerate_action = 'value';
msg.twod_swe_framerate_value  = 'low';
remoteSendMessage(srv, msg);
clear msg;

%%
%change swe option (resolution)
msg.name        = 'set_user_sequence';
msg.twod_swe_option_action = 'value';
msg.twod_swe_option_value  = 'pen';
remoteSendMessage(srv, msg);
clear msg;

%%
%change 2d swe gain
msg.name        = 'set_user_sequence';
msg.twod_swe_gain_action = 'value';
msg.twod_swe_gain_value  = '100';
remoteSendMessage(srv, msg);
clear msg;

%%
%change 2d swe opacity
msg.name        = 'set_user_sequence';
msg.twod_swe_opacity_action = 'value';
msg.twod_swe_opacity_value  = '90';
remoteSendMessage(srv, msg);
clear msg;

%%
%change 2d swe persistence
msg.name        = 'set_user_sequence';
msg.twod_swe_persistence_action = 'decrease';
msg.twod_swe_persistence_value  = '90';
remoteSendMessage(srv, msg);
clear msg;


%%
%change 2d screen format
msg.name        = 'set_user_sequence';
msg.twod_swe_screen_format_action = 'increase';
msg.twod_swe_screen_format_value  = 'top_bottom';
remoteSendMessage(srv, msg);
clear msg;


%%
% get SWE lut color bar
lut = remoteGetUserLutColorBar (srv)

%%
% get last swe data

close all
[data, status] = remoteTransfertData(srv, 'SWE');
status
disp ('process elasto');
figure;
elasto  = reshape(data.data(:,1), str2num(status.height_px),str2num(status.width_px));
imagesc(elasto);

disp ('process quality');
figure;
quality = reshape(data.data(:,2), str2num(status.height_px),str2num(status.width_px));
imagesc(quality);
disp ('processes ok');

%%
%change 2d screen format
msg.name        = 'set_user_sequence';
msg.twod_swe_elasticity_range_unit_action = 'value';
msg.twod_swe_elasticity_range_unit_value  = 'kPa';
remoteSendMessage(srv, msg);
clear msg;

%%
%========================= BOX MANAGEMENT =======================
%set Color Box 
msg.name        = 'set_user_sequence';

msg.box_action = 'value';
 msg.box_pos_x  = '10';
 msg.box_pos_z  = '10';
 msg.box_size_x  = '10';
 msg.box_size_z  = '10';

remoteSendMessage(srv, msg);
clear msg;

%%
%set Color Box 
msg.name        = 'set_user_sequence';



msg.box_action = 'increase';
msg.box_pos_x  = '1';
msg.box_pos_z  = '1';
msg.box_size_x  = '0';
msg.box_size_z  = '0';

remoteSendMessage(srv, msg);
clear msg;

%%
%hide all tems
msg.name = 'set_screen_properties';
msg.box_visibility = 0;
msg.frozen_bitmap_visibility = 0;
msg.screen_lut_visibility = 0;
msg.screen_scale_visibility = 0;
msg.screen_focal_zone_visibility = 0;
msg.screen_sar_visibility = 0;

remoteSendMessage(srv, msg);
clear msg;

%%
%display all tems
msg.name = 'set_screen_properties';
msg.box_visibility               = 1;
msg.frozen_bitmap_visibility     = 1;
msg.screen_lut_visibility        = 1;
msg.screen_scale_visibility      = 1;
msg.screen_focal_zone_visibility = 1;
msg.screen_sar_visibility        = 1;

remoteSendMessage(srv, msg);
clear msg;

%%
%get display item informations
msg.name = 'get_screen_properties';
infos  = remoteSendMessage(srv, msg);
infos
clear msg;
clear infos;


%%
%test  auto freeze
for i=0:20
    
    datestr(now, 'mmmm dd, yyyy HH:MM:SS.FFF AM')
    
%     msg.name        = 'set_user_sequence';
%     msg.twod_echo_gain_action = 'value';
%     msg.twod_echo_gain_value  = '100';
%     remoteSendMessage(srv, msg);
%     clear msg;

    msg.name        = 'reset_auto_freeze';
    remoteSendMessage(srv, msg);
    clear msg;
    
    pause (120)
end

