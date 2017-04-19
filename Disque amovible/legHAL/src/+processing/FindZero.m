function ListRoots = FindZero(Y)


%find List of t[i] such that Y(t[i]) # 0
% algo : find sign reversal and then linear interpolation


N = length(Y);

SignReversal = ((Y(1:(N-1)).*Y(2:N))<=0);

T = find(SignReversal); % a root is between T(i) and T(i+1)
NumRoots = length(T);
ListRoots = zeros(NumRoots,1);
for iRoot = 1:NumRoots
        Ti = T(iRoot);
        Y0 = Y(Ti);
        Y1 = Y(Ti+1);
        %Linear Fit : Y(dt) = (Y1 - Y0) * dt + Y0 for dt = 0..1
        dt = -Y0/(Y1-Y0);
        ListRoots(iRoot) = Ti + dt;
end;







