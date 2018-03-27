%%% trig only
Nloop = 1
for k = 1:Nloop
    tic

    SEQ = SEQ.startSequence('Wait',0);
    close;
    
    pause(1)
    
    
    toc
    
       SEQ = SEQ.stopSequence('Wait', 1);  
end