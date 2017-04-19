% COMMON.LEGHAL.GETEXCEPTION (STATIC)
%   Reissue an exception.
%
%   NEW = COMMON.LEGHAL.GETEXCEPTION(OLD, OBJNAME, METHNAME) returns an
%   exception with an identifier built out of the OBJNAME and the METHNAME and
%   with exception OLD as its cause.
%
%   Note - This function is defined as a method of the class COMMON.LEGHAL. It
%   cannot be used without all methods of the class COMMON.LEGHAL and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/12/16

function varargout = GetException(varargin)

% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check the method syntax
if ( nargin ~= 3 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The common.legHAL.GetException static method needs 3 input ' ...
        'arguments:\n' ...
        '    1. an exception,\n' ...
        '    2. the full name of the object,\n' ...
        '    3. the name of the method calling the static method.'];
    error('COMMON:LEGHAL:GETEXCEPTION', ErrMsg);
    
elseif ( ~isa(varargin{1}, 'MException') )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The 1st argument of the common.legHAL.GetException static ' ...
        'method needs to belong to the MException class, and not the ' ...
        upper(class(varargin{1})) ' class.'];
    error('COMMON:LEGHAL:GETEXCEPTION', ErrMsg);
    
elseif ( ~ischar(varargin{2}) || ~ischar(varargin{3}) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The 2nd and 3rd arguments of the common.legHAL.GetException ' ...
        'static method needs to be character values (2nd = ' ...
        upper(class(varargin{2})) ' and 3rd = ' upper(class(varargin{3})) ').'];
    error('COMMON:LEGHAL:GETEXCEPTION', ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Build the new exception

% Build the new exception identifier
varargin{2}(findstr(varargin{2}, '.')) = ':';
ErrId = [upper(varargin{2}) ':' upper(varargin{3})];

% ============================================================================ %

% Build the new exception
varargout{1} = MException(ErrId, varargin{1}.message);
varargout{1} = addCause(varargout{1}, varargin{1});

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    rethrow(Exception);
end

% ============================================================================ %
% ============================================================================ %

end
