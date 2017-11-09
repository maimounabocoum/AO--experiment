function DurationTotal = SEQinfosPrint( SEQ )
% this functions returns ifnformation of the current sequence :
% created by maimouna bocoum 13-07-2017

%     Msg    = struct('name', 'get_status');
%     Status = remoteSendMessage(SEQ.Server, Msg) ;
    
%SEQ.Server     ;

% event informations :
 SEQ.InfoStruct.event.duration

 DurationTotal = 0 ; % us
 for Nevent = 1:length(SEQ.InfoStruct.event)
 DurationTotal  = DurationTotal  + SEQ.InfoStruct.event(Nevent).duration ;
 end

 fprintf('The sequence is about %f us long\r\n',DurationTotal)
 
 
 % movie on sequences
 figure;
 clear T_waveform
 dt_s = 1/(system.hardware.ClockFreq);
 for i = 1:length(SEQ.InfoStruct.tx)
     delay_waveform = 0 ;
     t_waveform = (1:size(SEQ.InfoStruct.tx(i).waveform,1))*dt_s;
     Nelement = 1:size(SEQ.InfoStruct.tx(i).waveform,2);
     [NELEM,T_waveform] = meshgrid(Nelement,t_waveform);
     T_waveform = T_waveform + repmat(SEQ.InfoStruct.tx(i).Delays,length(t_waveform),1) ;
     surfc(NELEM,T_waveform,SEQ.InfoStruct.tx(i).waveform)
     %imagesc(SEQ.InfoStruct.tx(i).waveform')
     shading interp
     view([0,90])
     pause(1)
     drawnow
 end
 
% SEQ.InfoStruct.event.TrigOutDelay
% SEQ.InfoStruct.event.numSamples

%  SEQ.InfoStruct
% SEQ.InfoStruct.rx
% SEQ.InfoStruct.mode

%SEQ.InfoStruct.tx
%SEQ.InfoStruct.tx.repeat
% printout waveform or firt event 
% figure;
% imagesc(SEQ.InfoStruct.tx(10).waveform)
% title(['event 1 out of ',num2str( length(SEQ.InfoStruct.tx) )])
% xlabel('piezo element index')
% ylabel('Command voltage')
% colormap(gray)
% cb  = colorbar ;
% ylabel(cb,'piezo element index')

end

