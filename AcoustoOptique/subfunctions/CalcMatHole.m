function [nuX,nuZ,t,Mat] = CalcMatHole(f0,nbX,nbZ,nuX0,nuZ0,x,Fe,c,Bascule)
% c input in m/s
% f0  (en MHz) est la fréquence de porteuse
% nuZ (en mm-1)
% nuX (en mm-1)
% Fe : sampling frequency of Aixplorer in MHz ; 
% x  : coordinate vector in mm

% conversion of all input to SI units : 

Fe = Fe*1e6 ;           % MHz->Hz
f0 = f0*1e6;            % MHz->Hz
nuZ = 1e3*(nbZ*nuZ0) ;  % mm-1->m-1
nuX = 1e3*(nbX*nuX0);   % mm-1->m-1
x = x*1e-3;             % mm->m

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

if strcmp(Bascule,'on')
N   = 2*(Fe/fz0);    % 
else
N   = (Fe/fz0);    %    
end

Tot = N*dt;        % durée totale de la séquence

 Tz = 1/fz;          % periode de l'envelloppe A in s
% T0 = 1/f0;          % periode de la porteuse A in s


                  



%   if (Tz ~= Tot/Nrep)
%       d = 999 ; %??
%   end

% Tz = Tot/nbZ;    % ré-ajustement de la période ??
% fz = 1/Tz   ;     % ré-ajustement de la fréquence (en MHz) ??
% nuZ = fz/c ;

% k = floor(Tot/T0); % nombre de cycles porteuse
% f0 = k/Tot; % ré-ajustement de la fréquence porteuse

t = (0:N-1)*dt;  % time in us

[X,T] = meshgrid(x-mean(x),t);

alpha = nuX/fz;
carrier = sin(2*pi*f0*T);
%carrier = sin(2*pi*f0*Tz*(1+sawtooth(pi*T/Tz)));
% 
% figure; plot(T)
% hold on ; plot(Tz*(1+sawtooth(pi*T/Tz)))


if strcmp(Bascule,'on')
    
        Am = mod(ceil(2*fz*(T-alpha*X)),4);
        Am(Am==2)=0;
        Am(Am==3)=-1;
        Mat = sign(carrier).*Am;
        
else
    
        if nbZ==0
           Mat = sign(carrier) ;
        else
           Mat = sign(carrier).*( sin( 2*pi*fz*(T-alpha*X) )> 0 );   
        end    
        
end

% if nbZ==0
%    Mat = sign(carrier) ;
% else
%    Mat = sign(carrier).*(sin( 2*pi*fz*(T-alpha*X) )> 0 ).*sign(sin( pi*fz*(T-alpha*X) ));   
%    %Mat = sign(sin( pi*fz*(T-alpha*X) ));
% end


% convert m-1->mm-1
nuZ = 1e-3*nuZ;
nuX = 1e-3*nuX;

%% print matrix
figure(100)
        imagesc(Mat)
        xlabel('x (mm)')
        ylabel('z(mm)')
        drawnow
end
    