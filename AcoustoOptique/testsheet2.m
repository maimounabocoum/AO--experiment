
US.freqx = 3:3:192 ;
US.Nphase = 3 ;
for kk = 1:length(US.freqx)
        
        for ll = 1:3
            
            for mm = 1:system.probe.NbElemts
                WF_mat(ll,1,kk, DlySmpl(mm,1) + (1:length(Wf)) ,mm) =...
                    (1-2*rem( ceil((mm+(ll-1)*US.freqx(kk)/US.Nphase)/US.freqx(kk) ),2))*Wf;
                
            end
            
            figure(256+ll)
            imagesc(squeeze(WF_mat(ll,1,kk,:,:)))
            drawnow
            pause(0.1)
            
        end
        
    end
