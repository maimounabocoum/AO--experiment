function srv = remoteDefineServer (type,a,b)
%RUBIDEFINESERVER Define the server parameters
%
% Usage :
%   srv = RUBIDEFINESERVER(type, argA, argB)
%
% Description : 
%   Configure the server parameters and check the server remote version
%   The returned structure is the first paremeter to use with all remote
%   functions
%
%   Can be used with :
%       - type='extern'. argA parameter is required => srv IP
%                        argB parameter is required => srv port (must be 9999)
%                           ex : srv = remoteDefineServer ('extern', '192.138.1.34','9999')
%                                srv = remoteDefineServer ('extern', '127.0.0.1','9999')
%       - type='local'.  argA parameter is required => srv file (must be /tmp/remoteSocket)
%                                srv = remoteDefineServer ('local', '/tmp/remoteSocket')
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.


    if nargin >0
        if strcmp (type,'extern') && nargin == 3
            srv.type = type;
            srv.addr = a;
            srv.port = b;
        elseif strcmp (type,'local') && nargin == 2
            srv.type = type;
            srv.file = a;
        else
            error ('the type is not known or the argument numbers is false!!!');
        end
    end
    
    %Now check version
    clientVersion = '1.8';%'1.6.3';
    status = remoteCheckVersion(srv, clientVersion);
    if status.type == 'ack'
        disp (['Server version : ' status.server_version]);
        disp (['Client version : ' clientVersion]);
        if str2double(status.equal) == 1
            disp 'Client and server have the same version';
        else
            if str2double(status.compatible) == 1
                disp 'Warning : client and server have not the same version but are compatible'
            else
                error 'Client and server have not the same version and are not compatible'
            end
        end
    end
end
