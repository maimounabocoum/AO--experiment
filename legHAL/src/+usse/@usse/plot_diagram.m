function plot_diagram( obj, varargin )

    nb_event = length( obj.RemoteStruct.event )

    t0 = 0;
    for n = 1:nb_event
        d_local(n) = event_diagram( obj.RemoteStruct, n );
        d(n) = d_local(n);

        all_f = fields(d(n));
        for f_id = 1:length(all_f)
            f = all_f{f_id};
            d(n).(f) = d(n).(f) + t0 ;
        end
        
        t0 = d(n).event(2);
    end
    
%     d
    f = 'duration';
    fig = 6124145;
    figure(fig)
    hold off
    for k = 1:length(d)
        t = d(k).(f);
        plot( [ t(1) t(1) ], [ 0 1 ] )
        if k == 1
            hold on
        end
        plot( t, [ 1 1 ] )
        plot( [ t(2) t(2) ], [ 1 0 ] )
        plot( [ t(2) d(k).event(2) ], [ 0 0 ] )
    end
    ylim( [ -.1 1.1 ] )
end

% in us
function d = event_diagram( RemoteStruct, event_id )
    event = RemoteStruct.event(event_id);
%     event_id
%     event.noopMultiplier
    d.duration  = [ 0 event.duration ];
    d.noop      = [ d.duration(2) d.duration(2)+event.noop * event.noopMultiplier * 0.2 ];
    d.event     = [ 0 d.noop(2) ];
end