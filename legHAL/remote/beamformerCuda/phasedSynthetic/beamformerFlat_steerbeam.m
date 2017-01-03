function [RF, UFbfStruct] = beamformerFlat_steerbeam(buffer,CP,SEQ)

%% param beamform
UFbfStruct.Angle = CP.FlatAngles*pi/180;
UFbfStruct.idxFrame = 0;
UFbfStruct.nbSources = length(CP.FlatAngles);
UFbfStruct.nbImages =CP.NbFrames ;
for i=1:length(UFbfStruct.Angle)
    UFbfStruct.timeOrigin(i) = double(min(SEQ.InfoStruct.tx(i).Delays(SEQ.InfoStruct.rx(1).Channels))*1e-6)+1e-6;
end;

UFbfStruct.fNumber = 1; % fnumber
UFbfStruct.linePitch = system.probe.Pitch*1e-3; % 0.5
UFbfStruct.Zmin = CP.Depth(1)*1e-3;
UFbfStruct.Zmax= CP.Depth(2)*1e-3;
UFbfStruct.Gamma = 0;
UFbfStruct.Xmin = -UFbfStruct.linePitch*system.probe.NbElemts/2-tand(UFbfStruct.Gamma)*(UFbfStruct.Zmax-UFbfStruct.Zmin);
UFbfStruct.nbRecon = system.probe.NbElemts+round(2*tand(UFbfStruct.Gamma)*(UFbfStruct.Zmax-UFbfStruct.Zmin)/UFbfStruct.linePitch);
UFbfStruct.nbLinesPerRecon = 1;
UFbfStruct.speedOfSound = common.constants.SoundSpeed;
UFbfStruct.piezoPitch = system.probe.Pitch*1e-3;
UFbfStruct.demodFreq =  SEQ.InfoStruct.rx(1).Freq/4*1e6;
UFbfStruct.peakDelay = 0;
UFbfStruct.lambda = UFbfStruct.speedOfSound/UFbfStruct.demodFreq;
UFbfStruct.nbPiezos = system.probe.NbElemts;
UFbfStruct.firstSample = SEQ.InfoStruct.event(1).skipSamples;
UFbfStruct.nbSamples =SEQ.InfoStruct.event(1).numSamples;
UFbfStruct.normMode=2;
UFbfStruct.synthAcq = 0;
UFbfStruct.frame_per_frame = 0;
UFbfStruct.idxTransmitToBeamform = 0;
UFbfStruct.usegpu = 1 ;
UFbfStruct.channelOffset = SEQ.InfoStruct.mode(1).channelSize/2;
UFbfStruct.Naccum = 1;
UFbfStruct.firstChannel = min(SEQ.InfoStruct.rx(1).Channels);
UFbfStruct.nbImages = CP.NbFrames;
UFbfStruct.sampFreq=SEQ.InfoStruct.rx(1).Freq*1e6/2*double(SEQ.InfoStruct.rx.Bandwidth)/100;
% if ~exist('CP.BFcompound')
% CP.BFcompound =1;
% end
if CP.Synthacq==0
    if CP.BFcompound==1
        
        if CP.RF==1
            UFbfStruct.pixelPitch = UFbfStruct.lambda/5;
            UFbfStruct.nbPixelsPerLine = round((CP.Depth(2)-CP.Depth(1))/UFbfStruct.pixelPitch*1e-3);
            RF = beamformerSyntheticFlat_RF(UFbfStruct,buffer.data,int32(buffer.alignedOffset));
        else
            UFbfStruct.pixelPitch = UFbfStruct.lambda;
            UFbfStruct.nbPixelsPerLine = round((CP.Depth(2)-CP.Depth(1))/UFbfStruct.pixelPitch*1e-3);
            RF = beamformerSyntheticFlat_IQ(UFbfStruct,buffer.data,int32(buffer.alignedOffset));
        end;
    else
       % UFbfStruct.nbImages = UFbfStruct.nbSources*UFbfStruct.nbImages;
        UFbfStruct.Angle = repmat(UFbfStruct.Angle,1,UFbfStruct.nbImages);
        UFbfStruct.rcvAngle = repmat(CP.rcvAngle.*pi./180,1,UFbfStruct.nbImages);
        UFbfStruct.timeOrigin = repmat(UFbfStruct.timeOrigin,1,UFbfStruct.nbImages);
        UFbfStruct.nbImages = UFbfStruct.nbSources*UFbfStruct.nbImages;
        UFbfStruct.nbSources = 1;
        if CP.RF==1
            UFbfStruct.pixelPitch = UFbfStruct.lambda/5;
            UFbfStruct.nbPixelsPerLine = round((CP.Depth(2)-CP.Depth(1))/UFbfStruct.pixelPitch*1e-3);
            RF = beamformerSyntheticFlat_RF_steerbeam(UFbfStruct,buffer.data,int32(buffer.alignedOffset));
        else
            UFbfStruct.pixelPitch = UFbfStruct.lambda;
            UFbfStruct.nbPixelsPerLine = round((CP.Depth(2)-CP.Depth(1))/UFbfStruct.pixelPitch*1e-3);
            if CP.RCVAngles ==1
                IQ = beamformerSyntheticFlat_IQ_steerbeam_rcvAngles(UFbfStruct,buffer.data,int32(buffer.alignedOffset));
            else
                IQ = beamformerSyntheticFlat_IQ_steerbeam(UFbfStruct,buffer.data,int32(buffer.alignedOffset));
            end
            RF=complex(IQ(1:2:end,:,:),IQ(2:2:end,:,:));
        end;
    end;
    %end;
    
