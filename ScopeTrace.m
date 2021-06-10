classdef ScopeTrace
    %ScopeTrace Class for storing oscilloscope traces.
    
    properties
        FilePath
        TraceType
        Info
    end
    
    properties(Dependent)
        Time
        Voltage
        SecondVoltage
        UserText
        TrigtimeArray
        RisTimeArray
    end
    
    properties (Access = private)
        Echo
        CachedTrace
        fid
        Offset
        Locations
        HeaderFilePath
        RawInfo
        ValidImport = false
    end
    
    methods
        function obj = ScopeTrace(inputargs)
            arguments
                inputargs.FilePath
                inputargs.Echo        = false;
                inputargs.CachedTrace = false;
            end
            if ~isfield(inputargs,'FilePath')
                [file,path] = uigetfile('*');
                inputargs.FilePath = fullfile(path,file);
                clearvars file path
            end
            obj.FilePath    = inputargs.FilePath;
            obj.Echo        = inputargs.Echo;
            obj.CachedTrace = inputargs.CachedTrace;
            
            if isfile(obj.FilePath)
                
                obj = GetTraceType(obj);
                
                obj.fid = fopen(obj.FilePath,'r');
                switch obj.TraceType
                    case 'LeCroy (.trc)'
                        obj = GetLeCroyTrcInfo(obj);
                    case 'LeCroy (.dat)'
                        obj = GetLeCroyDatInfo(obj);
                    case 'Tektronix (.wfm)'
                        obj = GetTektronixWfmInfo(obj);
                    case 'Tektronix (.isf)'
                        obj = GetTektronixIsfInfo(obj);
                    case 'Tektronix (.dat)'
                        obj = GetTektronixDatInfo(obj);
                    case 'Tektronix (.csv)'
                        obj = GetTektronixCsvInfo(obj);
                    otherwise
                        obj.Info = 'Invalid File Type, must be: (.trc),(.dat),(.wfm),(.isf) or (.csv)';
                end
                
                fclose(obj.fid);
            end
        end
        
        function Time               = get.Time(obj)
            if obj.ValidImport
                switch obj.TraceType
                    case 'LeCroy (.trc)'
                        Time = GetLeCroyTrcTime(obj);
                    case 'LeCroy (.dat)'
                        Time = GetLeCroyDatTime(obj);
                    case 'Tektronix (.wfm)'
                        Time = GetTektronixWfmTime(obj);
                    case 'Tektronix (.isf)'
                        Time = GetTektronixIsfTime(obj);
                    case 'Tektronix (.dat)'
                        Time = GetTektronixDatTime(obj);
                    case 'Tektronix (.csv)'
                        Time = 'Not Currently Available for Tektronnix (.csv)';
                        %Time = GetTektronixCsvTime(obj);
                end
            else
                Time = 'Invalid Import';
            end
        end
        function Voltage            = get.Voltage(obj)
            if obj.ValidImport
                switch obj.TraceType
                    case 'LeCroy (.trc)'
                        Voltage = GetLeCroyTrcVoltage(obj);
                    case 'LeCroy (.dat)'
                        Voltage = GetLeCroyDatVoltage(obj);
                    case 'Tektronix (.wfm)'
                        Voltage = GetTektronixWfmVoltage(obj);
                    case 'Tektronix (.isf)'
                        Voltage = GetTektronixIsfVoltage(obj);
                    case 'Tektronix (.dat)'
                        Voltage = GetTektronixDatVoltage(obj);
                    case 'Tektronix (.csv)'
                        Voltage = 'Not Currently Available for Tektronnix (.csv)';
                        %Voltage = GetTektronixCsvVoltage(obj);
                end
            else
                Voltage = 'Invalid Import';
            end
        end
        function SecondVoltage      = get.SecondVoltage(obj)
            if obj.ValidImport
                switch obj.TraceType
                    case 'LeCroy (.trc)'
                        SecondVoltage   = GetLeCroyTrcSecondVoltage(obj);
                    case 'Tektronix (.wfm)'
                        SecondVoltage = 'Not Currently Available for Tektronnix (.wfm)';
                        %SecondVoltage   = GetTektronixWfmSecondVoltage(obj);
                    case 'Tektronix (.csv)'
                        SecondVoltage = 'Not Available for Tektronnix (.csv)';
                        %SecondVoltage   = GetTektronixCsvSecondVoltage(obj);
                end
            else
                SecondVoltage = 'Invalid Import';
            end
        end
        function UserText           = get.UserText(obj)
            if obj.ValidImport
                switch obj.TraceType
                    case 'LeCroy (.trc)'
                        UserText = GetLeCroyTrcUserText(obj);
                end
            else
                UserText = 'Invalid Import';
            end
        end
        function TrigtimeArray      = get.TrigtimeArray(obj)
            if obj.ValidImport 
                switch obj.TraceType
                    case 'LeCroy (.trc)'
                        TrigtimeArray   = GetLeCroyTrcTrigtimeArray(obj);
                end
            else
                TrigtimeArray = 'Invalid Import';
            end
        end
        function RisTimeArray       = get.RisTimeArray(obj)
            if obj.ValidImport
                switch obj.TraceType
                    case 'LeCroy (.trc)'
                        RisTimeArray    = GetLeCroyTrcRisTimeArray(obj);
                end
            else
                RisTimeArray = 'Invalid Import';
            end
            
        end
        
        function TracePlot          = PlotTrace(obj,Ax)
            if obj.ValidImport
                if ~exist('Ax') %#ok<EXIST>
                    TracePlot = figure();
                    Ax = axes(TracePlot);
                end
                plot(Ax,obj.Time,obj.Voltage)
            else
                TracePlot = 'Invalid Import';
            end
        end
        function Waveform           = Waveform(obj)
            if obj.ValidImport
                switch obj.TraceType
                    case 'LeCroy (.trc)'
                        Waveform.time    = GetLeCroyTrcTime(obj);
                        Waveform.voltage = GetLeCroyTrcVoltage(obj);
                    case 'LeCroy (.dat)'
                        Waveform.time    = GetLeCroyDatTime(obj);
                        Waveform.voltage = GetLeCroyDatVoltage(obj);
                    case 'Tektronix (.wfm)'
                        Waveform.time    = GetTektronixWfmTime(obj);
                        Waveform.voltage = GetTektronixWfmVoltage(obj);
                    case 'Tektronix (.isf)'
                        Waveform.time    = GetTektronixIsfTime(obj);
                        Waveform.voltage = GetTektronixIsfVoltage(obj);
                    case 'Tektronix (.dat)'
                        Waveform.time    = GetTektronixDatTime(obj);
                        Waveform.voltage = GetTektronixDAtVoltage(obj);
                end
            else
                Waveform = 'Invalid Import';
            end
        end
        function SingleWaveform     = SingleWaveform(obj)
            if obj.ValidImport    
                switch obj.TraceType
                    case 'LeCroy (.trc)'
                        [SingleWaveform.time   ,TimeError   ] = GetLeCroyTrcTimeSingle(obj);
                        [SingleWaveform.voltage,VoltageError] = GetLeCroyTrcVoltageSingle(obj);
                        SingleWaveform.Quality = 1 - hypot(TimeError,VoltageError);
                    case 'LeCroy (.dat)'
                        [SingleWaveform.time   ,TimeError   ] = GetLeCroyDatTimeSingle(obj);
                        [SingleWaveform.voltage,VoltageError] = GetLeCroyDatVoltageSingle(obj);
                        SingleWaveform.Quality = 1 - hypot(TimeError,VoltageError);
                    case 'Tektronix (.wfm)'
                        [SingleWaveform.time   ,TimeError   ] = GetTektronixWfmTimeSingle(obj);
                        [SingleWaveform.voltage,VoltageError] = GetTektronixWfmVoltageSingle(obj);
                        SingleWaveform.Quality = 1 - hypot(TimeError,VoltageError);
                    case 'Tektronix (.isf)'
                        [SingleWaveform.time   ,TimeError   ] = GetTektronixIsfTimeSingle(obj);
                        [SingleWaveform.voltage,VoltageError] = GetTektronixIsfVoltageSingle(obj);
                        SingleWaveform.Quality = 1 - hypot(TimeError,VoltageError);
                    case 'Tektronix (.dat)'
                        [SingleWaveform.time   ,TimeError   ] = GetTektronixDatTimeSingle(obj);
                        [SingleWaveform.voltage,VoltageError] = GetTektronixDatVoltageSingle(obj);
                        SingleWaveform.Quality = 1 - hypot(TimeError,VoltageError);
                end
            else
                SingleWaveform = 'Invalid Import';
            end
        end
        function time               = time(obj)
            time = obj.Time;
        end
        function voltage            = voltage(obj)
            voltage = obj.Voltage;
        end
    end
    
    methods (Access = private)
        function obj                = GetTraceType(obj)
            switch obj.FilePath(end-3:end)
                case '.trc'
                    obj.TraceType = 'LeCroy (.trc)';
                case '.isf'
                    obj.TraceType = 'Tektronix (.isf)';
                case '.wfm'
                    obj.TraceType = 'Tektronix (.wfm)';
                case '.dat' 
                    obj.TraceType = obj.DecipherDatType(obj.FilePath);
                otherwise
                    obj.TraceType = 'Unsupported Trace Type';
            end
        end
        % LeCroy .trc Methods
        function obj                = GetLeCroyTrcInfo(obj)
            
            obj.Offset    = strfind(fread(obj.fid,50,'char')','WAVEDESC') - 1;
            
            obj.Locations.TEMPLATE_NAME        = obj.Offset + 16;   % string
            obj.Locations.COMM_TYPE            = obj.Offset + 32;   % enum
            obj.Locations.COMM_ORDER           = obj.Offset + 34;   % enum
            obj.Locations.WAVE_DESCRIPTOR      = obj.Offset + 36;   % long length of the descriptor block
            obj.Locations.USER_TEXT            = obj.Offset + 40;   % long  length of the usertext block
            obj.Locations.RES_DESC1            = obj.Offset + 44;   % long
            obj.Locations.TRIGTIME_ARRAY       = obj.Offset + 48;   % long
            obj.Locations.RIS_TIME_ARRAY       = obj.Offset + 52;   % long
            obj.Locations.RES_ARRAY            = obj.Offset + 56;   % long
            obj.Locations.WAVE_ARRAY_1         = obj.Offset + 60;   % long length (in Byte) of the sample array
            obj.Locations.WAVE_ARRAY_2         = obj.Offset + 64;   % long length (in Byte) of the optional second sample array
            obj.Locations.RES_ARRAY2           = obj.Offset + 68;   % long
            obj.Locations.RES_ARRAY3           = obj.Offset + 72;   % long
            obj.Locations.INSTRUMENT_NAME      = obj.Offset + 76;   % string
            obj.Locations.INSTRUMENT_NUMBER    = obj.Offset + 92;   % long
            obj.Locations.TRACE_LABEL          = obj.Offset + 96;   % string
            obj.Locations.RESERVED1            = obj.Offset + 112;  % word
            obj.Locations.RESERVED2            = obj.Offset + 114;  % word
            obj.Locations.WAVE_ARRAY_COUNT     = obj.Offset + 116;  % long
            obj.Locations.PNTS_PER_SCREEN      = obj.Offset + 120;  % long
            obj.Locations.FIRST_VALID_PNT      = obj.Offset + 124;  % long
            obj.Locations.LAST_VALID_PNT       = obj.Offset + 128;  % long
            obj.Locations.FIRST_POINT          = obj.Offset + 132;  % long
            obj.Locations.SPARSING_FACTOR      = obj.Offset + 136;  % long
            obj.Locations.SEGMENT_INDEX        = obj.Offset + 140;  % long
            obj.Locations.SUBARRAY_COUNT       = obj.Offset + 144;  % long
            obj.Locations.SWEEPS_PER_AQG       = obj.Offset + 148;  % long
            obj.Locations.POINTS_PER_PAIR      = obj.Offset + 152;  % word
            obj.Locations.PAIR_OFFSET          = obj.Offset + 154;  % word
            obj.Locations.VERTICAL_GAIN        = obj.Offset + 156;  % float
            obj.Locations.VERTICAL_OFFSET      = obj.Offset + 160;  % float
            obj.Locations.MAX_VALUE            = obj.Offset + 164;  % float
            obj.Locations.MIN_VALUE            = obj.Offset + 168;  % float
            obj.Locations.NOMINAL_BITS         = obj.Offset + 172;  % word
            obj.Locations.NOM_SUBARRAY_COUNT   = obj.Offset + 174;  % word
            obj.Locations.HORIZ_INTERVAL       = obj.Offset + 176;  % float
            obj.Locations.HORIZ_OFFSET         = obj.Offset + 180;  % double
            obj.Locations.PIXEL_OFFSET         = obj.Offset + 188;  % double
            obj.Locations.VERTUNIT             = obj.Offset + 196;  % unit_definition
            obj.Locations.HORUNIT              = obj.Offset + 244;  % unit_definition
            obj.Locations.HORIZ_UNCERTAINTY    = obj.Offset + 292;  % float
            obj.Locations.TRIGGER_TIME         = obj.Offset + 296;  % time_stamp
            obj.Locations.ACQ_DURATION         = obj.Offset + 312;  % float
            obj.Locations.RECORD_TYPE          = obj.Offset + 316;  % enum
            obj.Locations.PROCESSING_DONE      = obj.Offset + 318;  % enum
            obj.Locations.RESERVED5            = obj.Offset + 320;  % word
            obj.Locations.RIS_SWEEPS           = obj.Offset + 322;  % word
            obj.Locations.TIMEBASE             = obj.Offset + 324;  % enum
            obj.Locations.VERT_COUPLING        = obj.Offset + 326;  % enum
            obj.Locations.PROBE_ATT            = obj.Offset + 328;  % float
            obj.Locations.FIXED_VERT_GAIN      = obj.Offset + 332;  % enum
            obj.Locations.BANDWIDTH_LIMIT      = obj.Offset + 334;  % enum
            obj.Locations.VERTICAL_VERNIER     = obj.Offset + 336;  % enum
            obj.Locations.ACQ_VERT_OFFSET      = obj.Offset + 340;  % float
            obj.Locations.WAVE_SOURCE          = obj.Offset + 344;  % enum
            
            if logical(obj.ReadEnumLecroy(obj.fid,obj.Locations.COMM_ORDER))
                fclose(obj.fid);
                obj.fid=fopen(obj.FilePath,'r','ieee-le');		% HIFIRST
            else
                fclose(obj.fid);
                obj.fid=fopen(obj.FilePath,'r','ieee-be');		% LOFIRST
            end
            
            obj.Info.template_name           = obj.ReadString(         obj.fid,obj.Locations.TEMPLATE_NAME);
            obj.Info.comm_type               = obj.ReadEnumLecroy(     obj.fid,obj.Locations.COMM_TYPE);
            obj.Info.comm_order              = obj.ReadEnumLecroy(     obj.fid,obj.Locations.COMM_ORDER);
            obj.Info.wave_descriptor         = obj.ReadLong(           obj.fid,obj.Locations.WAVE_DESCRIPTOR);
            obj.Info.user_text               = obj.ReadLong(           obj.fid,obj.Locations.USER_TEXT);
            obj.Info.res_desc1               = obj.ReadLong(           obj.fid,obj.Locations.RES_DESC1);
            obj.Info.trigtime_array          = obj.ReadLong(           obj.fid,obj.Locations.TRIGTIME_ARRAY);
            obj.Info.ris_time_array          = obj.ReadLong(           obj.fid,obj.Locations.RIS_TIME_ARRAY);
            obj.Info.res_array               = obj.ReadLong(           obj.fid,obj.Locations.RES_ARRAY);
            obj.Info.wave_array1             = obj.ReadLong(           obj.fid,obj.Locations.WAVE_ARRAY_1);
            obj.Info.wave_array2             = obj.ReadLong(           obj.fid,obj.Locations.WAVE_ARRAY_2);
            obj.Info.res_array2              = obj.ReadLong(           obj.fid,obj.Locations.RES_ARRAY2);
            obj.Info.res_array3              = obj.ReadLong(           obj.fid,obj.Locations.RES_ARRAY3);
            obj.Info.instrument_name         = obj.ReadString(         obj.fid,obj.Locations.INSTRUMENT_NAME);
            obj.Info.instrument_number       = obj.ReadLong(           obj.fid,obj.Locations.INSTRUMENT_NUMBER);
            obj.Info.trace_label             = obj.ReadString(         obj.fid,obj.Locations.TRACE_LABEL);
            obj.Info.reserved1               = obj.ReadWord(           obj.fid,obj.Locations.RESERVED1);
            obj.Info.reserved2               = obj.ReadWord(           obj.fid,obj.Locations.RESERVED2);
            obj.Info.wave_array_count        = obj.ReadLong(           obj.fid,obj.Locations.WAVE_ARRAY_COUNT);
            obj.Info.points_per_screen       = obj.ReadLong(           obj.fid,obj.Locations.PNTS_PER_SCREEN);
            obj.Info.first_valid_point       = obj.ReadLong(           obj.fid,obj.Locations.FIRST_VALID_PNT);
            obj.Info.last_valid_point        = obj.ReadLong(           obj.fid,obj.Locations.LAST_VALID_PNT);
            obj.Info.first_point             = obj.ReadLong(           obj.fid,obj.Locations.FIRST_POINT);
            obj.Info.sparsing_factor         = obj.ReadLong(           obj.fid,obj.Locations.SPARSING_FACTOR);
            obj.Info.segment_index           = obj.ReadLong(           obj.fid,obj.Locations.SEGMENT_INDEX);
            obj.Info.subarray_count          = obj.ReadLong(           obj.fid,obj.Locations.SUBARRAY_COUNT);
            obj.Info.sweeps_per_aqg          = obj.ReadLong(           obj.fid,obj.Locations.SWEEPS_PER_AQG);
            obj.Info.points_per_pair         = obj.ReadWord(           obj.fid,obj.Locations.POINTS_PER_PAIR);
            obj.Info.pair_offset             = obj.ReadWord(           obj.fid,obj.Locations.PAIR_OFFSET);
            obj.Info.vertical_gain           = obj.ReadFloat(          obj.fid,obj.Locations.VERTICAL_GAIN);
            obj.Info.vertical_offset         = obj.ReadFloat(          obj.fid,obj.Locations.VERTICAL_OFFSET);
            obj.Info.max_value               = obj.ReadFloat(          obj.fid,obj.Locations.MAX_VALUE);
            obj.Info.min_value               = obj.ReadFloat(          obj.fid,obj.Locations.MIN_VALUE);
            obj.Info.nominal_bits            = obj.ReadWord(           obj.fid,obj.Locations.NOMINAL_BITS);
            obj.Info.nom_subarray_count      = obj.ReadWord(           obj.fid,obj.Locations.NOM_SUBARRAY_COUNT);
            obj.Info.horizontal_interval     = obj.ReadFloat(          obj.fid,obj.Locations.HORIZ_INTERVAL);
            obj.Info.horizontal_offset       = obj.ReadDouble(         obj.fid,obj.Locations.HORIZ_OFFSET);
            obj.Info.pixel_offset            = obj.ReadDouble(         obj.fid,obj.Locations.PIXEL_OFFSET);
            obj.Info.vertical_unit           = obj.ReadUnitDefinition( obj.fid,obj.Locations.VERTUNIT);
            obj.Info.horizontal_unit         = obj.ReadUnitDefinition( obj.fid,obj.Locations.HORUNIT);
            obj.Info.horizontal_uncertainty  = obj.ReadFloat(          obj.fid,obj.Locations.HORIZ_UNCERTAINTY);
            obj.Info.trigger_time            = obj.ReadTimestamp(      obj.fid,obj.Locations.TRIGGER_TIME);
            obj.Info.acq_duration            = obj.ReadFloat(          obj.fid,obj.Locations.ACQ_DURATION);
            obj.Info.recording_type          = obj.ReadEnumLecroy(     obj.fid,obj.Locations.RECORD_TYPE);
            obj.Info.processing_done         = obj.ReadEnumLecroy(     obj.fid,obj.Locations.PROCESSING_DONE);
            obj.Info.reserved5               = obj.ReadWord(           obj.fid,obj.Locations.RESERVED5);
            obj.Info.ris_sweeps              = obj.ReadWord(           obj.fid,obj.Locations.RIS_SWEEPS);
            obj.Info.timebase                = obj.ReadEnumLecroy(     obj.fid,obj.Locations.TIMEBASE);
            obj.Info.vertical_coupling       = obj.ReadEnumLecroy(     obj.fid,obj.Locations.VERT_COUPLING);
            obj.Info.probe_attenuation       = obj.ReadFloat(          obj.fid,obj.Locations.PROBE_ATT);
            obj.Info.fixed_vertical_gain     = obj.ReadEnumLecroy(     obj.fid,obj.Locations.FIXED_VERT_GAIN);
            obj.Info.bandwidth_limit         = obj.ReadEnumLecroy(     obj.fid,obj.Locations.BANDWIDTH_LIMIT);
            obj.Info.vertical_vernier        = obj.ReadFloat(          obj.fid,obj.Locations.VERTICAL_VERNIER);
            obj.Info.acq_vertical_offset     = obj.ReadFloat(          obj.fid,obj.Locations.ACQ_VERT_OFFSET);
            obj.Info.wave_source             = obj.ReadEnumLecroy(     obj.fid,obj.Locations.WAVE_SOURCE);
            
            tmp = ['byte';'word'];
            obj.Info.comm_type = tmp(1+obj.Info.comm_type,:);
            
            tmp = ['LOFIRST';'HIFIRST'];
            obj.Info.comm_order = tmp(1+obj.Info.comm_order,:);
            
            tmp=[
                'single_sweep      ';	'interleaved       '; 'histogram         ';
                'graph             ';	'filter_coefficient'; 'complex           ';
                'extrema           ';	'sequence_obsolete '; 'centered_RIS      ';
                'peak_detect       '];
            obj.Info.recording_type = deblank(tmp(1+obj.Info.recording_type,:));
            
            tmp=[
                'no_processing';   'fir_filter   '; 'interpolated ';   'sparsed      ';
                'autoscaled   ';   'no_result    '; 'rolling      ';   'cumulative   '];
            obj.Info.processing_done		= deblank(tmp (1+obj.Info.processing_done,:));
            
            if obj.Info.timebase == 100
                obj.Info.timebase = 'EXTERNAL';
            else
                tmp=[
                    '1 ps / div  ';'2 ps / div  ';'5 ps / div  ';'10 ps / div ';'20 ps / div ';'50 ps / div ';'100 ps / div';'200 ps / div';'500 ps / div';
                    '1 ns / div  ';'2 ns / div  ';'5 ns / div  ';'10 ns / div ';'20 ns / div ';'50 ns / div ';'100 ns / div';'200 ns / div';'500 ns / div';
                    '1 us / div  ';'2 us / div  ';'5 us / div  ';'10 us / div ';'20 us / div ';'50 us / div ';'100 us / div';'200 us / div';'500 us / div';
                    '1 ms / div  ';'2 ms / div  ';'5 ms / div  ';'10 ms / div ';'20 ms / div ';'50 ms / div ';'100 ms / div';'200 ms / div';'500 ms / div';
                    '1 s / div   ';'2 s / div   ';'5 s / div   ';'10 s / div  ';'20 s / div  ';'50 s / div  ';'100 s / div ';'200 s / div ';'500 s / div ';
                    '1 ks / div  ';'2 ks / div  ';'5 ks / div  '];
                obj.Info.timebase = deblank(tmp(1+obj.Info.timebase,:));
            end
            
            tmp=['DC_50_Ohms'; 'ground    ';'DC 1MOhm  ';'ground    ';'AC 1MOhm  '];
            obj.Info.vertical_coupling		= deblank(tmp(1+obj.Info.vertical_coupling,:));
            
            tmp=[
                '1 uV / div  ';'2 uV / div  ';'5 uV / div  ';'10 uV / div ';'20 uV / div ';'50 uV / div ';'100 uV / div';'200 uV / div';'500 uV / div';
                '1 mV / div  ';'2 mV / div  ';'5 mV / div  ';'10 mV / div ';'20 mV / div ';'50 mV / div ';'100 mV / div';'200 mV / div';'500 mV / div';
                '1 V / div   ';'2 V / div   ';'5 V / div   ';'10 V / div  ';'20 V / div  ';'50 V / div  ';'100 V / div ';'200 V / div ';'500 V / div ';
                '1 kV / div  '];
            obj.Info.fixed_vertical_gain = deblank(tmp(1+obj.Info.fixed_vertical_gain,:));
            
            tmp=['off'; 'on '];
            obj.Info.bandwidth_limit	= deblank(tmp(1+obj.Info.bandwidth_limit,:));
            
            if obj.Info.wave_source == 9
                obj.Info.wave_source = 'UNKNOWN';
            else
                tmp=['C1     ';'C2     ';'C3     ';'C4     ';'UNKNOWN'];
                obj.Info.wave_source = deblank(tmp (1+obj.Info.wave_source,:));
            end
            clearvars tmp
            
            obj.ValidImport = true;
        end
        function Time               = GetLeCroyTrcTime(obj)
            Time = (0:obj.Info.wave_array_count-1) * obj.Info.horizontal_interval + obj.Info.horizontal_offset;
            Time = Time(:);
        end
        function [Time,Error]       = GetLeCroyTrcTimeSingle(obj)
            Time  = single(GetLeCroyTrcTime(obj));
            Error = double(eps(Time(end))) / obj.Info.horizontal_interval;
        end
        function Voltage            = GetLeCroyTrcVoltage(obj)
            if logical(obj.Info.wave_array1)
                
                switch obj.Info.comm_order
                    case 'HIFIRST'
                        obj.fid=fopen(obj.FilePath,'r','ieee-le');
                    case 'LOFIRST'
                        obj.fid=fopen(obj.FilePath,'r','ieee-be');
                end
                
                fseek(obj.fid, obj.Offset + obj.Info.wave_descriptor + obj.Info.user_text + obj.Info.trigtime_array + obj.Info.ris_time_array, 'bof');
                switch obj.Info.comm_type
                    case 'word'
                        Voltage=fread(obj.fid,obj.Info.wave_array1 / 2, 'int16');
                    case 'byte'
                        Voltage=fread(obj.fid,obj.Info.wave_array1    , 'int8');
                end
                Voltage = Voltage * obj.Info.vertical_gain - obj.Info.vertical_offset;
                
                fclose(obj.fid);
                
            end
        end
        function [Voltage,Error]    = GetLeCroyTrcVoltageSingle(obj)
                Voltage = single(GetLeCroyTrcVoltage(obj));
                Error = double(eps(max(abs(Voltage)))) / obj.Info.vertical_gain;
        end
        function SecondVoltage      = GetLeCroyTrcSecondVoltage(obj)
            if logical(obj.Info.wave_array2)
                
                switch obj.Info.comm_order
                    case 'HIFIRST'
                        obj.fid=fopen(obj.FilePath,'r','ieee-le');
                    case 'LOFIRST'
                        obj.fid=fopen(obj.FilePath,'r','ieee-be');
                end
                
                SecondVoltage = 'Uncertain On Validity of object, see Liam and save as (.dat)';
%                 fseek(obj.fid, ...
%                     obj.Offset + obj.Info.wave_descriptor + obj.Info.user_text + obj.Info.trigtime_array + obj.Info.ris_time_array + obj.Info.wave_array1 , 'bof');
%                 switch obj.Info.comm_type
%                     case 'word'
%                         SecondVoltage = fread(obj.fid,obj.Info.wave_array2 / 2,'int16');
%                     case 'byte'
%                         SecondVoltage = fread(obj.fid,obj.Info.wave_array2    ,'int8');
%                 end
%                 SecondVoltage = SecondVoltage * obj.Info.vertical_gain - obj.Info.vertical_offset;
                
                fclose(obj.fid);
                
            end
        end
        function UserText           = GetLeCroyTrcUserText(obj)
            if logical(obj.Info.user_text)
                
                switch obj.Info.comm_order
                    case 'HIFIRST'
                        obj.fid=fopen(obj.FilePath,'r','ieee-le');
                    case 'LOFIRST'
                        obj.fid=fopen(obj.FilePath,'r','ieee-be');
                end
                
                UserText = 'Uncertain On Validity of object, see Liam and save as (.dat)';
%                 fseek(obj.fid,obj.Offset+obj.Info.wave_descriptor,'bof');
%                 UserText = fread(obj.fid,obj.Info.user_text,'char');
%                 
                fclose(obj.fid);
            end
        end
        function TrigtimeArray      = GetLeCroyTrcTrigtimeArray(obj)
            if logical(obj.Info.trigtime_array)
                
                switch obj.Info.comm_order
                    case 'HIFIRST'
                        obj.fid=fopen(obj.FilePath,'r','ieee-le');
                    case 'LOFIRST'
                        obj.fid=fopen(obj.FilePath,'r','ieee-be');
                end
                
                TrigtimeArray  = 'Uncertain On Validity of object, see Liam and save as (.dat)';
%                 TrigtimeArray.trigger_time = [];
%                 TrigtimeArray.trigger_offset = [];
%                 for i = 0:(obj.Info.nom_subarray_count-1)
%                     TrigtimeArray.trigger_time(i+1)   = obj.ReadDouble(obj.fid, obj.Offset + obj.Info.wave_descriptor + obj.Info.user_text + (i*16));
%                     TrigtimeArray.trigger_offset(i+1) = obj.ReadDouble(obj.fid, obj.Offset + obj.Info.wave_descriptor + obj.Info.user_text + (i*16) + 8);
%                 end
%                 TrigtimeArray.trigger_time   = obj.ReadDouble(obj.fid, obj.Offset + obj.Info.wave_descriptor + obj.Info.user_text);
%                 TrigtimeArray.trigger_offset = obj.ReadDouble(obj.fid, obj.Offset + obj.Info.wave_descriptor + obj.Info.user_text + 8);
                
                fclose(obj.fid);
            end
        end
        function RisTimeArray       = GetLeCroyTrcRisTimeArray(obj)
            
            if logical(obj.Info.ris_time_array)
                
                switch obj.Info.comm_order
                    case 'HIFIRST'
                        obj.fid=fopen(obj.FilePath,'r','ieee-le');
                    case 'LOFIRST'
                        obj.fid=fopen(obj.FilePath,'r','ieee-be');
                end
                
                RisTimeArray = 'Uncertain On Validity of object, see Liam and save as (.dat)';
%                 fseek(obj.fid,obj.Offset+obj.Info.wave_descriptor + obj.Info.user_text+obj.Info.trigtime_array,'bof');
%                 RisTimeArray.ris_offset = fread(obj.fid,obj.Info.ris_sweeps,'float64');
                
                fclose(obj.fid);
            end
            
        end
        % LeCroy .dat Methods
        function obj                = GetLeCroyDatInfo(obj)
            
            TimeTmp = fscanf(obj.fid,'%f %*f');
            
            obj.Info.StartTime = min(TimeTmp);
            obj.Info.EndTime   = max(TimeTmp);
            obj.Info.NumberOfPoints = numel(TimeTmp);
            obj.Info.HorizontalInterval = abs(TimeTmp(2)-TimeTmp(1));
            
            obj.ValidImport = true;
        end
        function Time               = GetLeCroyDatTime(obj)
            Time = linspace(obj.Info.StartTime, ...
                            obj.Info.EndTime, ...
                            obj.Info.NumberOfPoints)';
        end
        function [Time,Error]       = GetLeCroyDatTimeSingle(obj)
            Time  = single(GetLeCroyDatTime(obj));
            Error = double(eps(Time(end))) / obj.Info.HorizontalInterval;
        end
        function Voltage            = GetLeCroyDatVoltage(obj)
            
            CompressedFilePath = [obj.FilePath(1:end-4),'CompressedVoltage'];
            
            if ~isfile(CompressedFilePath)
                obj.fid = fopen(obj.FilePath);
                Voltage = fscanf(obj.fid,'%*f %f');
                fclose(obj.fid);
                obj.WriteCompressedWaveform(CompressedFilePath,Voltage)
            else
                Voltage = obj.ReadCompressedWaveform(CompressedFilePath, ...
                                                 obj.Info.NumberOfPoints);
            end
        end
        function [Voltage,Error]    = GetLeCroyDatVoltageSingle(obj)
            Voltage = single(GetLeCroyDatVoltage(obj));
            Error = double(eps(max(abs(Voltage)))) / min(abs(diff(unique(Voltage))));
        end
        % Tektronix .wfm Methods
        function obj                = GetTektronixWfmInfo(obj)
            % Locations found by Liam on 7254, could vary scope to scope as no specific format for tek scopes.
            
            byte_order = fread(obj.fid,1,'ushort'); %reading the byte order
            fclose(obj.fid);
            switch byte_order
                case 61680 %equivalent to hexidecimal 0xF0F0, which is big endian
                    obj.fid = fopen(obj.FilePath,'r','ieee-be'); %reopening file with big endian format
                case 3855 %equivalent to hexidecimal 0x0F0F, which is little endian
                    obj.fid = fopen(obj.FilePath,'r','ieee-le'); %reopening file with little endian format
                otherwise
                    obj.Info = 'Invalid Import';
                    return
            end
            clearvars byte_order
            
            % Static File Information                                                                     location  format              length in bytes
            obj.Locations.Waveform_static_file_information.Byte_order_verification                      = 0;        %unsigned short     2
            obj.Locations.Waveform_static_file_information.Version_number                               = 3;        %char               8
            obj.Locations.Waveform_static_file_information.Number_of_digits_in_byte_count               = 10;       %char               1
            obj.Locations.Waveform_static_file_information.Number_of_bytes_to_the_end_of_file           = 11;       %longint            4
            obj.Locations.Waveform_static_file_information.Number_of_bytes_per_point                    = 15;       %char               1
            obj.Locations.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer     = 16;       %long int           4
            obj.Locations.Waveform_static_file_information.Waveform_label                               = 40;       %char               32
            obj.Locations.Waveform_static_file_information.N_number_of_FastFrames_minus_one             = 72;       %unsigned long      4
            obj.Locations.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes         = 76;       %unsigned short     2
            obj.Info.Waveform_static_file_information.Byte_order_verification                           = obj.ReadUShort(   obj.fid, obj.Locations.Waveform_static_file_information.Byte_order_verification);                           %unsigned short     2
            obj.Info.Waveform_static_file_information.Version_number                                    = obj.ReadChar(     obj.fid, obj.Locations.Waveform_static_file_information.Version_number,7);                                  %char               8
            obj.Info.Waveform_static_file_information.Number_of_digits_in_byte_count                    = obj.ReadChar(     obj.fid, obj.Locations.Waveform_static_file_information.Number_of_digits_in_byte_count,1,'DoNotConvert');   %char               1
            obj.Info.Waveform_static_file_information.Number_of_bytes_to_the_end_of_file                = 15 + obj.ReadLong(obj.fid, obj.Locations.Waveform_static_file_information.Number_of_bytes_to_the_end_of_file);                %longint            4
            obj.Info.Waveform_static_file_information.Number_of_bytes_per_point                         = obj.ReadChar(     obj.fid, obj.Locations.Waveform_static_file_information.Number_of_bytes_per_point,1,'DoNotConvert');        %char               1
            obj.Info.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer          = obj.ReadLong(     obj.fid, obj.Locations.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer);          %long int           4
            obj.Info.Waveform_static_file_information.Waveform_label                                    = obj.ReadChar(     obj.fid, obj.Locations.Waveform_static_file_information.Waveform_label,32);                                 %char               32
            obj.Info.Waveform_static_file_information.N_number_of_FastFrames_minus_one                  = obj.ReadULong(    obj.fid, obj.Locations.Waveform_static_file_information.N_number_of_FastFrames_minus_one);                  %unsigned long      4
            obj.Info.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes              = obj.ReadUShort(   obj.fid, obj.Locations.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes);              %unsigned short     2
            % Reference File Data
            obj.Locations.Waveform_header.Reference_file_data.SetType                                   = 78;       %enum (int)         4
            obj.Locations.Waveform_header.Reference_file_data.WfmCnt                                    = 82;       %unsigned long      4
            obj.Locations.Waveform_header.Reference_file_data.Wfm_update_specification_count            = 110;      %unsigned long      4
            obj.Locations.Waveform_header.Reference_file_data.Imp_dim_ref_count                         = 114;      %unsigned long      4
            obj.Locations.Waveform_header.Reference_file_data.Exp_dim_ref_count                         = 118;      %unsigned long      4
            obj.Locations.Waveform_header.Reference_file_data.Data_type                                 = 122;      %enum (int)         4
            obj.Locations.Waveform_header.Reference_file_data.Curve_ref_count                           = 142;      %unsigned long      4
            obj.Locations.Waveform_header.Reference_file_data.Number_of_requested_fast_frames           = 146;      %unsigned long      4
            obj.Locations.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames             = 150;      %unsigned long      4
            obj.Locations.Waveform_header.Reference_file_data.Summary_frame_type                        = 154;      %unsigned short     2
            obj.Locations.Waveform_header.Reference_file_data.Pix_map_display_format                    = 156;      %enum (int)         4
            obj.Locations.Waveform_header.Reference_file_data.Pix_map_max_value                         = 160;      %unsigned long long 8
            obj.Info.Waveform_header.Reference_file_data.SetType                                        = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.Reference_file_data.SetType);                                %enum (int)         4
            obj.Info.Waveform_header.Reference_file_data.WfmCnt                                         = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Reference_file_data.WfmCnt);                                 %unsigned long      4
            obj.Info.Waveform_header.Reference_file_data.Wfm_update_specification_count                 = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Reference_file_data.Wfm_update_specification_count);         %unsigned long      4
            obj.Info.Waveform_header.Reference_file_data.Imp_dim_ref_count                              = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Reference_file_data.Imp_dim_ref_count);                 %unsigned long      4
            obj.Info.Waveform_header.Reference_file_data.Exp_dim_ref_count                              = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Reference_file_data.Exp_dim_ref_count);                 %unsigned long      4
            obj.Info.Waveform_header.Reference_file_data.Data_type                                      = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.Reference_file_data.Data_type);                              %enum (int)         4
            obj.Info.Waveform_header.Reference_file_data.Curve_ref_count                                = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Reference_file_data.Curve_ref_count);                        %unsigned long      4
            obj.Info.Waveform_header.Reference_file_data.Number_of_requested_fast_frames                = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Reference_file_data.Number_of_requested_fast_frames);            %unsigned long      4
            obj.Info.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames                  = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames);              %unsigned long      4
            obj.Info.Waveform_header.Reference_file_data.Summary_frame_type                             = obj.ReadUShort(   obj.fid, obj.Locations.Waveform_header.Reference_file_data.Summary_frame_type);                     %unsigned short     2
            obj.Info.Waveform_header.Reference_file_data.Pix_map_display_format                         = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.Reference_file_data.Pix_map_display_format);                 %enum (int)         4
            obj.Info.Waveform_header.Reference_file_data.Pix_map_max_value                              = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Reference_file_data.Pix_map_max_value);                      %unsigned long long 8
            switch obj.Info.Waveform_header.Reference_file_data.SetType
                case 0
                    obj.Info.Waveform_header.Reference_file_data.SetType = 'Single Waveform Set';
                case 1
                    obj.Info.Waveform_header.Reference_file_data.SetType = 'FastFrame Set';
                    obj.Info = 'Invalid Import';
                    return
                otherwise
                    obj.Info = 'Invalid Import';
                    return
            end
            switch obj.Info.Waveform_header.Reference_file_data.Data_type
                case 0
                    obj.Info.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_SCALAR_MEAS';
                case 1
                    obj.Info.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_SCALAR_CONST';
                case 2
                    obj.Info.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_VECTOR';
                case 4
                    obj.Info.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_INVALID';
                case 5
                    obj.Info.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_WFMDB';
                case 6
                    obj.Info.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_DIGITAL';
                otherwise
                    obj.Info = 'Invalid Import';
                    return
            end
            switch obj.Info.Waveform_header.Reference_file_data.Pix_map_display_format
                case 0
                    obj.Info.Waveform_header.Reference_file_data.Pix_map_display_format = 'DSY_FORMAT_INVALID';
                case 1
                    obj.Info.Waveform_header.Reference_file_data.Pix_map_display_format = 'DSY_FORMAT_YT';
                case 2
                    obj.Info.Waveform_header.Reference_file_data.Pix_map_display_format = 'DSY_FORMAT_XY';
                case 3
                    obj.Info.Waveform_header.Reference_file_data.Pix_map_display_format = 'DSY_FORMAT_XYZ';
                otherwise
                    obj.Info = 'Invalid Import';
                    return
            end
            % Explicit Dimension 1
            if obj.Info.Waveform_header.Reference_file_data.Exp_dim_ref_count > 0
                obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_scale                            = 168;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_offset                           = 176;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_size                             = 184;      %unsigned long      4
                obj.Locations.Waveform_header.Explicit_Dimension_1.Units                                = 188;      %char               20
                obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_extent_min                       = 208;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_extent_max                       = 216;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_resolution                       = 224;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_ref_point                        = 232;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_1.Format                               = 240;      %enum(int)          4
                obj.Locations.Waveform_header.Explicit_Dimension_1.Storage_type                         = 244;      %enum(int)          4
                obj.Locations.Waveform_header.Explicit_Dimension_1.N_value                              = 248;      %4byte              4
                obj.Locations.Waveform_header.Explicit_Dimension_1.Over_range                           = 252;      %4byte              4
                obj.Locations.Waveform_header.Explicit_Dimension_1.Under_range                          = 256;      %4byte              4
                obj.Locations.Waveform_header.Explicit_Dimension_1.High_range                           = 260;      %4byte              4
                obj.Locations.Waveform_header.Explicit_Dimension_1.Row_range                            = 264;      %4byte              4
                obj.Locations.Waveform_header.Explicit_Dimension_1.User_scale                           = 268;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_1.User_units                           = 276;      %char               20
                obj.Locations.Waveform_header.Explicit_Dimension_1.User_offset                          = 296;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_1.Point_density                        = 304;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_1.HRef_in_percent                      = 312;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_1.TrigDelay_in_seconds                 = 320;      %double             8
                obj.Info.Waveform_header.Explicit_Dimension_1.Dim_scale                                 = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_scale);                                  %double             8
                obj.Info.Waveform_header.Explicit_Dimension_1.Dim_offset                                = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_offset);                                 %double             8
                obj.Info.Waveform_header.Explicit_Dimension_1.Dim_size                                  = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_size);                                   %unsigned long      4
                obj.Info.Waveform_header.Explicit_Dimension_1.Units                                     = obj.ReadChar(     obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Units,20);                                   %char               20
                obj.Info.Waveform_header.Explicit_Dimension_1.Dim_extent_min                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_extent_min);                             %double             8
                obj.Info.Waveform_header.Explicit_Dimension_1.Dim_extent_max                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_extent_max);                             %double             8
                obj.Info.Waveform_header.Explicit_Dimension_1.Dim_resolution                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_resolution);                             %double             8
                obj.Info.Waveform_header.Explicit_Dimension_1.Dim_ref_point                             = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Dim_ref_point);                              %double             8
                obj.Info.Waveform_header.Explicit_Dimension_1.Format                                    = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Format);                                     %enum(int)          4
                obj.Info.Waveform_header.Explicit_Dimension_1.Storage_type                              = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Storage_type);                               %enum(int)          4
                obj.Info.Waveform_header.Explicit_Dimension_1.n_value                                   = 246;      %4byte              4
                obj.Info.Waveform_header.Explicit_Dimension_1.over_range                                = 250;      %4byte              4
                obj.Info.Waveform_header.Explicit_Dimension_1.under_range                               = 254;      %4byte              4
                obj.Info.Waveform_header.Explicit_Dimension_1.high_range                                = 258;      %4byte              4
                obj.Info.Waveform_header.Explicit_Dimension_1.low_range                                 = 262;      %4byte              4
                obj.Info.Waveform_header.Explicit_Dimension_1.User_scale                                = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.User_scale);                                 %double             8
                obj.Info.Waveform_header.Explicit_Dimension_1.User_units                                = obj.ReadChar(     obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.User_units,20);                              %char               20
                obj.Info.Waveform_header.Explicit_Dimension_1.User_offset                               = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.User_offset);                                %double             8
                obj.Info.Waveform_header.Explicit_Dimension_1.Point_density                             = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.Point_density);                              %unsigned long      4
                obj.Info.Waveform_header.Explicit_Dimension_1.HRef_in_percent                           = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.HRef_in_percent);                            %double             8
                obj.Info.Waveform_header.Explicit_Dimension_1.TrigDelay_in_seconds                      = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_1.TrigDelay_in_seconds);                       %double             8
                switch obj.Info.Waveform_header.Explicit_Dimension_1.Format
                    case 0
                        obj.Info.Waveform_header.Explicit_Dimension_1.Format = 'int16';
                    case 1
                        obj.Info.Waveform_header.Explicit_Dimension_1.Format = 'int32';
                    case 2
                        obj.Info.Waveform_header.Explicit_Dimension_1.Format = 'uint32';
                    case 3
                        obj.Info.Waveform_header.Explicit_Dimension_1.Format = 'uint64';
                    case 4
                        obj.Info.Waveform_header.Explicit_Dimension_1.Format = 'float32';
                    case 5
                        obj.Info.Waveform_header.Explicit_Dimension_1.Format = 'float64';
                    case 6
                        obj.Info.Waveform_header.Explicit_Dimension_1.Format = 'uint8';
                    case 7
                        obj.Info.Waveform_header.Explicit_Dimension_1.Format = 'int8';
                    case 8
                        obj.Info.Waveform_header.Explicit_Dimension_1.Format = 'EXP_INVALID_DATA_FORMAT';
                    otherwise
                        obj.Info = 'Invalid Import';
                        return
                end
                switch obj.Info.Waveform_header.Explicit_Dimension_1.Storage_type
                    case 0
                        obj.Info.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_SAMPLE';
                    case 1
                        obj.Info.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_MIN_MAX';
                    case 2
                        obj.Info.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_VERT_HIST';
                    case 3
                        obj.Info.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_HOR_HIST';
                    case 4
                        obj.Info.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_ROW_ORDER';
                    case 5
                        obj.Info.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_COLUMN_ORDER';
                    case 6
                        obj.Info.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_INVALID_STORAGE';
                    otherwise
                        obj.Info = 'Invalid Import';
                        return
                end
            end
            % Explicit Dimension 2
            if obj.Info.Waveform_header.Reference_file_data.Exp_dim_ref_count > 1
                obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_scale                            = 328;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_offset                           = 336;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_size                             = 344;      %unsigned long      4
                obj.Locations.Waveform_header.Explicit_Dimension_2.Units                                = 348;      %char               20
                obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_extent_min                       = 368;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_extent_max                       = 376;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_resolution                       = 384;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_ref_point                        = 392;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_2.Format                               = 400;      %enum(int)          4
                obj.Locations.Waveform_header.Explicit_Dimension_2.Storage_type                         = 404;      %enum(int)          4
                obj.Locations.Waveform_header.Explicit_Dimension_2.N_value                              = 408;      %4byte              4
                obj.Locations.Waveform_header.Explicit_Dimension_2.Over_range                           = 412;      %4byte              4
                obj.Locations.Waveform_header.Explicit_Dimension_2.Under_range                          = 416;      %4byte              4
                obj.Locations.Waveform_header.Explicit_Dimension_2.High_range                           = 420;      %4byte              4
                obj.Locations.Waveform_header.Explicit_Dimension_2.Low_range                            = 424;      %4byte              4
                obj.Locations.Waveform_header.Explicit_Dimension_2.User_scale                           = 428;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_2.User_units                           = 436;      %char               20
                obj.Locations.Waveform_header.Explicit_Dimension_2.User_offset                          = 456;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_2.Point_density                        = 464;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_2.HRef_in_percent                      = 472;      %double             8
                obj.Locations.Waveform_header.Explicit_Dimension_2.TrigDelay_in_seconds                 = 480;      %double             8
                obj.Info.Waveform_header.Explicit_Dimension_2.Dim_scale                                 = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_scale);                                  %double             8
                obj.Info.Waveform_header.Explicit_Dimension_2.Dim_offset                                = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_offset);                                 %double             8
                obj.Info.Waveform_header.Explicit_Dimension_2.Dim_size                                  = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_size);                                   %unsigned long      4
                obj.Info.Waveform_header.Explicit_Dimension_2.Units                                     = obj.ReadChar(     obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Units,20);                                   %char               20
                obj.Info.Waveform_header.Explicit_Dimension_2.Dim_extent_min                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_extent_min);                             %double             8
                obj.Info.Waveform_header.Explicit_Dimension_2.Dim_extent_max                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_extent_max);                             %double             8
                obj.Info.Waveform_header.Explicit_Dimension_2.Dim_resolution                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_resolution);                             %double             8
                obj.Info.Waveform_header.Explicit_Dimension_2.Dim_ref_point                             = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Dim_ref_point);                              %double             8
                obj.Info.Waveform_header.Explicit_Dimension_2.Format                                    = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Format);                                     %enum(int)          4
                obj.Info.Waveform_header.Explicit_Dimension_2.Storage_type                              = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Storage_type);                               %enum(int)          4
                obj.Info.Waveform_header.Explicit_Dimension_2.n_value                                   = 402;      %4byte              4
                obj.Info.Waveform_header.Explicit_Dimension_2.over_range                                = 406;      %4byte              4
                obj.Info.Waveform_header.Explicit_Dimension_2.under_range                               = 410;      %4byte              4
                obj.Info.Waveform_header.Explicit_Dimension_2.high_range                                = 414;      %4byte              4
                obj.Info.Waveform_header.Explicit_Dimension_2.low_range                                 = 418;      %4byte              4
                obj.Info.Waveform_header.Explicit_Dimension_2.User_scale                                = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.User_scale);                                 %double             8
                obj.Info.Waveform_header.Explicit_Dimension_2.User_units                                = obj.ReadChar(     obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.User_units,20);                              %char               20
                obj.Info.Waveform_header.Explicit_Dimension_2.User_offset                               = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.User_offset);                                %double             8
                obj.Info.Waveform_header.Explicit_Dimension_2.Point_density                             = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.Point_density);                              %unsigned long      4
                obj.Info.Waveform_header.Explicit_Dimension_2.HRef_in_percent                           = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.HRef_in_percent);                            %double             8
                obj.Info.Waveform_header.Explicit_Dimension_2.TrigDelay_in_seconds                      = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Explicit_Dimension_2.TrigDelay_in_seconds);                       %double             8
                switch obj.Info.Waveform_header.Explicit_Dimension_2.Format
                    case 0
                        obj.Info.Waveform_header.Explicit_Dimension_2.Format = 'int16';
                    case 1
                        obj.Info.Waveform_header.Explicit_Dimension_2.Format = 'int32';
                    case 2
                        obj.Info.Waveform_header.Explicit_Dimension_2.Format = 'uint32';
                    case 3
                        obj.Info.Waveform_header.Explicit_Dimension_2.Format = 'uint64';
                    case 4
                        obj.Info.Waveform_header.Explicit_Dimension_2.Format = 'float32';
                    case 5
                        obj.Info.Waveform_header.Explicit_Dimension_2.Format = 'float64';
                    case 6
                        obj.Info.Waveform_header.Explicit_Dimension_2.Format = 'uint8';
                    case 7
                        obj.Info.Waveform_header.Explicit_Dimension_2.Format = 'int8';
                    case 8
                        obj.Info.Waveform_header.Explicit_Dimension_2.Format = 'EXP_INVALID_DATA_FORMAT';
                    case 9
                        obj.Info.Waveform_header.Explicit_Dimension_2.Format = 'DIMENSION NOT IN USE';
                    otherwise
                        obj.Info = 'Invalid Import';
                        return
                end
                switch obj.Info.Waveform_header.Explicit_Dimension_2.Storage_type
                    case 0
                        obj.Info.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_SAMPLE';
                    case 1
                        obj.Info.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_MIN_MAX';
                    case 2
                        obj.Info.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_VERT_HIST';
                    case 3
                        obj.Info.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_HOR_HIST';
                    case 4
                        obj.Info.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_ROW_ORDER';
                    case 5
                        obj.Info.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_COLUMN_ORDER';
                    case 6
                        obj.Info.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_INVALID_STORAGE';
                    otherwise
                        obj.Info = 'Invalid Import';
                        return
                end
            end
            % Implicit Dimension 1
            if obj.Info.Waveform_header.Reference_file_data.Imp_dim_ref_count > 0
                obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_scale                            = 488;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_offset                           = 496;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_size                             = 504;      %unsigned long      4
                obj.Locations.Waveform_header.Implicit_Dimension_1.Units                                = 508;      %char               20
                obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_extent_min                       = 528;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_extent_max                       = 536;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_resolution                       = 544;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_ref_point                        = 552;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_1.Spacing                              = 560;      %enum(int)          4
                obj.Locations.Waveform_header.Implicit_Dimension_1.User_scale                           = 564;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_1.User_units                           = 572;      %char               20
                obj.Locations.Waveform_header.Implicit_Dimension_1.User_offset                          = 592;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_1.Point_density                        = 600;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_1.HRef_in_percent                      = 608;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_1.TrigDelay_in_seconds                 = 616;      %double             8
                obj.Info.Waveform_header.Implicit_Dimension_1.Dim_scale                                 = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_scale);                                  %double             8
                obj.Info.Waveform_header.Implicit_Dimension_1.Dim_offset                                = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_offset);                                 %double             8
                obj.Info.Waveform_header.Implicit_Dimension_1.Dim_size                                  = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_size);                                   %unsigned long      4
                obj.Info.Waveform_header.Implicit_Dimension_1.Units                                     = obj.ReadChar(     obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.Units,20);                                   %char               20
                obj.Info.Waveform_header.Implicit_Dimension_1.Dim_extent_min                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_extent_min);                             %double             8
                obj.Info.Waveform_header.Implicit_Dimension_1.Dim_extent_max                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_extent_max);                             %double             8
                obj.Info.Waveform_header.Implicit_Dimension_1.Dim_resolution                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_resolution);                             %double             8
                obj.Info.Waveform_header.Implicit_Dimension_1.Dim_ref_point                             = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.Dim_ref_point);                              %double             8
                obj.Info.Waveform_header.Implicit_Dimension_1.Spacing                                   = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.Spacing);                                    %enum(int)          4
                obj.Info.Waveform_header.Implicit_Dimension_1.User_scale                                = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.User_scale);                                 %double             8
                obj.Info.Waveform_header.Implicit_Dimension_1.User_units                                = obj.ReadChar(     obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.User_units,20);                              %char               20
                obj.Info.Waveform_header.Implicit_Dimension_1.User_offset                               = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.User_offset);                                %double             8
                obj.Info.Waveform_header.Implicit_Dimension_1.Point_density                             = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.Point_density);                              %unsigned long      4
                obj.Info.Waveform_header.Implicit_Dimension_1.HRef_in_percent                           = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.HRef_in_percent);                            %double             8
                obj.Info.Waveform_header.Implicit_Dimension_1.TrigDelay_in_seconds                      = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_1.TrigDelay_in_seconds);                       %double             8
            end
            % Implicit Dimension 2
            if obj.Info.Waveform_header.Reference_file_data.Imp_dim_ref_count > 1
                obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_scale                            = 624;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_offset                           = 632;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_size                             = 640;      %unsigned long      4
                obj.Locations.Waveform_header.Implicit_Dimension_2.Units                                = 644;      %char               20
                obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_extent_min                       = 664;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_extent_max                       = 672;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_resolution                       = 680;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_ref_point                        = 688;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_2.Spacing                              = 696;      %enum(int)          4
                obj.Locations.Waveform_header.Implicit_Dimension_2.User_scale                           = 700;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_2.User_units                           = 708;      %char               20
                obj.Locations.Waveform_header.Implicit_Dimension_2.User_offset                          = 728;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_2.Point_density                        = 736;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_2.HRef_in_percent                      = 744;      %double             8
                obj.Locations.Waveform_header.Implicit_Dimension_2.TrigDelay_in_seconds                 = 752;      %double             8
                obj.Info.Waveform_header.Implicit_Dimension_2.Dim_scale                                 = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_scale);                                  %double             8
                obj.Info.Waveform_header.Implicit_Dimension_2.Dim_offset                                = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_offset);                                 %double             8
                obj.Info.Waveform_header.Implicit_Dimension_2.Dim_size                                  = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_size);                                   %unsigned long      4
                obj.Info.Waveform_header.Implicit_Dimension_2.Units                                     = obj.ReadChar(     obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.Units,20);                                   %char               20
                obj.Info.Waveform_header.Implicit_Dimension_2.Dim_extent_min                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_extent_min);                             %double             8
                obj.Info.Waveform_header.Implicit_Dimension_2.Dim_extent_max                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_extent_max);                             %double             8
                obj.Info.Waveform_header.Implicit_Dimension_2.Dim_resolution                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_resolution);                             %double             8
                obj.Info.Waveform_header.Implicit_Dimension_2.Dim_ref_point                             = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.Dim_ref_point);                              %double             8
                obj.Info.Waveform_header.Implicit_Dimension_2.Spacing                                   = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.Spacing);                                    %enum(int)          4
                obj.Info.Waveform_header.Implicit_Dimension_2.User_scale                                = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.User_scale);                                 %double             8
                obj.Info.Waveform_header.Implicit_Dimension_2.User_units                                = obj.ReadChar(     obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.User_units,20);                              %char               20
                obj.Info.Waveform_header.Implicit_Dimension_2.User_offset                               = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.User_offset);                                %double             8
                obj.Info.Waveform_header.Implicit_Dimension_2.Point_density                             = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.HRef_in_percent);                            %double             8
                obj.Info.Waveform_header.Implicit_Dimension_2.TrigDelay_in_seconds                      = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.Implicit_Dimension_2.TrigDelay_in_seconds);                       %double             8
            end
            % TimeBase Info 1
            if obj.Info.Waveform_header.Reference_file_data.Curve_ref_count > 0
                obj.Locations.Waveform_header.TimeBase_Info1.Real_point_spacing                         = 760;      %unsigned long      4
                obj.Locations.Waveform_header.TimeBase_Info1.Sweep                                      = 764;      %enum(int)          4
                obj.Locations.Waveform_header.TimeBase_Info1.Type_of_base                               = 768;      %enum(int)          4
                obj.Info.Waveform_header.TimeBase_Info1.Real_point_spacing                              = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.TimeBase_Info1.Real_point_spacing);                                %unsigned long      4
                obj.Info.Waveform_header.TimeBase_Info1.Sweep                                           = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.TimeBase_Info1.Sweep);                                             %enum(int)          4
                obj.Info.Waveform_header.TimeBase_Info1.Type_of_base                                    = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.TimeBase_Info1.Type_of_base);                                      %enum(int)          4
                switch obj.Info.Waveform_header.TimeBase_Info1.Sweep 
                    case 0
                        obj.Info.Waveform_header.TimeBase_Info1.Sweep = 'SWEEP_ROLL';
                    case 1
                        obj.Info.Waveform_header.TimeBase_Info1.Sweep = 'SWEEP_SAMPLE';
                    case 2
                        obj.Info.Waveform_header.TimeBase_Info1.Sweep = 'SWEEP_ET';
                    case 3
                        obj.Info.Waveform_header.TimeBase_Info1.Sweep = 'SWEEP_INVALID';
                    otherwise
                        obj.Info = 'Invalid Import';
                        return
                end
                switch obj.Info.Waveform_header.TimeBase_Info1.Type_of_base
                    case 0
                        obj.Info.Waveform_header.TimeBase_Info1.Type_of_base = 'BASE_TIME';
                    case 1
                        obj.Info.Waveform_header.TimeBase_Info1.Type_of_base = 'BASE_SPECTRAL_MAG';
                    case 2
                        obj.Info.Waveform_header.TimeBase_Info1.Type_of_base = 'BASE_SPRECTRAL_PHASE';
                    case 3
                        obj.Info.Waveform_header.TimeBase_Info1.Type_of_base = 'BASE_INVALID';
                    otherwise
                        obj.Info = 'Invalid Import';
                        return
                end
            end
            % TimeBase Info 2
            if obj.Info.Waveform_header.Reference_file_data.Curve_ref_count > 1
                obj.Locations.Waveform_header.TimeBase_Info2.Real_point_spacing                         = 772;      %unsigned long      4
                obj.Locations.Waveform_header.TimeBase_Info2.Sweep                                      = 776;      %enum(int)          4
                obj.Locations.Waveform_header.TimeBase_Info2.Type_of_base                               = 780;      %enum(int)          4
                obj.Info.Waveform_header.TimeBase_Info2.Real_point_spacing                              = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.TimeBase_Info2.Real_point_spacing);                                %unsigned long      4
                obj.Info.Waveform_header.TimeBase_Info2.Sweep                                           = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.TimeBase_Info2.Sweep);                                             %enum(int)          4
                obj.Info.Waveform_header.TimeBase_Info2.Type_of_base                                    = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.TimeBase_Info2.Type_of_base);                                      %enum(int)          4
                switch obj.Info.Waveform_header.TimeBase_Info2.Sweep 
                    case 0
                        obj.Info.Waveform_header.TimeBase_Info2.Sweep = 'SWEEP_ROLL';
                    case 1
                        obj.Info.Waveform_header.TimeBase_Info2.Sweep = 'SWEEP_SAMPLE';
                    case 2
                        obj.Info.Waveform_header.TimeBase_Info2.Sweep = 'SWEEP_ET';
                    case 3
                        obj.Info.Waveform_header.TimeBase_Info2.Sweep = 'SWEEP_INVALID';
                    otherwise
                        obj.Info = 'Invalid Import';
                        return
                end
                switch obj.Info.Waveform_header.TimeBase_Info2.Type_of_base
                    case 0
                        obj.Info.Waveform_header.TimeBase_Info2.Type_of_base = 'BASE_TIME';
                    case 1
                        obj.Info.Waveform_header.TimeBase_Info2.Type_of_base = 'BASE_SPECTRAL_MAG';
                    case 2
                        obj.Info.Waveform_header.TimeBase_Info2.Type_of_base = 'BASE_SPRECTRAL_PHASE';
                    case 3
                        obj.Info.Waveform_header.TimeBase_Info2.Type_of_base = 'BASE_INVALID';
                    otherwise
                        obj.Info = 'Invalid Import';
                        return
                end
            end
            % Wfm Update Spec
            obj.Locations.Waveform_header.WfmUpdateSpec.Real_point_offset                               = 784;      %unsigned long      4
            obj.Locations.Waveform_header.WfmUpdateSpec.TT_offset                                       = 788;      %double             8
            obj.Locations.Waveform_header.WfmUpdateSpec.Frac_sec                                        = 796;      %double             8
            obj.Locations.Waveform_header.WfmUpdateSpec.Gmt_sec                                         = 804;      %long               4
            obj.Info.Waveform_header.WfmUpdateSpec.Real_point_offset                                    = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.WfmUpdateSpec.Real_point_offset);                                %unsigned long      4
            obj.Info.Waveform_header.WfmUpdateSpec.TT_offset                                            = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.WfmUpdateSpec.TT_offset);                                         %double             8
            obj.Info.Waveform_header.WfmUpdateSpec.Frac_sec                                             = obj.ReadDouble(   obj.fid, obj.Locations.Waveform_header.WfmUpdateSpec.Frac_sec);                                          %double             8
            obj.Info.Waveform_header.WfmUpdateSpec.Gmt_sec                                              = obj.ReadLong(     obj.fid, obj.Locations.Waveform_header.WfmUpdateSpec.Gmt_sec);                                           %long               4
            % Wfm Curve Object
            obj.Locations.Waveform_header.WfmCurveObject.State_flags                                    = 808;      %unsigned long      4
            obj.Locations.Waveform_header.WfmCurveObject.Type_of_check_sum                              = 812;      %enum(int)          4
            obj.Locations.Waveform_header.WfmCurveObject.Check_sum                                      = 816;      %short              2
            obj.Locations.Waveform_header.WfmCurveObject.Precharge_start_offset                         = 818;      %unsigned long      4
            obj.Locations.Waveform_header.WfmCurveObject.Data_start_offset                              = 822;      %unsigned long      4
            obj.Locations.Waveform_header.WfmCurveObject.Postcharge_start_offset                        = 826;      %unsigned long      4
            obj.Locations.Waveform_header.WfmCurveObject.Postcharge_stop_offset                         = 830;      %unsigned long      4
            obj.Locations.Waveform_header.WfmCurveObject.End_of_curve_buffer                            = 834;      %unsigned long      4
            obj.Info.Waveform_header.WfmCurveObject.State_flags                                         = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.WfmCurveObject.State_flags);                                       %unsigned long      4
            obj.Info.Waveform_header.WfmCurveObject.Type_of_check_sum                                   = obj.ReadEnumTek(  obj.fid, obj.Locations.Waveform_header.WfmCurveObject.Type_of_check_sum);                                 %enum(int)          4
            obj.Info.Waveform_header.WfmCurveObject.Check_sum                                           = obj.ReadShort(    obj.fid, obj.Locations.Waveform_header.WfmCurveObject.Check_sum);                                         %short              2
            obj.Info.Waveform_header.WfmCurveObject.Precharge_start_offset                              = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.WfmCurveObject.Precharge_start_offset);                            %unsigned long      4
            obj.Info.Waveform_header.WfmCurveObject.Data_start_offset                                   = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.WfmCurveObject.Data_start_offset);                                 %unsigned long      4
            obj.Info.Waveform_header.WfmCurveObject.Postcharge_start_offset                             = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.WfmCurveObject.Postcharge_start_offset);                           %unsigned long      4
            obj.Info.Waveform_header.WfmCurveObject.Postcharge_stop_offset                              = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.WfmCurveObject.Postcharge_stop_offset);                            %unsigned long      4
            obj.Info.Waveform_header.WfmCurveObject.End_of_curve_buffer                                 = obj.ReadULong(    obj.fid, obj.Locations.Waveform_header.WfmCurveObject.End_of_curve_buffer);                               %unsigned long      4
            switch obj.Info.Waveform_header.WfmCurveObject.Type_of_check_sum
                case 0
                    obj.Info.Waveform_header.WfmCurveObject.Type_of_check_sum = 'NO_CHECKSUM';
                case 1
                    obj.Info.Waveform_header.WfmCurveObject.Type_of_check_sum = 'CTYPE_CRC16';
                case 2
                    obj.Info.Waveform_header.WfmCurveObject.Type_of_check_sum = 'CTYPE_SUM16';
                case 3
                    obj.Info.Waveform_header.WfmCurveObject.Type_of_check_sum = 'CTYPE_CRC32';
                case 4
                    obj.Info.Waveform_header.WfmCurveObject.Type_of_check_sum = 'CTYPE_SUM32';
                otherwise
                    obj.Info = 'Invalid Import';
                    return
            end
            % FastFrame Frames
            N = obj.Info.Waveform_static_file_information.N_number_of_FastFrames_minus_one;
            obj.Locations.fast_frame_frames.N_WfmUpdateSpec_object = 838;
            obj.Locations.fast_frame_frames.N_WfmCurveSpec_objects = 838 + (N*24);
            %CurveBuffer
            obj.Locations.CurveBuffer.Curve_buffer                 = 838 + (N*54);
            %%Checksum
            obj.Locations.CurveBufferWfmFileChecksum.Waveform_file_checksum   = obj.Info.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer+obj.Info.Waveform_header.WfmCurveObject.End_of_curve_buffer; % Needs correcting as this assumes no user marks.
            frewind(obj.fid)
            obj.Info.WfmFileChecksum.Waveform_file_checksum_calculated  = sum(fread(obj.fid,obj.Locations.CurveBufferWfmFileChecksum.Waveform_file_checksum,'uchar'));
            obj.Info.WfmFileChecksum.Waveform_file_checksum             = obj.ReadULongLong(obj.fid,obj.Locations.CurveBufferWfmFileChecksum.Waveform_file_checksum);
            
            % Checks on waveform
            FastFramesPresentCheck1 = obj.Info.Waveform_static_file_information.N_number_of_FastFrames_minus_one ~= 0;
            FastFramesPresentCheck2 = obj.Locations.fast_frame_frames.N_WfmUpdateSpec_object ~= obj.Locations.CurveBuffer.Curve_buffer;
            FastFramesPresentCheck3 = obj.Locations.fast_frame_frames.N_WfmCurveSpec_objects ~= obj.Locations.CurveBuffer.Curve_buffer;
            FastFramesPresent       = FastFramesPresentCheck1 || FastFramesPresentCheck2 || FastFramesPresentCheck3;
            NotValidVersion         = ~strcmp(obj.Info.Waveform_static_file_information.Version_number,'WFM#003');
            MoreThanOneCurve        = obj.Info.Waveform_header.Reference_file_data.Curve_ref_count ~= 1;
            CurveBeginsWrongPlace   = obj.Info.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer ~= obj.Locations.CurveBuffer.Curve_buffer;
            CurveTheWrongSize       = obj.Info.Waveform_header.Implicit_Dimension_1.Dim_size ~= obj.Info.Waveform_header.WfmCurveObject.End_of_curve_buffer / obj.Info.Waveform_static_file_information.Number_of_bytes_per_point;
            ChecksumIssue           = obj.Info.WfmFileChecksum.Waveform_file_checksum_calculated ~= obj.Info.WfmFileChecksum.Waveform_file_checksum;
            if FastFramesPresent || NotValidVersion || MoreThanOneCurve || CurveBeginsWrongPlace || CurveTheWrongSize || ChecksumIssue
                obj.Info = 'Invalid Import';
                return
            end
            
            blank_line_count = 0;
            while ~feof(obj.fid)
                blank_line_count = blank_line_count+1;
                fread(obj.fid,1,'int8');
            end
            
            if blank_line_count == 1
                %disp('Single Blank byte at end of file, as expected')
            else
                disp('More blank lines than expected, below is the number recorded')
                disp(blank_line_count)
            end
            clearvars blank_line_count
            
            
            obj.RawInfo                            = obj.Info;
            obj.Info.horizontal_resolution         = obj.Info.Waveform_header.Implicit_Dimension_1.Dim_scale;
            obj.Info.vertical_resolution           = obj.Info.Waveform_header.Explicit_Dimension_1.Dim_scale;
            obj.Info.horizontal_unit               = deblank(obj.Info.Waveform_header.Implicit_Dimension_1.Units);
            obj.Info.vertical_unit                 = deblank(obj.Info.Waveform_header.Explicit_Dimension_1.Units);
            obj.Info.no_of_points                  = obj.Info.Waveform_header.Implicit_Dimension_1.Dim_size;
            obj.Info.time_of_aquisition            = datetime(obj.Info.Waveform_header.WfmUpdateSpec.Gmt_sec,'ConvertFrom','posixtime'); %Reckon scope clock wrong
            obj.Info.version_number                = obj.Info.Waveform_static_file_information.Version_number;
            obj.Info.no_of_bytes_per_data_point    = obj.Info.Waveform_static_file_information.Number_of_bytes_per_point;
            obj.Info.waveform_label                = obj.Info.Waveform_static_file_information.Waveform_label;
            
            obj.Info = rmfield(obj.Info,'Waveform_header');
            obj.Info = rmfield(obj.Info,'WfmFileChecksum');
            obj.Info = rmfield(obj.Info,'Waveform_static_file_information');
            
            obj.ValidImport = true;
        end
        function Time               = GetTektronixWfmTime(obj)
            switch obj.RawInfo.Waveform_static_file_information.Byte_order_verification
                case 61680 %equivalent to hexidecimal 0xF0F0, which is big endian
                    obj.fid = fopen(obj.FilePath,'r','ieee-be'); %reopening file with big endian format
                case 3855 %equivalent to hexidecimal 0x0F0F, which is little endian
                    obj.fid = fopen(obj.FilePath,'r','ieee-le'); %reopening file with little endian format
                otherwise
                    Time = 'Invalid Import';
                    return
            end
            Time       = (((1:obj.RawInfo.Waveform_header.Implicit_Dimension_1.Dim_size) * obj.RawInfo.Waveform_header.Implicit_Dimension_1.Dim_scale) + obj.RawInfo.Waveform_header.Implicit_Dimension_1.Dim_offset)';
            fclose(obj.fid);
        end
        function [Time,Error]       = GetTektronixWfmTimeSingle(obj)
            Time  = single(GetTektronixWfmTime(obj));
            Error = double(eps(Time(end))) / obj.Info.horizontal_resolution;
        end
        function Voltage            = GetTektronixWfmVoltage(obj)
            
            switch obj.RawInfo.Waveform_static_file_information.Byte_order_verification
                case 61680 %equivalent to hexidecimal 0xF0F0, which is big endian
                    obj.fid = fopen(obj.FilePath,'r','ieee-be'); %reopening file with big endian format
                case 3855 %equivalent to hexidecimal 0x0F0F, which is little endian
                    obj.fid = fopen(obj.FilePath,'r','ieee-le'); %reopening file with little endian format
                otherwise
                    Voltage = 'Invalid Import';
                    return
            end
            
            Voltage = obj.ReadDefinedFormat(obj.fid, ...
                                            obj.RawInfo.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer, ...
                                            obj.RawInfo.Waveform_header.Implicit_Dimension_1.Dim_size, ...
                                            obj.RawInfo.Waveform_header.Explicit_Dimension_1.Format);
            
            Voltage    = (Voltage * obj.RawInfo.Waveform_header.Explicit_Dimension_1.Dim_scale)+obj.RawInfo.Waveform_header.Explicit_Dimension_1.Dim_offset;
            
            fclose(obj.fid);
        end
        function [Voltage,Error]    = GetTektronixWfmVoltageSingle(obj)
            Voltage = single(GetTektronixWfmVoltage(obj));
            Error = double(eps(max(abs(Voltage)))) / obj.Info.vertical_resolution;
        end
        % Tektronix .isf Methods
        function obj                = GetTektronixIsfInfo(obj)
            % Locations found by Liam on 4054 isf file, could vary scope to scope as no specific format for tek scopes.
            IsfHeader = char(fread(obj.fid,1000,'uchar')');
            obj.Locations.byte_order = obj.FindIsfLocation(IsfHeader,'BYT_O');
            obj.Info.byte_order      = obj.GetIsfInformation(IsfHeader,obj.Locations.byte_order);
            
            fclose(obj.fid);
            switch obj.Info.byte_order
                case 'MSB' % if most significant byte first then big-endian
                    fopen(obj.FilePath,'r','ieee-be');
                case 'LSB' % if least significant bye first then little-endian
                    fopen(obj.FilePath,'r','ieee-le');
                otherwise
                    obj.Info      = [];
                    return
            end
            
            obj.Locations.no_of_points              = obj.FindIsfLocation(IsfHeader,'NR_P');
            obj.Locations.bytes_per_point           = obj.FindIsfLocation(IsfHeader,'BYT_N');
            obj.Locations.bits_per_point            = obj.FindIsfLocation(IsfHeader,'BIT_N');
            obj.Locations.encoding                  = obj.FindIsfLocation(IsfHeader,'ENC');
            obj.Locations.binary_format             = obj.FindIsfLocation(IsfHeader,'BN_F');
            obj.Locations.byte_order                = obj.FindIsfLocation(IsfHeader,'BYT_O');
            obj.Locations.waveform_identifier       = obj.FindIsfLocation(IsfHeader,'WFI');
            obj.Locations.point_format              = obj.FindIsfLocation(IsfHeader,'PT_F');
            obj.Locations.horizontal_unit           = obj.FindIsfLocation(IsfHeader,'XUN');
            obj.Locations.horizontal_interval       = obj.FindIsfLocation(IsfHeader,'XIN');
            obj.Locations.horizontal_zero           = obj.FindIsfLocation(IsfHeader,'XZE');
            obj.Locations.trigger_point_offset      = obj.FindIsfLocation(IsfHeader,'PT_O');
            obj.Locations.vertical_unit             = obj.FindIsfLocation(IsfHeader,'YUN');
            obj.Locations.vertical_scale_factor     = obj.FindIsfLocation(IsfHeader,'YMU');
            obj.Locations.vertical_offset           = obj.FindIsfLocation(IsfHeader,'YOF');
            obj.Locations.vertical_zero             = obj.FindIsfLocation(IsfHeader,'YZE');
            obj.Locations.vertical_scale            = obj.FindIsfLocation(IsfHeader,'VSCALE');
            obj.Locations.horizontal_scale          = obj.FindIsfLocation(IsfHeader,'HSCALE');
            obj.Locations.vertical_position_unknown = obj.FindIsfLocation(IsfHeader,'VPOS');
            obj.Locations.vertical_offset_unknown   = obj.FindIsfLocation(IsfHeader,'VOFFSET');
            obj.Locations.horizontal_delay_unknown  = obj.FindIsfLocation(IsfHeader,'HDELAY');
            
            obj.Info.no_of_points                   = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.no_of_points));
            obj.Info.bytes_per_point                = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.bytes_per_point));
            obj.Info.bits_per_point                 = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.bits_per_point));
            obj.Info.encoding                       = obj.GetIsfInformation(IsfHeader,obj.Locations.encoding);
            obj.Info.binary_format                  = obj.GetIsfInformation(IsfHeader,obj.Locations.binary_format);
            obj.Info.byte_order                     = obj.GetIsfInformation(IsfHeader,obj.Locations.byte_order);
            obj.Info.waveform_identifier            = obj.GetIsfInformation(IsfHeader,obj.Locations.waveform_identifier);
            obj.Info.point_format                   = obj.GetIsfInformation(IsfHeader,obj.Locations.point_format);
            obj.Info.horizontal_unit                = obj.GetIsfInformation(IsfHeader,obj.Locations.horizontal_unit);
            obj.Info.horizontal_interval            = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.horizontal_interval));
            obj.Info.horizontal_zero                = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.horizontal_zero));
            obj.Info.trigger_point_offset           = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.trigger_point_offset));
            obj.Info.vertical_unit                  = obj.GetIsfInformation(IsfHeader,obj.Locations.vertical_unit);
            obj.Info.vertical_scale_factor          = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.vertical_scale_factor));
            obj.Info.vertical_offset                = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.vertical_offset));
            obj.Info.vertical_zero                  = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.vertical_zero));
            obj.Info.vertical_scale                 = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.vertical_scale));
            obj.Info.horizontal_scale               = str2double(obj.GetIsfInformation(IsfHeader,obj.Locations.horizontal_scale));
            obj.Info.vertical_position_unknown      = obj.GetIsfInformation(IsfHeader,obj.Locations.vertical_offset_unknown);
            obj.Info.horizontal_delay_unknown       = obj.GetIsfInformation(IsfHeader,obj.Locations.horizontal_delay_unknown);
            
            obj.Info.waveform_identifier            = regexprep(obj.Info.waveform_identifier,'"','');
            obj.Info.horizontal_unit                = regexprep(obj.Info.horizontal_unit,'"','');
            obj.Info.vertical_unit                  = regexprep(obj.Info.vertical_unit,'"','');
            
            obj.ValidImport = true;
        end
        function Time               = GetTektronixIsfTime(obj)
            Time = obj.Info.horizontal_interval * ((1:obj.Info.no_of_points)' - obj.Info.trigger_point_offset);
        end
        function [Time,Error]       = GetTektronixIsfTimeSingle(obj)
            Time  = single(GetTektronixIsfTime(obj));
            Error = double(eps(Time(end))) / obj.Info.horizontal_interval;
        end
        function Voltage            = GetTektronixIsfVoltage(obj)
            
            obj.fid = fopen(obj.FilePath,'r');
            IsfHeader = char(fread(obj.fid,1000,'uchar')');
            fclose(obj.fid);
            
            switch obj.Info.byte_order
                case 'MSB' % if most significant byte first then big-endian
                    fopen(obj.FilePath,'r','ieee-be');
                case 'LSB' % if least significant byte first then little-endian
                    fopen(obj.FilePath,'r','ieee-le');
                otherwise
                    Voltage = 'Error Reading Voltage';
                    return
            end
            
            fseek(obj.fid,regexp(IsfHeader,'#','once'),'bof');
            NoOfPoints = str2double(fread(obj.fid,1,'*char'));
            NoOfPoints = str2double(fread(obj.fid,NoOfPoints,'*char')');
            
            InCorrectNumberOfPoints = obj.Info.no_of_points * obj.Info.bytes_per_point ~= NoOfPoints;
            InCorrectByteEncodings  = obj.Info.bits_per_point/8 ~= obj.Info.bytes_per_point;
            if  InCorrectNumberOfPoints || InCorrectByteEncodings
                Voltage = 'Error Reading Voltage';
                fclose(obj.fid);
                return
            end
            
            switch obj.Info.bytes_per_point
                case 1
                    Voltage = fread(obj.fid,obj.Info.no_of_points,'int8');
                case 2
                    Voltage = fread(obj.fid,obj.Info.no_of_points,'int16');
                otherwise
                    Voltage = 'Error Reading Voltage';
                    fclose(obj.fid);
                    return
            end
            Voltage = obj.Info.vertical_zero + obj.Info.vertical_scale_factor * (Voltage - obj.Info.vertical_offset);
            
            fread(obj.fid,1); %sometimes need to read off the end of file for some reason
            if ~feof(obj.fid) %checking to ensure we are at the end of the file (we should be)
                Voltage = 'Error Reading Voltage';
                fclose(obj.fid);
                return
            end
            
            fclose(obj.fid);
        end
        function [Voltage,Error]    = GetTektronixIsfVoltageSingle(obj)
            Voltage = single(GetTektronixIsfVoltage(obj));
            Error = double(eps(max(abs(Voltage)))) / obj.Info.vertical_scale_factor;
        end
        % Tektronix .dat Methods
        function obj                = GetTektronixDatInfo(obj)
            
            HdrFilePath = strrep(obj.FilePath,'.','_hdr.');
            if ~isfile(HdrFilePath)
                obj.Info = 'Invalid Import';
                return
            end
            obj.HeaderFilePath = HdrFilePath;
            
            
            Header = fopen(obj.HeaderFilePath);
            HeaderInfo = fscanf(Header,'%f');
            fclose(Header);
            
            obj.Info.NumberOfPoints         = HeaderInfo(1);
            obj.Info.HorizontalInterval     = HeaderInfo(2);
            obj.Info.TriggerPositionIdx     = HeaderInfo(3);
            obj.Info.FractionalTriggerPos   = HeaderInfo(4);
            obj.Info.StartTime              = HeaderInfo(5);
            
            obj.Info.EndTime = obj.Info.StartTime + obj.Info.HorizontalInterval * (obj.Info.NumberOfPoints - 1);
            
            obj.ValidImport = true;
        end
        function Time               = GetTektronixDatTime(obj)
            Time = linspace(obj.Info.StartTime, ...
                            obj.Info.EndTime, ...
                            obj.Info.NumberOfPoints)';
        end
        function [Time,Error]       = GetTektronixDatTimeSingle(obj)
            Time  = single(GetTektronixDatTime(obj));
            Error = double(eps(Time(end))) / obj.Info.HorizontalInterval;
        end
        function Voltage            = GetTektronixDatVoltage(obj)
            
            CompressedFilePath = [obj.FilePath(1:end-4),'CompressedVoltage'];
            
            if ~isfile(CompressedFilePath)
                obj.fid = fopen(obj.FilePath);
                Voltage = fscanf(obj.fid,'%f');
                fclose(obj.fid);
                obj.WriteCompressedWaveform(CompressedFilePath,Voltage)
            else
                Voltage = obj.ReadCompressedWaveform(CompressedFilePath, ...
                                                 obj.Info.NumberOfPoints);
            end
        end
        function [Voltage,Error]    = GetTektronixDatVoltageSingle(obj)
            Voltage = single(GetTektronixDatVoltage(obj));
            Error = double(eps(max(abs(Voltage)))) / min(abs(diff(unique(Voltage))));
        end
    end
    
    methods(Static)
        % Trace Type
        function TraceType  = DecipherDatType(FilePath)
            
            HeaderFilePath = strrep(FilePath,'.','_hdr.');
            HeaderExists = isfile(HeaderFilePath);
            
            fid = fopen(FilePath,'r');
            FirstLine = fgetl(fid);
            fclose(fid);
            
            if contains(FirstLine,' ')
                StringsPerLine = 2;
            else
                StringsPerLine = 1;
            end
            
            if HeaderExists && StringsPerLine == 1
                TraceType = 'Tektronix (.dat)';
            elseif ~HeaderExists && StringsPerLine ==2
                TraceType = 'LeCroy (.dat)';
            else
                TraceType = 'Unsupported Trace Type';
            end
        end
        % Isf Methods
        function [location] = FindIsfLocation(data,string)
            location.start = regexp(data,string,'once'); %finding the start of the entry
            location.start = location.start + regexp(data(location.start:end),' ','once'); % finding the space in between entry and value
            location.length = regexp(data(location.start:end),';','once')-2;
        end
        function [out]      = GetIsfInformation(data,location)
            out = data(location.start:location.start+location.length);
        end
        % Compressed Waveform Storage (for LeCroy (.dat) Tektonix (.dat) and Tektronix (.csv)
        function Voltage    = ReadCompressedWaveform(CompressedFilePath,Npts)
            fid = fopen(CompressedFilePath,'r');
            BytesPerPt = fread(fid,1,'uint8');
            NumLevels  = fread(fid,1,'uint32');
            Levels     = fread(fid,NumLevels,'float64');
            
            switch BytesPerPt
                case 1
                    Voltage = fread(fid,Npts,'uint8=>uint8');
                case 2
                    Voltage = fread(fid,Npts,'uint16=>uint16');
            end
            
            fread(fid,1);
            if ~feof(fid)
                return
            end
            
            Voltage = Levels(Voltage);
            
        end
        function              WriteCompressedWaveform(CompressedFilePath,Voltage)
            
            Levels    = unique(Voltage);
            NumLevels = numel(Levels);
            
            if NumLevels <= 255
                BytesPerPt = 1;
                IntVoltage = uint8(zeros(size(Voltage)));
            elseif NumLevels <= 65535
                BytesPerPt = 2;
                IntVoltage = uint16(zeros(size(Voltage)));
            else
                return
            end
            
            for i = 1:NumLevels
                IntVoltage(Voltage == Levels(i)) = i;
            end
            
            fid = fopen(CompressedFilePath,'w');
            fwrite(fid,BytesPerPt,'uint8');
            fwrite(fid,NumLevels,'uint32');
            fwrite(fid,Levels,'float64');
            switch BytesPerPt
                case 1
                    fwrite(fid,IntVoltage,'uint8');
                case 2
                    fwrite(fid,IntVoltage,'uint16');
            end
            fclose(fid);
        end
        % Low Level Import Functions
        function s = ReadString(fid, Addr)
            fseek(fid,Addr,'bof'); %move to the address listed in relation to the beginning of the file
            s=deblank(fgets(fid,16)); %read the next 16 characters of the line (all strings in lecroy binary file are 16 characters long)
        end
        function e = ReadEnumLecroy(fid,Addr)
            fseek(fid,Addr,'bof');
            e = fread(fid,1,'int16');
        end
        function w = ReadWord(fid, Addr)
            fseek(fid,Addr,'bof');
            w = fread(fid,1,'int16');
        end
        function d = ReadDouble(fid, Addr)
            fseek(fid,Addr,'bof');
            d=fread(fid,1,'float64');
        end
        function s = ReadUnitDefinition(fid, Addr)
            fseek(fid,Addr,'bof'); %move to the address listed in relation to the beginning of the file
            s=deblank(fgets(fid,48)); %read the next 48 characters of the line (all strings in lecroy binary file are 16 characters long)
        end
        function t = ReadTimestamp(fid, Addr)
            fseek(fid,Addr,'bof');
            
            seconds	= fread(fid,1,'float64');
            minutes	= fread(fid,1,'int8');
            hours	= fread(fid,1,'int8');
            days	= fread(fid,1,'int8');
            months	= fread(fid,1,'int8');
            year	= fread(fid,1,'int16');
            
            t=sprintf('%i.%i.%i, %i:%i:%2.0f', days, months, year, hours, minutes, seconds);
        end
        function l = ReadULong(fid,Addr)
            fseek(fid,Addr,'bof');
            l = fread(fid,1,'ulong');
        end
        function l = ReadULongLong(fid,Addr)
            fseek(fid,Addr,'bof');
            l = fread(fid,1,'int64');
        end
        function s = ReadUShort(fid,Addr)
            fseek(fid,Addr,'bof');
            s = fread(fid,1,'ushort');
        end
        function f = ReadFloat(fid,Addr)
            fseek(fid,Addr,'bof');
            f=fread(fid,1,'float');
        end
        function l = ReadLong(fid,Addr)
            fseek(fid,Addr,'bof');
            l=fread(fid,1,'long');
        end
        function s = ReadShort(fid,Addr)
            fseek(fid,Addr,'bof');
            s = fread(fid,1,'short');
        end
        function c = ReadChar(fid,Addr,No_of_char,DoNotConvert)
            fseek(fid,Addr,'bof');
            if nargin < 4
                DoNotConvert = 'Convert';
            end
            if ~strcmp(DoNotConvert,'DoNotConvert')
                c = char(fread(fid,No_of_char,'char')');
            else
                c = fread(fid,No_of_char,'char')';
            end
        end
        function e = ReadEnumTek(fid,Addr)
            fseek(fid,Addr,'bof');
            e = fread(fid,1,'int');
        end
        function c = ReadDefinedFormat(fid,Addr,No_of_elem,format)
            fseek(fid,Addr,'bof');
            c = fread(fid,No_of_elem,format);
        end
    end
end