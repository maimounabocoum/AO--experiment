% Marc_Blocs_start 15-06-15
% Acceleration du getData

% nouveau beamformer pour machine V9 (GPU 3D)
% application d'un masque au beamforming pour selection de zones
% d'intérets. (disponible pour GPU 2D)

% Sequence de Marc ( d'après 150914-Elodie et Thomas)
% SEQUENCE DE blocs avec sauvegarde à chaque boucle

%% Init
disp('------------Initialisation ... ------------------')


clear all_bufs buffer test_buff buffer_data InitIQ IQ

all_bufs = {};
buf_size = Sequence.RemoteStruct.mode(1).channelSize(1) * system.hardware.NbRxChan / 2 ;
all_bufs{1} = int16( zeros( 1, buf_size, 'int16' ) );
buffer_data = all_bufs{1};

% IQ initialisation
test_buff.data = buffer_data;
test_buff.mode = 0;
test_buff.alignedOffset = 0;
TempMaskOn = CP.MaskOn;
CP.MaskOn = 'init'; 
InitIQ = beamformerFlat(test_buff,CP,Sequence);
IQ = complex(zeros([size(InitIQ,1)/2 size(InitIQ,2) size(InitIQ,3)], 'single'));

% Beamforming mask
CP.MaskOn = TempMaskOn; % 'on' for using a mask (find a way to design it). 'off' if you don't use a mask
clear TempMaskOn

if strcmp(CP.MaskOn,'on') % design of the beamforming Mask. Put '1' in pixels to be beamformed, otherwise put '0'.
    CP.Mask = ones([size(InitIQ,1)/2 size(InitIQ,2)], 'int8');
    %     CP.Mask(1:20,:)=0;
    %     CP.Mask(50:end,:)=0;
    %     CP.Mask(:,1:5)=0;
    %     CP.Mask(:,20:60)=0;
    
    % CP.Mask = DessineMoiUnMasque(InputImage)
    load Mask_test_SL10_2.mat  % exemple pour image de 20mm de profondeur prise à la SL 10-2  ~ équivalent à 8 mm sur sucre
    CP.Mask = maskForSL10_2;
end

clear InitIQ test_buff

heure = datestr(now, 'hh_MM_ss');
Debug=1

if UF.TrigIn == 0 ;
    %     disp('---------Push a button to start the burst sequence----------')
    %     pause
else
    disp('------------Waiting for TRIG IN------------------')
end

%% START SEQUENCE
temps_AcqBloc = zeros(1,NbAcqRx*UF.Repeat_sequence);
index_to_keep =[];
Sequence = Sequence.startSequence('Wait', 0);

tic_total=tic;
for bloc = 1:NbAcqRx*UF.Repeat_sequence
    try
        bloc
        temps_AcqBloc(1,bloc) = toc(tic_total);
        tic_loop = tic;
        % Retrieve data
    %      buffer = Sequence.getData('Realign',2);
        buffer = Sequence.getData('Realign',0, 'Timeout',20, 'Buffer',buffer_data, 'DataFormat',Sequence.getParam('DataFormat'), 'Debug',Debug );


        % Beamforming 
        disp('seq done')
        toc(tic_loop)
        IQ_buffer = beamformerFlat(buffer,CP,Sequence);
%         time_to_bf = toc;
        
        if bloc == 1
            index_to_keep = find(~(IQ_buffer(end, :,1)==0));
        end
        IQ_buffer = IQ_buffer(:,index_to_keep,:);
        IQ = complex(IQ_buffer(1:2:end,:,:),IQ_buffer(2:2:end,:,:));

        disp('BF done')
        toc(tic_loop)
    %     %saving
    %     tic
    %     save([dir_save name '_IQ' num2str(bloc) '_' date '_' heure], '-v6', 'IQ', 'heure');
    %     time_to_save_Matlab = toc
        %saving
        if test
            display_Doppler;
        end
        fastSaveAsync(IQ,[dir_save name '_IQ_' date '_' heure '_' sprintf('%.3d', bloc) '.mat.fs']);
        %toc(tic_loop)
        time_to_loop = toc(tic_loop)
        disp(sprintf('------------TIME TO LOOP  = %.2f ----------------', time_to_loop));
    catch
        save([dir_save name '_TempsDAcq_' date '_' heure], '-v6', 'temps_AcqBloc', 'heure');
        errordlg('PLANTAGE!')
    end
%     

end
Sequence = Sequence.stopSequence('Wait', 1);
str= ['Total acquisition time = ' num2str(toc(tic_total) ) ' seconds']; disp(str)
save([dir_save name '_TempsDAcq_' date '_' heure], '-v6', 'temps_AcqBloc', 'heure');


Sequence = Sequence.quitRemote();
warning('Do not forget to SAVE data from rubi and CLEAN /home/rubi/WorkFolder when you are finished')
% cd /home/rubi/WorkFolder

return
%%

Sequence = Sequence.stopSequence('Wait', 0);

%clear IQ buffer
% pack

% [SonFini,FsSonFini,NBITS]=wavread('/media/Data/Marc/SonSurAixPlorer/R2D2e.wav');
% sound(SonFini,FsSonFini,NBITS);
% clear SonFini FsSonFini NBITS