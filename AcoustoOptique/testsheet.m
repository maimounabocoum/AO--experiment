%% test scrpits

AlphaM = -20:20 ;
Nbtot = 10;
pitch = 0.2 ;
c = 1540 ;
dt_s = (1/180);
f0 = 6;
NbHemicycle = 10;
pulseDuration = NbHemicycle*(0.5/f0) ;


Delay = zeros(Nbtot,length(AlphaM)); %(µs)

for i = 1:length(AlphaM)
    
%     Delay(:,i) = sin(pi/180*AlphaM(i))*...
%         (1:size(Delay,1))*(pitch)/(c*1000); 
    
    Delay(:,i) = 1000*(1/c)*tan(pi/180*AlphaM(i))*(1:Nbtot)*(pitch); %s
    Delay(:,i) = Delay(:,i) - min(Delay(:,i));
    
end

% plot(Delay)

% for i = 1:length(AlphaM)
%     
%     Delay(:,i) = Delay(:,i) + max(max(Delay(:,:)))-max(Delay(:,i));
%     
% end


DlySmpl = round(Delay/dt_s);



T_Wf = 0:dt_s:pulseDuration;
Wf = sin(2*pi*f0*T_Wf);

N_T = length(Wf) + max(max(DlySmpl))
WF_mat = zeros(N_T,size(Delay,1),size(Delay,2));

for kk = 1:length(AlphaM)
    for j = 1:size(Delay,1)
        WF_mat( DlySmpl(j,kk) + (1:length(Wf)),j,kk) = Wf;
    end
end

imagesc(squeeze(WF_mat(:,:,10)))


