classdef scopetrace < handle
% scopetrace: Class for storing oscilloscope traces.
% 
% An object for importing binary oscilloscope files from either Tektronix
% or LeCroy oscilloscopes found within the ISML Lab. This object will
% manage storage, summarising metadata, and accessing of raw data for a
% variety of filetypes. Where file types are not conducive to quick access
% (.csv and .dat a couple of examples) the object will create binary files
% to accompany the raw file, these will allow all future imports to run
% much quicker so long as the original is not moved away from its binary 
% Doppelgänger.
%
% scopetrace: Dependencies
% 
%   None.
% 
% scopetrace: Installation
%
%   Download the folder and put it somewhere logical. This package is 
%   used by other tools you may uese (PDVTrace, PDVAnalysis & LightGate)
%   so youll want it to have a fairly logical path. You will need to 
%   keep the +lib and +tools folders in the same folder as the @scopetrace
%   folder, as without this the class will not have access to the low level
%   functions that let it work, and that keep the main class folder less 
%   cluttered.
%
% scopetrace: Constructor Arguments (All given as Name Value Pairs):
%
%   "path" - Absolute or relative file path to a raw oscilloscope file.
%
%   "echo" - Logical, (False default) for more verbose mode.
%
%   "cache" - Logical, (False default), if active will enforce all data is 
%             stored in workspace, instead of being read in when needed 
%             (use only if you want marginally faster access at the 
%             expense of workspace size). Access should be very quick even
%             without enabling this.
%   
%   Note: If run without arguments scopetrace will launch a file selection
%         diaglogue.
%
    properties 
        % path - The path given to the raw oscilloscope trace
        path string
        % TraceType - A string containing a descriptor of the type of scope.
        type string
        % Info - A struct containing lots of metadata about the oscilloscope trace. The import will pull as much data as possible depending on the file type.
        info
        % Parent - A handle to an encapsulating object
        parent 
    end
    properties (Dependent)
        % Time - Column vector containing time values for the oscilloscope trace.
        time    (:,1) numerictype
        % Voltage - Column vector containing voltage values for the oscilloscope trace.
        voltage (:,1) numerictype
        % SecondVoltage - Column vector containing secondary voltage values for the oscilloscope trace, this will only be populated if this data exists.
        second_voltage
        % UserText - A string containing UserText, a field that may be present in some binary oscilloscope files.
        user_text
        % TrigtimeArray - A property containing the Tigger Times, this will only be populated in multi-trigger traces.
        trig_time_array
        % RisTimeArray - A property containing information about Random Interleaved Sampling should it be used.
        ris_time_array
        % Channel - A string containing (if anything) the apparent channel of the trace.
        channel     string
        sample_rate double
        is_valid    logical
        % Note : UserText, TrigtimeArray and RisTimeArray will all return
        % errors requestiong you send me the file, this is becuase the
        % framework for importing this is untested. I will validate and
        % update the code if you hit these errors!
    end
    properties (Hidden)
        echo
        cache
        offset
        locs
        header_path
        raw_info
        valid_import = false
    end
    methods
        function obj = scopetrace(args)
            %Valid Arguments - {"path",  "echo",  "cache"}
            % 
            % INPUT "path" - Absolute or relative file path to a raw 
            %                oscilloscope file. This will be imported 
            %                using ScopeTrace.
            %                               
            %       "echo" - A logical value that will trigger a more
            %                verbose import mode. Default = false
            %
            %       "cache - An on/off switch state that will enforce
            %                the storage of all loaded data in the 
            %                workspace, instead of being read in when 
            %                needed [1]. Default = false
            %                
            %       Note: If run without any input arguments the
            %             constructor will open a file dialogue to select a
            %             raw oscilloscope file.
            %
            % OUTPUT  obj - The object.
            %
            % REMARKS   1)  Enable this only if you want marginally faster
            %               access at the expense of workspace size).
            %               Access should be very quick even without
            %               enabling this.
            %
            arguments
                args.path  (1,1) string {mustBeFile} = tools.uigetfullfile()
                args.echo  (1,1) matlab.lang.OnOffSwitchState = "off";
                args.cache (1,1) matlab.lang.OnOffSwitchState = "off";
            end
            
            if args.path.startsWith(filesep)
                obj.path = args.path;
            else
                obj.path = which(args.path);
            end
            obj.echo  = args.echo;
            obj.cache = args.cache;
            
            if isfile(obj.path)
                obj.get_type;
                switch obj.type
                    case "LeCroy (.trc)"
                        lib.lecroy.trc.get_info(obj)
                    case "LeCroy (.dat)"
                        lib.lecroy.dat.get_info(obj)
                    case "Tektronix (.wfm)"
                        lib.tektronix.wfm.get_info(obj)
                    case "Tektronix (.isf)"
                        lib.tektronix.isf.get_info(obj)
                    case "Tektronix (.dat)"
                        lib.tektronix.dat.get_info(obj)
                    case "Tektronix (.csv)"
                        obj.info = "Tektronix (.csv) files are not supported, please save as .isf or .wfm";
                        % obj = obj.GetTektronixCsvInfo;
                    case "Simple CSV (.SimpleCSV)"
                        lib.simplecsv.get_info(obj)
                    otherwise
                        obj.info = "Invalid File Type, must be: .trc, .dat, .wfm, .isf or .csv";
                end
            end
        end
        function out = get.time(           obj)
            if obj.valid_import
                switch obj.type
                    case "LeCroy (.trc)"
                        out = lib.lecroy.trc.get_time(obj);
                    case "LeCroy (.dat)"
                        out = lib.lecroy.dat.get_time(obj);
                    case "Tektronix (.wfm)"
                        out = lib.tektronix.wfm.get_time(obj);
                    case "Tektronix (.isf)"
                        out = lib.tektronix.isf.get_time(obj);
                    case "Tektronix (.dat)"
                        out = lib.tektronix.dat.get_time(obj);
                    case "Tektronix (.csv)"
                        disp("Not Currently Available for Tektronnix (.csv)")
                        out = [];
                        %time = lib.tektronix.csv.get_time(obj); Not Yet Written
                    case "Simple CSV (.SimpleCSV)"
                        out = lib.simplecsv.get_time(obj);
                end
            else
                out = "Invalid Import";
            end
        end
        function out = get.voltage(        obj)
            if obj.valid_import
                switch obj.type
                    case "LeCroy (.trc)"
                        out = lib.lecroy.trc.get_voltage(obj);
                    case "LeCroy (.dat)"
                        out = lib.lecroy.dat.get_voltage(obj);
                    case "Tektronix (.wfm)"
                        out = lib.tektronix.wfm.get_voltage(obj);
                    case "Tektronix (.isf)"
                        out = lib.tektronix.isf.get_voltage(obj);
                    case "Tektronix (.dat)"
                        out = lib.tektronix.dat.get_voltage(obj);
                    case "Tektronix (.csv)"
                        out = "Not Currently Available for Tektronnix (.csv)";
                        % out = lib.tektronix.csv.get_voltage(obj);
                    case "Simple CSV (.SimpleCSV)"
                        out = lib.simplecsv.get_voltage(obj);
                end
            else
                out = "Invalid Import";
            end
        end
        function out = get.second_voltage( obj)
            if obj.valid_import
                switch obj.type
                    case "LeCroy (.trc)"
                        out = lib.lecroy.trc.get_second_voltage(obj);
                    case "Tektronix (.wfm)"
                        out = "Not Currently Available for Tektronnix (.wfm)";
                        % out = lib.tektronix.wfm.get_second_voltage(obj);
                    case "Tektronix (.csv)"
                        out = "Not Available for Tektronnix (.csv)";
                        % out = lib.tektronix.csv.get_second_voltage(obj);
                    case "Simple CSV (.SimpleCSV)"
                        out = "Not Available for Simple CSV (.SimpleCSV)";
                end
            else
                out = "Invalid Import";
            end
        end
        function out = get.user_text(      obj)
            if obj.valid_import
                switch obj.type
                    case "LeCroy (.trc)"
                        out = lib.lecroy.trc.get_user_text(obj);
                end
            else
                out = "Invalid Import";
            end
        end
        function out = get.trig_time_array(obj)
            if obj.valid_import 
                switch obj.type
                    case "LeCroy (.trc)"
                        out = lib.lecroy.trc.get_trig_time_array(obj);
                end
            else
                out = "Invalid Import";
            end
        end
        function out = get.ris_time_array( obj)
            if obj.valid_import
                switch obj.type
                    case "LeCroy (.trc)"
                        out = lib.lecroy.trc.get_ris_time_array(obj);
                end
            else
                out = "Invalid Import";
            end
            
        end
        function out = get.channel(        obj)
            % Ch1, Ch2, Ch3, Ch4, ??? Outputs
            switch obj.type
                case "Tektronix (.isf)"
                    out = split(obj.info.waveform_identifier,",");
                    out = out{1};
                case "LeCroy (.trc)"
                    out = obj.info.wave_source;
                    if out.startsWith("C")
                        out = out.insertAfter("C","h");
                    else
                        out = "???";
                    end
                otherwise
                    out = "???";
            end
        end
        function out = get.is_valid(       obj)
            out = obj.valid_import;
        end
        function out = get.sample_rate(    obj)
            if obj.valid_import
                switch obj.type
                    case "LeCroy (.trc)"
                        dt = obj.info.horizontal_interval;
                    case "LeCroy (.dat)"
                        dt = (obj.info.EndTime - obj.info.StartTime) / (obj.info.NumberOfPoints - 1);
                    case "Tektronix (.wfm)"
                        dt = obj.RawInfo.Waveform_header.Implicit_Dimension_1.Dim_scale;
                    case "Tektronix (.isf)"
                        dt = obj.info.horizontal_interval;
                    case "Tektronix (.dat)"
                        dt = (obj.info.EndTime - obj.info.StartTime) / (obj.info.NumberOfPoints - 1);
                    case "Tektronix (.csv)"
                        error("Not Currently Available for Tektronnix (.csv)")
                    case "Simple CSV (.SimpleCSV)"
                        dt = (obj.info.EndTime - obj.info.StartTime) / (obj.info.NumberOfPoints - 1);
                end
                out = 1.0 / dt;
            end
        end
    end
    methods (Static)
        tf = validate(path)
    end
end