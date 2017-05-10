function AFG=TeK_AFG_3101_open()

% Find a VISA-USB object.
obj1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::1689::834::C021881::0::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = visa('TEK', 'USB0::1689::834::C021881::0::INSTR');
else
    fclose(obj1);
    obj1 = obj1(1);
end

set(obj1, 'InputBufferSize',512);
set(obj1, 'OutputBufferSize',512);

% Connect to instrument object, obj1.
fopen(obj1);

AFG=obj1;