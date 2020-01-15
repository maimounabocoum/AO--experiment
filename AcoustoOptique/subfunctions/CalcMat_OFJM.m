function [nuZ,t,WF_mat] = CalcMat_OFJM(f0,nbZ,nuZ0,Fe,c,DelayLaw)
% c input in m/s
% f0  (en MHz) est la fréquence de porteuse
% nuZ (en mm-1)
% nuX (en mm-1)
% Fe : sampling frequency of Aixplorer in MHz ; 
% x  : coordinate vector in mm

dt_s = 1/Fe;
% conversion of all input to SI units : 

Fe = Fe*1e6 ;           % MHz->Hz
f0 = f0*1e6;            % MHz->Hz
nuZ = 1e3*(nbZ*nuZ0) ;  % mm-1->m-1

% conversion to temporal frequency along z
fz0 = c*nuZ0*1e3  ;      % fondamental frequency in Hz
fz  = c*nuZ ;            % harmonic frequency in Hz
dt  = 1/Fe ;             % in s


% 2 constraints are imposed on the repeating patter:
% fz*Tot should be integer
% f0*Tot should be integer
% where Tot is the temporal windows of the fondamental pattern
% since Tot = N*(1/Fe)
% this forces the following constraints:
% N*fz0/Fe should be integer
% N*f0/Fe should be integer

% consequently, if fz0/Fe and f0/Fe are integers, than:

N   = (Fe/fz0);    % 
%Tot = N*dt;        % durée totale de la séquence

% number of steps offset dt_s for each actuators position : 
 DlySmpl = round(DelayLaw/dt_s); 

t = (0:N-1)*dt;  % time in us
carrier = sin(2*pi*f0*t);

if nbZ==0
   Wf = sign(carrier) ;
else
   Wf = sign(carrier).*(sin( 2*pi*fz*t )> 0 );   
end

 % number of time-points necessary = points in waveform + maximum DelayLaw
 % offset necessary for DelayLaw law
 N_T = length(Wf) + max(DlySmpl); 

%%% construction of a DelayLaw matrix : one column / actuator
 WF_mat = zeros(N_T,length(DelayLaw));

 for j = 1:length(DelayLaw)
     % offset for each actuator + normal waveform init
     WF_mat( DlySmpl(j)+(1:length(Wf)) , j ) = Wf;
 end
 
% convert m-1->mm-1
nuZ = 1e-3*nuZ;

%% print matrix
figure(100)
        imagesc(WF_mat)
        xlabel('x (mm)')
        ylabel('z(mm)')
        drawnow
end
    