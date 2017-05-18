%%%% loading waveforms to generator %%%%

%==================== establish communication ====
% findInstrument() ; % execute alone to find adress of connected instrument
                     % along with their information
% Clear MATLAB workspace of any previous instrument connections
instrreset;         
visaAddress = 'USB0::0x0699::0x0343::C021048::0::INSTR';
AFG = visa('NI', visaAddress);


AFG.OutputBufferSize = 131072;% 2^16*2; %51200; 
AFG.ByteOrder        = 'littleEndian';



set(AFG, 'Timeout', 10.0);
fopen(AFG);

%========== set both generator outputs to OFF
fprintf(AFG, 'OUTPUT1:STATE 0');
fprintf(AFG, 'OUTPUT2:STATE 0');


% Convert the double values integer values between 0 and 16382 (as require by the instrument)
waveform14bits       =  round( 2^14*(waveform - min(waveform))/(max((waveform - min(waveform)))) );
waveformLength       =  length(waveform14bits);

% Encode variable 'waveform' into binary waveform data for AFG.  
binblock          = zeros(2 * waveformLength, 1);
binblock(2:2:end) = bitand(waveform14bits, 255);
binblock(1:2:end) = bitshift(waveform14bits, -8);
binblock          = binblock';
% Build binary block header
bytes = num2str(length(binblock));
header = ['#' num2str(length(bytes)) bytes];
% Build binary block header
bytes = num2str(length(binblock));
header = ['#' num2str(length(bytes)) bytes];

% définition de la taille mémoire
fprintf(AFG,(sprintf('DATA:DEF EMEM,%i',length(waveform14bits))));
% catch an error :
fprintf(AFG,sprintf('*ESR?'));
fprintf(AFG,sprintf('SYSTEM:ERROR:[NEXT]?'));

% Transfer the custom waveform from MATLAB to edit memory of instrument
fwrite(AFG, [':TRACE EMEM, ' header binblock ';'], 'uint8');

% Place la forme d'onde dans un fichier interne au géné
fprintf(AFG,(sprintf('DATA:COPY USER1 EMEM')));

% Selectionne la forme d'onde pour la source
fprintf(AFG,(sprintf('SOUR:FUNCTION USER1')));



% error status ??
% fprintf(AFG,sprintf('*ESR?'));
% fprintf(AFG,sprintf('SYSTEM:ERROR:[NEXT]?'));


% Clean up - close the connection and clear the object
fclose(AFG);
delete(AFG);
clear AFG;





