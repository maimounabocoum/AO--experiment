% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef DeviceList < handle
    properties (GetAccess = protected, SetAccess = private)
        m_library;
        m_libraryName;
    end
    properties (SetAccess = private)
        Count;
    end
    methods
        function obj = DeviceList(library)
            obj.m_library = library;
            obj.m_libraryName = library.Name;
        end

        function result = getItemByIndex(self, index)
            serialNumber = calllib(self.m_libraryName, 'LstDevGetSerialNumber', LibTiePie.Const.IDKIND.INDEX, index);
            self.m_library.checkLastStatus();
            result = LibTiePie.DeviceListItem(self.m_library, serialNumber);
        end

        function result = getItemByProductId(self, pid)
            serialNumber = calllib(self.m_libraryName, 'LstDevGetSerialNumber', LibTiePie.Const.IDKIND.PRODUCTID, pid);
            self.m_library.checkLastStatus();
            result = LibTiePie.DeviceListItem(self.m_library, serialNumber);
        end

        function result = getItemBySerialNumber(self, serialNumber)
            serialNumber = calllib(self.m_libraryName, 'LstDevGetSerialNumber', LibTiePie.Const.IDKIND.SERIALNUMBER, serialNumber);
            self.m_library.checkLastStatus();
            result = LibTiePie.DeviceListItem(self.m_library, serialNumber);
        end

        function update(self)
            calllib(self.m_libraryName, 'LstUpdate');
            self.m_library.checkLastStatus();
        end

        function result = createCombinedDevice(self, devices)
            handles = zeros(1, length(devices), 'uint32');
            for k = 1 : length(devices)
                handles(k) = devices(k).Handle;
            end
            serialNumber = calllib(self.m_libraryName ,'LstCreateCombinedDevice', handles, length(handles));
            self.m_library.checkLastStatus();
            result = LibTiePie.DeviceListItem(self.m_library, serialNumber);
        end

        function result = createAndOpenCombinedDevice(self, devices)
            item = self.createCombinedDevice(devices);
            result = item.openDevice(item.Types(1));
        end

        function removeDevice(self, serialNumber)
            calllib(self.m_libraryName, 'LstRemoveDevice', serialNumber);
            self.m_library.checkLastStatus();
        end
    end
    methods
        function value = get.Count(self)
            value = calllib(self.m_libraryName, 'LstGetCount');
            self.m_library.checkLastStatus();
        end
    end
end
