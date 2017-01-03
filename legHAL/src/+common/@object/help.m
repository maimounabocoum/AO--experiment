function help( obj )


NbPar = size( obj.Pars, 1 );

% parameters
all_parameters_ids = [];
Parameters = struct( 'name',{}, 'class',{} );
for n=1:NbPar
    tmp = obj.Pars(n,3);
    tmp_par = tmp{1};
    if isa( tmp_par, 'common.parameter' )
        all_parameters_ids = [ all_parameters_ids n ];
        tmp_name = obj.Pars(n,1);
        p.name = tmp_name{1};
        p.class = tmp_par.ParClass;
        Parameters(end+1) = p;
    end
end


% classes
S = superclasses( obj ) ;
all_classes = { obj.Type S{:} } ;

% Parameters

% tmp = { Parameters(:).class };
% all_class = unique( tmp );

help_str = [  'Class ' obj.Type ' : ' obj.Desc ] ;

for n = 1:length(all_classes)
    class_n = all_classes{n};
    class_ids = find( strcmp( { Parameters(:).class }, class_n) );
    
    if isempty( class_ids )
        continue
    end

%     disp( [ '-->' help_str ] )
    help_str = sprintf( '%s\n\n\n%s', help_str, [ 'Parameters inherited from class ' class_n ':' ] );
%     disp( [ '-->' help_str ] )
    
    for n2 = class_ids
        tmp = obj.Pars( all_parameters_ids(n2), 3 );
        par = tmp{1};
        
        default_value = par.Value;
        if isempty(default_value )
            default_value_str = '[]';
        elseif isnumeric( default_value )
            default_value_str = num2str( default_value );
        elseif ischar( default_value )
            default_value_str = [ '''' default_value '''' ];
        else
            default_value_str = '';
        end
    
        help_str = sprintf( '%s\n\n- %s (%s) %s (default = %s)', help_str, Parameters(n2).name, par.Type, par.Desc, default_value_str );
        for n3 = 1:length( par.AuthValues )
            val = par.AuthValues{ n3 };
            if isnumeric( val )
                if length( val ) > 1
                    val_str = num2str( val(1) );
                    for n4 = 2:length( val )
                        val_str = [ val_str ' ' num2str( val(n4) ) ];
                    end
                    val_str = [ '[ ' val_str ' ]' ];
                else
                    val_str = num2str( val );
                end
            else
                val_str = val;
            end
            help_str = sprintf( '%s\n  %s : %s', help_str, val_str, par.AuthDesc{n3} );
        end
    end
    
%     disp( [ '-->' help_str ] )

end

disp( help_str )

