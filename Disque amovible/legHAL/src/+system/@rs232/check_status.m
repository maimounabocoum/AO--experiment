function check_status( obj, msg, status )

    if ~strcmpi( status.type, 'ack' )
        ErrMsg = [ 'Fail to send ' msg.message ' using remote function ' msg.name ];
        error( ErrMsg );
    end
    
end