else
    
    %if CP.BFcompound==1
    
    %   if CP.RF==1
    %       UFbfStruct.pixelPitch = UFbfStruct.lambda/5;
    %       UFbfStruct.nbPixelsPerLine = round((CP.Depth(2)-CP.Depth(1))/UFbfStruct.pixelPitch*1e-3);
    %       RF = beamformerSyntheticFlat_RF(UFbfStruct,buffer.data,int32(buffer.alignedOffset));
    %     else
    %         UFbfStruct.pixelPitch = UFbfStruct.lambda;
    %         UFbfStruct.nbPixelsPerLine = round((CP.Depth(2)-CP.Depth(1))/UFbfStruct.pixelPitch*1e-3);
    %         RF = beamformerSyntheticFlat_IQ(UFbfStruct,buffer.data,int32(buffer.alignedOffset));
    %     end;
    % else
    UFbfStruct.nbImages = UFbfStruct.nbSources*UFbfStruct.nbImages;
    UFbfStruct.Angle = repmat(UFbfStruct.Angle,1,UFbfStruct.nbImages);
    UFbfStruct.timeOrigin = repmat(UFbfStruct.timeOrigin,1,UFbfStruct.nbImages);
    UFbfStruct.nbSources = 1;
    UFbfStruct.synthAcq = 1;
    %         if CP.RF==1
    %         UFbfStruct.pixelPitch = UFbfStruct.lambda/5;
    %         UFbfStruct.nbPixelsPerLine = round((CP.Depth(2)-CP.Depth(1))/UFbfStruct.pixelPitch*1e-3);
    %         RF = beamformerSyntheticFlat_RF_steerbeam(UFbfStruct,buffer.data,int32(buffer.alignedOffset));
    %          else
    UFbfStruct.pixelPitch = UFbfStruct.lambda;
    UFbfStruct.nbPixelsPerLine = round((CP.Depth(2)-CP.Depth(1))/UFbfStruct.pixelPitch*1e-3);
    RF = beamformerSyntheticFlat_IQ_steerbeam_synthacq(UFbfStruct,buffer.data,int32(buffer.alignedOffset));
    %   end;
    %end;
    %end;
end;
