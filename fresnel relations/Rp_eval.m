function Rp = Rp_eval( n1, n2 , theta )
%RP_EVAL Summary of this function goes here
%   Detailed explanation goes here
num = n1*sqrt( 1 - (n1*sin(theta)/n2).^2 ) - n2*cos(theta) ;
den = n1*sqrt( 1 - (n1*sin(theta)/n2).^2 ) + n2*cos(theta) ; 
Rp = abs(num./den).^2 ;
end

