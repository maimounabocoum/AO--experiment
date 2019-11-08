function [nuX0,nuZ0] = EvalNu0(X0 , X1 , NU_low)
%this function allows to calculate Nux0 and Nuz0 before the loading of the
%sequence for optimal time spent.
% created by maimouna bocoum , 2019-10-30

%% System parameters import :
% ======================================================================= %
c           = common.constants.SoundSpeed ; %[m/s]
NbElemts    = system.probe.NbElemts ; 
pitch       = system.probe.Pitch ; % in mm

%% ==================== Codage en arbitrary : preparation des acmos ==============
% shooting elements 
ElmtBorns   = [min(NbElemts,max(1,round(X0/pitch))),max(1,min(NbElemts,round(X1/pitch)))];
ElmtBorns   = sort(ElmtBorns) ; % in case X0 and X1 are mixed up

Nbtot    = ElmtBorns(2) - ElmtBorns(1) + 1 ;

nuZ0 = (NU_low*1e6)/(c*1e3);                 % Pas fréquence spatiale en Z (en mm-1)
nuX0 = 1/(Nbtot*pitch);                      % Pas fréquence spatiale en X (en mm-1)

%% ==================== convert to SI unit
nuX0 = nuX0*1e3;
nuZ0 = nuZ0*1e3;

end

