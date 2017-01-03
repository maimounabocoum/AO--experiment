function varargout=AcqTiePie(varargin)
% acousto-optic image with a TiePie HandyScope HS5 acq. card
% 03/04/2015 version
Scp=varargin{1};
SEQ=varargin{2}.SEQ;
Nmoy=varargin{2}.NTrig;
NPosX=round(varargin{2}.ScanLength/system.probe.Pitch);

data = zeros(N_points,NPosX);

SEQ = SEQ.startSequence();

for i=1:Nmoy
    Scp.Start;
    for ii=1:Scp.SegmentCount
        while ~( Scp.IsDataReady || Scp.IsRemoved )
            pause( 1e-7 ) % 100 ns delay, try later.
        end
        data(:,ii) = data(:,ii)+1/Nmoy*Scp.Data(:,2);
    end
end

varargout{1}=data;