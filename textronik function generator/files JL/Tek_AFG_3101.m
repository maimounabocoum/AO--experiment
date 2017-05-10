%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Inrterfaçage générateur AFG3101 Tek
%%%
%%% Input => signal norm ou pas
%%%         + freq d'échatillonnage (MHz)
%%%         + Temps répétition (s)
%%%         + amplitude PP (V)
%%%
%%% Je fixe la fréquence ech du géné à 30Ms/s
%%%
%%% on peut la changer de même que le nom...
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Tek_AFG_3101(signal,F_ech,T_rep,nb_cyc,duree,Vpp,offset)

% Exemple :
% Vpp      = 0.5;  % (V)
% T_rep    = 20;   % (ms)
% F_ech    = 100;  % (MHz)
% freq     = 1.4;  % (MHz)
% df       = 0.2;  % (MHz)
% dt_chirp = 10;% (µs)
% nb_cyc   = 1;
% [signal,t] = makeChirp(F_ech,[freq-df freq+df],dt_chirp);
% Tek_AFG_3101(signal,F_ech,T_rep,freq,Vpp);

nom_onde = 'USER1';
signal   = (signal./max(abs(signal)));

visaAddress = 'USB0::0x0699::0x0342::C021881::0::INSTR';
% visaAddress = 'USB0::1689::834::C021881::0::INSTR';
AFG = visa('TEK', visaAddress);
AFG.OutputBufferSize = 131072;% 2^16*2; %51200; 
AFG.ByteOrder = 'littleEndian';
set(AFG, 'Timeout', 10.0);
fopen(AFG);

% arrêt de la voie du générateur
fprintf(AFG, 'OUTP 0');

% Convert the double values integer values between 0 and 16382 (as require by the instrument)
waveform =  round((signal+1)*2^14/2);
waveformLength = length(waveform);

% Encode variable 'waveform' into binary waveform data for AFG.  
binblock = zeros(2 * waveformLength, 1);
binblock(2:2:end) = bitand(waveform, 255);
binblock(1:2:end) = bitshift(waveform, -8);
binblock = binblock';
% Build binary block header
bytes = num2str(length(binblock));
header = ['#' num2str(length(bytes)) bytes];

% définition de la taille mémoire
fprintf(AFG,(sprintf('DATA:DEF EMEM,%i',length(signal))));
% fprintf(AFG, ['DATA:DEF EMEM, ' num2str(length(t)) ';']); %1001

% Transfer the custom waveform from MATLAB to edit memory of instrument
fwrite(AFG, [':TRACE EMEM, ' header binblock ';'], 'uint8');

% Place la forme d'onde dans un fichier interne au géné
fprintf(AFG,(sprintf('DATA:COPY %s,EMEM',nom_onde)));

% Selectionne la forme d'onde pour la source
fprintf(AFG,(sprintf('SOUR:FUNCTION %s',nom_onde)));

% Rêgle la fréquence
fprintf(AFG,(sprintf('FREQUENCY %dM',1/duree)));

% Régle l'amplitude pp de sortie
fprintf(AFG,(sprintf('SOUR:VOLT:LEV:IMM:OFFS %dV',offset)))
fprintf(AFG,(sprintf('SOUR:VOLT:LEV:IMM:AMPL %dVpp',Vpp)));

% Active et réglage du mode  burst
fprintf(AFG,'SOUR:BURST 1');
fprintf(AFG,(sprintf('SOUR:BURS:NCYC %d',nb_cyc)))
fprintf(AFG,(sprintf('SOUR:BURS:TDEL %dms',0)))
fprintf(AFG,(sprintf('TRIG:SEQ:TIM %dms',T_rep)))

% je rallume la voie 
fprintf(AFG,('OUTP 1'));


% Clean up - close the connection and clear the object
fclose(AFG);
delete(AFG);
clear AFG;


