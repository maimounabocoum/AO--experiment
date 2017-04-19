% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef OscilloscopeChannelTrigger < handle
    properties (GetAccess = protected, SetAccess = private)
        m_library;
        m_libraryName;
        m_enumsSupported;
        m_handle;
        m_ch;
    end
    properties (SetAccess = private)
        Levels;
        Hystereses;
        Times;
        IsAvailable;
        IsTriggered;
        Kinds;
        Conditions;
    end
    properties
        Enabled;
        Kind;
        Condition;
    end
    methods
        function obj = OscilloscopeChannelTrigger(library, handle, ch)
            obj.m_library = library;
            obj.m_libraryName = library.Name;
            obj.m_enumsSupported = library.EnumsSupported;
            obj.m_handle = handle;
            obj.m_ch = ch;
            obj.Levels = LibTiePie.OscilloscopeChannelTriggerLevels(library, handle, ch);
            obj.Hystereses = LibTiePie.OscilloscopeChannelTriggerHystereses(library, handle, ch);
            obj.Times = LibTiePie.OscilloscopeChannelTriggerTimes(library, handle, ch);
        end
    end
    methods
        function value = get.IsAvailable(self)
            value = calllib(self.m_libraryName, 'ScpChTrIsAvailable', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function value = get.IsTriggered(self)
            value = calllib(self.m_libraryName, 'ScpChTrIsTriggered', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function value = get.Enabled(self)
            value = calllib(self.m_libraryName, 'ScpChTrGetEnabled', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
        end

        function set.Enabled(self, value)
            calllib(self.m_libraryName, 'ScpChTrSetEnabled', self.m_handle, self.m_ch, value);
            self.m_library.checkLastStatus();
        end

        function value = get.Kinds(self)
            value = calllib(self.m_libraryName, 'ScpChTrGetKinds', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
            value = LibTiePie.BitMask2Array(value);
            if self.m_enumsSupported
                value = LibTiePie.Enum.TK(value);
            end
        end

        function value = get.Kind(self)
            value = calllib(self.m_libraryName, 'ScpChTrGetKind', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
            if self.m_enumsSupported
                value = LibTiePie.Enum.TK(value);
            end
        end

        function set.Kind(self, value)
            calllib(self.m_libraryName, 'ScpChTrSetKind', self.m_handle, self.m_ch, uint64(value));
            self.m_library.checkLastStatus();
        end

        function value = get.Conditions(self)
            value = calllib(self.m_libraryName, 'ScpChTrGetConditions', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
            value = LibTiePie.BitMask2Array(value);
            if self.m_enumsSupported
                value = LibTiePie.Enum.TC(value);
            end
        end

        function value = get.Condition(self)
            value = calllib(self.m_libraryName, 'ScpChTrGetCondition', self.m_handle, self.m_ch);
            self.m_library.checkLastStatus();
            if self.m_enumsSupported
                value = LibTiePie.Enum.TC(value);
            end
        end

        function set.Condition(self, value)
            calllib(self.m_libraryName, 'ScpChTrSetCondition', self.m_handle, self.m_ch, uint32(value));
            self.m_library.checkLastStatus();
        end
    end
end
