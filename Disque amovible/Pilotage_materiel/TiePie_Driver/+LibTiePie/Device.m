% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef Device < handle
    properties (GetAccess = protected, SetAccess = private)
        m_library;
        m_libraryName;
        m_enumsSupported;
        m_handle;
    end
    properties (SetAccess = private)
        Handle;
        TriggerInputs = LibTiePie.TriggerInput.empty;
        TriggerOutputs = LibTiePie.TriggerOutput.empty;
        IsRemoved;
        DriverVersion;
        DriverVersionString;
        FirmwareVersion;
        FirmwareVersionString;
        CalibrationDate;
        SerialNumber;
        ProductId;
        VendorId;
        Type;
        Name;
        NameShort;
        NameShortest;
    end
    methods
        function obj = Device(library, handle)
            obj.m_library = library;
            obj.m_libraryName = library.Name;
            obj.m_enumsSupported = library.EnumsSupported;
            obj.m_handle = handle;
            for k = 1 : calllib(obj.m_libraryName, 'DevTrGetInputCount', handle)
              obj.TriggerInputs(k) = LibTiePie.TriggerInput(library, handle, k - 1);
            end
            for k = 1 : calllib(obj.m_libraryName, 'DevTrGetOutputCount', handle)
              obj.TriggerOutputs(k) = LibTiePie.TriggerOutput(library, handle, k - 1);
            end
          end

        function delete(self)
            calllib(self.m_libraryName, 'DevClose', self.m_handle);
            self.m_library = 0; % Release reference.
        end

        function result = getTriggerInputById(self, id)
            index = calllib(self.m_libraryName, 'DevTrGetInputIndexById', self.m_handle, id);
            self.m_library.checkLastStatus();
            if index < length(self.TriggerInputs)
                result = self.TriggerInputs(index + 1);
            else
                result = 0;
            end
        end

        function result = getTriggerOutputById(self, id)
            index = calllib(self.m_libraryName, 'DevTrGetOutputIndexById', self.m_handle, id);
            self.m_library.checkLastStatus();
            if index < length(self.TriggerOutputs)
                result = self.TriggerOutputs(index + 1);
            else
                result = 0;
            end
        end
    end
    methods
        function value = get.Handle(self)
            value = self.m_handle;
        end

        function value = get.IsRemoved(self)
            value = calllib(self.m_libraryName, 'DevIsRemoved', self.m_handle);
            self.m_library.checkLastStatus();
        end

        function value = get.DriverVersion(self)
            value = calllib(self.m_libraryName, 'DevGetDriverVersion', self.m_handle);
            self.m_library.checkLastStatus();
        end

        function value = get.DriverVersionString(self)
            value = LibTiePie.VersionNumber2String(self.DriverVersion);
        end

        function value = get.FirmwareVersion(self)
            value = calllib(self.m_libraryName, 'DevGetFirmwareVersion', self.m_handle);
            self.m_library.checkLastStatus();
        end

        function value = get.FirmwareVersionString(self)
            value = LibTiePie.VersionNumber2String(self.FirmwareVersion);
        end

        function value = get.CalibrationDate(self)
            value = calllib(self.m_libraryName, 'DevGetCalibrationDate', self.m_handle);
            self.m_library.checkLastStatus();
        end

        function value = get.SerialNumber(self)
            value = calllib(self.m_libraryName, 'DevGetSerialNumber', self.m_handle);
            self.m_library.checkLastStatus();
        end

        function value = get.ProductId(self)
            value = calllib(self.m_libraryName, 'DevGetProductId', self.m_handle);
            self.m_library.checkLastStatus();
        end

        function value = get.VendorId(self)
            value = calllib(self.m_libraryName, 'DevGetVendorId', self.m_handle);
            self.m_library.checkLastStatus();
        end

        function value = get.Type(self)
            value = calllib(self.m_libraryName, 'DevGetType', self.m_handle);
            self.m_library.checkLastStatus();
            if self.m_enumsSupported
                value = LibTiePie.Enum.DEVICETYPE(value);
            end
        end

        function value = get.Name(self)
            length = calllib(self.m_libraryName, 'DevGetName', self.m_handle, [], 0);
            self.m_library.checkLastStatus();
            [~, value] = calllib(self.m_libraryName, 'DevGetName', self.m_handle, blanks(length), length);
            self.m_library.checkLastStatus();
            value = native2unicode(uint8(value), 'UTF-8');
        end

        function value = get.NameShort(self)
            length = calllib(self.m_libraryName, 'DevGetNameShort', self.m_handle, [], 0);
            self.m_library.checkLastStatus();
            [~, value] = calllib(self.m_libraryName, 'DevGetNameShort', self.m_handle, blanks(length), length);
            self.m_library.checkLastStatus();
            value = native2unicode(uint8(value), 'UTF-8');
        end

        function value = get.NameShortest(self)
            length = calllib(self.m_libraryName, 'DevGetNameShortest', self.m_handle, [], 0);
            self.m_library.checkLastStatus();
            [~, value] = calllib(self.m_libraryName, 'DevGetNameShortest', self.m_handle, blanks(length), length);
            self.m_library.checkLastStatus();
            value = native2unicode(uint8(value), 'UTF-8');
        end
    end
end
