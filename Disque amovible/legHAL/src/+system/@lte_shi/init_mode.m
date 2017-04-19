function init_mode( obj, mode, varargin )
    obj = obj.setParam('Mode', mode);

    hydro = 0;
    rails_sides = obj.rails_th;

    switch mode
        case -1
            if nargin ~= 5
                error('Using mode -1, function must have 4 parameters')
            else
                % rails
                if strcmp( varargin{1}, 'rails_imaging' ) 
                    rails_sides = obj.rails_im;
                elseif strcmp( varargin{1}, 'rails_therapy' )
                    rails_sides = obj.rails_th;
                else
                    error('Second parameter must be "rails_imaging" or "rails_therapy"')
                end
                % relays
                if strcmp( varargin{2}, 'relays_imaging' ) 
                    rel_sides = obj.rel_im;
                elseif strcmp( varargin{2}, 'relays_therapy' )
                    rel_sides = obj.rel_th;
                else
                    error('Third parameter must be "relays_imaging" or "relays_therapy"')
                end
                % hydro
                if varargin{3} == 0 || varargin{3} == 1
                    hydro = varargin{3};
                else
                    error('Forth parameter must be 0 or 1')
                end
            end
            
        case 0
            rel_sides = obj.rel_th;

        case 1
            hydro = 1;
            rel_sides = obj.rel_th;

        case 2
%            setParam( 'imagingVoltage', 39.5 );
            rel_sides = obj.rel_im;
            rails_sides = obj.rails_im;

        case 3
            rel_sides = obj.rel_im;

        otherwise
    end
    
    disp( [ 'Sected mode : ' num2str(mode) ] )

    hv = obj.getParam( 'imagingVoltage' );
    obj.set_imaging_hv( hv );
    obj.init_dac();
    obj.init_digital_output();
    obj.init_digital_input();
    obj.set_rel( rel_sides, hydro );
    obj.set_rails( rails_sides );
end