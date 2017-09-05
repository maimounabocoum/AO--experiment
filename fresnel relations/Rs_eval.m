function Rs = Rp_eval( n1, n2 , theta )
%RP_EVAL Summary of this function goes here
%   Detailed explanation goes here
num = n1*cos(theta) - n2*sqrt( 1 - (n1*sin(theta)/n2).^2 );
den = n1*cos(theta) + n2*sqrt( 1 - (n1*sin(theta)/n2).^2 );
Rs = abs(num./den).^2 ;
end

