% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef OscilloscopeChannel < handle
    properties (GetAccess = protected, SetAccess = private)
        m_library;
        m_libraryName;
        m_enumsSupported;
        m_handle;
        m_ch;
    end
    properties (SetAccess = private)
        Trigger;
        IsAvailable;
        ConnectorType;
        IsDifferential;
        Impedance;
        Couplings;
        Ranges;
        HasTrigger;
        DataValueMin;
        DataValueMax;
        IsRangeMaxReachable;
        HasConnectionTest;
    end
    properties
        Coupling;
        Enabled;
        ProbeGain;
        ProbeOffset;
        AutoRanging;
        Range;
    end
    methods
        function obj = OscilloscopeChannel(library, handle, ch)
            obj.m_library = library;
            obj.m_libraryName = library.Name;
            obj.m_enumsSupported = library.EnumsSupported;
            obj.m_handle = handle;
            obj.m_ch = ch;
            if obj.HasTrigger
                obj.Trigger = LibTiePie.OscilloscopeChannelTrigger(library, handle, ch);
            else
                obj.Trigger = 0;
            end
        end

        function [min, max] = getDataValueRange(self)
            [min, max] = calllib(self.m_libraryName, 'ScpChGetDataValueRange', self.m_handle, self.m_ch, 0, 0);
            self.m_library.checkLastStatus();
        end
    end
    methods
        function value = get.IsAvailable(self)
            value = calllib(self.m_libraryName, 'ScpChIsAvailable', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function value = get.ConnectorType(self)
            value = calllib(self.m_libraryName, 'ScpChGetConnectorType', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
            if self.m_enumsSupported
                value = LibTiePie.Enum.CONNECTORTYPE(value);
            end
        end

        function value = get.IsDifferential(self)
            value = calllib(self.m_libraryName, 'ScpChIsDifferential', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function value = get.Impedance(self)
            value = calllib(self.m_libraryName, 'ScpChGetImpedance', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function value = get.Couplings(self)
            value = calllib(self.m_libraryName, 'ScpChGetCouplings', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
            value = LibTiePie.BitMask2Array(value);
            if self.m_enumsSupported
                value = LibTiePie.Enum.CK(value);
            end
        end

        function value = get.Coupling(self)
            value = calllib(self.m_libraryName, 'ScpChGetCoupling', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
            if self.m_enumsSupported
                value = LibTiePie.Enum.CK(value);
            end
        end

        function set.Coupling(self, value)
            calllib(self.m_libraryName, 'ScpChSetCoupling', self.m_handle, self.m_ch, uint64(value));
            self.m_library.checkLastStatus();
        end

        function value = get.Enabled(self)
            value = calllib(self.m_libraryName, 'ScpChGetEnabled', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function set.Enabled(self, value)
            calllib(self.m_libraryName, 'ScpChSetEnabled', self.m_handle, self.m_ch, value);
            self.m_library.checkLastStatus();
        end

        function value = get.ProbeGain(self)
            value = calllib(self.m_libraryName, 'ScpChGetProbeGain', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function set.ProbeGain(self, value)
            calllib(self.m_libraryName, 'ScpChSetProbeGain', self.m_handle, self.m_ch, value);
            self.m_library.checkLastStatus();
        end

        function value = get.ProbeOffset(self)
            value = calllib(self.m_libraryName, 'ScpChGetProbeOffset', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function set.ProbeOffset(self, value)
            calllib(self.m_libraryName, 'ScpChSetProbeOffset', self.m_handle, self.m_ch, value);
            self.m_library.checkLastStatus();
        end

        function value = get.AutoRanging(self)
            value = calllib(self.m_libraryName, 'ScpChGetAutoRanging', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function set.AutoRanging(self, value)
            calllib(self.m_libraryName, 'ScpChSetAutoRanging', self.m_handle, self.m_ch, value);
            self.m_library.checkLastStatus();
        end

        function value = get.Ranges(self)
            length = calllib(self.m_libraryName, 'ScpChGetRanges', self.m_handle, self.m_ch, [], 0);
            self.m_library.checkLastStatus();
            [~, value] = calllib(self.m_libraryName, 'ScpChGetRanges', self.m_handle, self.m_ch, zeros(length, 1), length);
            self.m_library.checkLastStatus();
        end

        function value = get.Range(self)
            value = calllib(self.m_libraryName, 'ScpChGetRange', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function set.Range(self, value)
            calllib(self.m_libraryName, 'ScpChSetRange', self.m_handle, self.m_ch, value);
            self.m_library.checkLastStatus();
        end

        function value = get.HasTrigger(self)
            value = calllib(self.m_libraryName, 'ScpChHasTrigger', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function value = get.DataValueMin(self)
            value = calllib(self.m_libraryName, 'ScpChGetDataValueMin', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function value = get.DataValueMax(self)
            value = calllib(self.m_libraryName, 'ScpChGetDataValueMax', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function value = get.IsRangeMaxReachable(self)
            value = calllib(self.m_libraryName, 'ScpChIsRangeMaxReachable', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function value = get.HasConnectionTest(self)
            value = calllib(self.m_libraryName, 'ScpChHasConnectionTest', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end
    end
end
