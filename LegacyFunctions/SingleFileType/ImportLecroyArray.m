%% This file is designed to read Lecroy binary (.trc) files when read into the workspace as a dataset from an HDF5 database file. 
%
% TO CLARIFY: This function is designed to operate on the output of
% h5read(), you cannot use this on normal .trc files!!!!!
%
% You should run the ImportLecroyArray function with the singular input an
% array of doubles as read in from the HDF5
% The output will be a struct containg file information, time series, and voltage. 
% Any issues contact Liam.


function waveform = ImportLecroyArray(ByteArray)

%% Initialising Variables and opening the binary file.
waveform = struct(); %Building the waveform struct

%% Finind the start location of the binary files, all lecroy binary files start with the characters WAVEDESC which is used as a reference location 

init_offset_search = char(ByteArray(1:50)); 
offset = strfind(init_offset_search,'WAVEDESC');
clearvars init_offset_search
get_locations

%% Closing and reopening the file such that the byte order (HIFIRST or LOFIRST) is considered.
% if logical(ReadEnum(fid,waveform.locations.COMM_ORDER))
%     fclose(fid);
%     fid=fopen(filename,'r','ieee-le');		% HIFIRST
% else
%     fclose(fid);
%     fid=fopen(filename,'r','ieee-be');		% LOFIRST
% end
% clearvars filename init_offset_search COMM_ORDER ans

%% Reading information from the file, each 
get_waveform_info

waveform_raw = waveform; %Need info settings in raw format for a few bits, so copy struct in raw from before mapping Enums to their meaning.
decipher_enum

read_user_text
get_trigtime_array %% NOT ADAPTED, Currently nothing to work from so no idea how to really interact with this
get_ris_time_array %% NOT ADAPTED, Currently nothing to work from so no idea how to really interact with this
read_voltages
read_second_voltages
generate_time_series


%% Removing unneccessary information from the waveform struct before it is returned
waveform = rmfield(waveform,'locations');
clearvars waveform_raw offset


%% Functions contained within the master function, these serve to simplify the code
    function get_locations
        waveform.locations.TEMPLATE_NAME        = offset+ 16; %string
        waveform.locations.COMM_TYPE            = offset+ 32; %enum
        waveform.locations.COMM_ORDER           = offset+ 34; %enum
        waveform.locations.WAVE_DESCRIPTOR      = offset+ 36;	%long length of the descriptor block
        waveform.locations.USER_TEXT            = offset+ 40;	%long  length of the usertext block
        waveform.locations.RES_DESC1            = offset+ 44; %long
        waveform.locations.TRIGTIME_ARRAY       = offset+ 48; %long
        waveform.locations.RIS_TIME_ARRAY       = offset+ 52; %long
        waveform.locations.RES_ARRAY            = offset+ 56; %long
        waveform.locations.WAVE_ARRAY_1         = offset+ 60;	%long length (in Byte) of the sample array
        waveform.locations.WAVE_ARRAY_2         = offset+ 64; %long length (in Byte) of the optional second sample array
        waveform.locations.RES_ARRAY2           = offset+ 68; %long
        waveform.locations.RES_ARRAY3           = offset+ 72; %long
        waveform.locations.INSTRUMENT_NAME      = offset+ 76; %string
        waveform.locations.INSTRUMENT_NUMBER    = offset+ 92; %long
        waveform.locations.TRACE_LABEL          = offset+ 96; %string
        waveform.locations.RESERVED1            = offset+ 112; %word
        waveform.locations.RESERVED2            = offset+ 114; %word
        waveform.locations.WAVE_ARRAY_COUNT     = offset+ 116; %long
        waveform.locations.PNTS_PER_SCREEN      = offset+ 120; %long
        waveform.locations.FIRST_VALID_PNT      = offset+ 124; %long
        waveform.locations.LAST_VALID_PNT       = offset+ 128; %long
        waveform.locations.FIRST_POINT          = offset+ 132; %long
        waveform.locations.SPARSING_FACTOR      = offset+ 136; %long
        waveform.locations.SEGMENT_INDEX        = offset+ 140; %long
        waveform.locations.SUBARRAY_COUNT       = offset+ 144; %long
        waveform.locations.SWEEPS_PER_AQG       = offset+ 148; %long
        waveform.locations.POINTS_PER_PAIR      = offset+ 152; %word
        waveform.locations.PAIR_OFFSET          = offset+ 154; %word
        waveform.locations.VERTICAL_GAIN        = offset+ 156; %float 
        waveform.locations.VERTICAL_OFFSET      = offset+ 160; %float
        waveform.locations.MAX_VALUE            = offset+ 164; %float
        waveform.locations.MIN_VALUE            = offset+ 168; %float
        waveform.locations.NOMINAL_BITS         = offset+ 172; %word
        waveform.locations.NOM_SUBARRAY_COUNT   = offset+ 174; %word
        waveform.locations.HORIZ_INTERVAL       = offset+ 176; %float
        waveform.locations.HORIZ_OFFSET         = offset+ 180; %double
        waveform.locations.PIXEL_OFFSET         = offset+ 188; %double
        waveform.locations.VERTUNIT             = offset+ 196; %unit_definition 
        waveform.locations.HORUNIT              = offset+ 244; %unit_definition
        waveform.locations.HORIZ_UNCERTAINTY    = offset+ 292; %float
        waveform.locations.TRIGGER_TIME         = offset+ 296; %time_stamp
        waveform.locations.ACQ_DURATION         = offset+ 312; %float
        waveform.locations.RECORD_TYPE          = offset+ 316; %enum
        waveform.locations.PROCESSING_DONE      = offset+ 318; %enum
        waveform.locations.RESERVED5            = offset+ 320; %word
        waveform.locations.RIS_SWEEPS           = offset+ 322; %word
        waveform.locations.TIMEBASE             = offset+ 324; %enum
        waveform.locations.VERT_COUPLING		= offset+ 326; %enum
        waveform.locations.PROBE_ATT			= offset+ 328; %float
        waveform.locations.FIXED_VERT_GAIN      = offset+ 332; %enum
        waveform.locations.BANDWIDTH_LIMIT      = offset+ 334; %enum
        waveform.locations.VERTICAL_VERNIER     = offset+ 336; %enum
        waveform.locations.ACQ_VERT_OFFSET      = offset+ 340; %float
        waveform.locations.WAVE_SOURCE          = offset+ 344; %enum
    end
    function get_waveform_info
        waveform.info.template_name           = ReadString(ByteArray,waveform.locations.TEMPLATE_NAME);
        waveform.info.comm_type               = ReadEnum(ByteArray,waveform.locations.COMM_TYPE);
        waveform.info.comm_order              = ReadEnum(ByteArray,waveform.locations.COMM_ORDER);
        waveform.info.wave_descriptor         = ReadLong(ByteArray,waveform.locations.WAVE_DESCRIPTOR);
        waveform.info.user_text               = ReadLong(ByteArray,waveform.locations.USER_TEXT);
        waveform.info.res_desc1               = ReadLong(ByteArray,waveform.locations.RES_DESC1);
        waveform.info.trigtime_array          = ReadLong(ByteArray,waveform.locations.TRIGTIME_ARRAY);
        waveform.info.ris_time_array          = ReadLong(ByteArray,waveform.locations.RIS_TIME_ARRAY);
        waveform.info.res_array               = ReadLong(ByteArray,waveform.locations.RES_ARRAY);
        waveform.info.wave_array1             = ReadLong(ByteArray,waveform.locations.WAVE_ARRAY_1);
        waveform.info.wave_array2             = ReadLong(ByteArray,waveform.locations.WAVE_ARRAY_2);
        waveform.info.res_array2              = ReadLong(ByteArray,waveform.locations.RES_ARRAY2);
        waveform.info.res_array3              = ReadLong(ByteArray,waveform.locations.RES_ARRAY3);
        waveform.info.instrument_name         = ReadString(ByteArray,waveform.locations.INSTRUMENT_NAME);
        waveform.info.instrument_number       = ReadLong(ByteArray,waveform.locations.INSTRUMENT_NUMBER);
        waveform.info.trace_label             = ReadString(ByteArray,waveform.locations.TRACE_LABEL);
        waveform.info.reserved1               = ReadWord(ByteArray,waveform.locations.RESERVED1);
        waveform.info.reserved2               = ReadWord(ByteArray,waveform.locations.RESERVED2);
        waveform.info.wave_array_count        = ReadLong(ByteArray,waveform.locations.WAVE_ARRAY_COUNT);
        waveform.info.points_per_screen       = ReadLong(ByteArray,waveform.locations.PNTS_PER_SCREEN);
        waveform.info.first_valid_point       = ReadLong(ByteArray,waveform.locations.FIRST_VALID_PNT);
        waveform.info.last_valid_point        = ReadLong(ByteArray,waveform.locations.LAST_VALID_PNT);
        waveform.info.first_point             = ReadLong(ByteArray,waveform.locations.FIRST_POINT);
        waveform.info.sparsing_factor         = ReadLong(ByteArray,waveform.locations.SPARSING_FACTOR);
        waveform.info.segment_index           = ReadLong(ByteArray,waveform.locations.SEGMENT_INDEX);
        waveform.info.subarray_count          = ReadLong(ByteArray,waveform.locations.SUBARRAY_COUNT);
        waveform.info.sweeps_per_aqg          = ReadLong(ByteArray,waveform.locations.SWEEPS_PER_AQG);
        waveform.info.points_per_pair         = ReadWord(ByteArray,waveform.locations.POINTS_PER_PAIR);
        waveform.info.pair_offset             = ReadWord(ByteArray,waveform.locations.PAIR_OFFSET);
        waveform.info.vertical_gain           = ReadFloat(ByteArray,waveform.locations.VERTICAL_GAIN);
        waveform.info.vertical_offset         = ReadFloat(ByteArray,waveform.locations.VERTICAL_OFFSET);
        waveform.info.max_value               = ReadFloat(ByteArray,waveform.locations.MAX_VALUE);
        waveform.info.min_value               = ReadFloat(ByteArray,waveform.locations.MIN_VALUE);
        waveform.info.nominal_bits            = ReadWord(ByteArray,waveform.locations.NOMINAL_BITS);
        waveform.info.nom_subarray_count      = ReadWord(ByteArray,waveform.locations.NOM_SUBARRAY_COUNT);
        waveform.info.horizontal_interval     = ReadFloat(ByteArray,waveform.locations.HORIZ_INTERVAL);
        waveform.info.horizontal_offset       = ReadDouble(ByteArray,waveform.locations.HORIZ_OFFSET);
        waveform.info.pixel_offset            = ReadDouble(ByteArray,waveform.locations.PIXEL_OFFSET);
        waveform.info.vertical_unit           = ReadUnitDefinition(ByteArray,waveform.locations.VERTUNIT);
        waveform.info.horizontal_unit         = ReadUnitDefinition(ByteArray,waveform.locations.HORUNIT);
        waveform.info.horizontal_uncertainty  = ReadFloat(ByteArray,waveform.locations.HORIZ_UNCERTAINTY);
        waveform.info.trigger_time            = ReadTimestamp(ByteArray,waveform.locations.TRIGGER_TIME);
        waveform.info.acq_duration            = ReadFloat(ByteArray,waveform.locations.ACQ_DURATION);
        waveform.info.recording_type          = ReadEnum(ByteArray,waveform.locations.RECORD_TYPE);
        waveform.info.processing_done         = ReadEnum(ByteArray,waveform.locations.PROCESSING_DONE);
        waveform.info.reserved5               = ReadWord(ByteArray,waveform.locations.RESERVED5);
        waveform.info.ris_sweeps              = ReadWord(ByteArray,waveform.locations.RIS_SWEEPS);
        waveform.info.timebase                = ReadEnum(ByteArray,waveform.locations.TIMEBASE);
        waveform.info.vertical_coupling       = ReadEnum(ByteArray,waveform.locations.VERT_COUPLING);
        waveform.info.probe_attenuation       = ReadFloat(ByteArray,waveform.locations.PROBE_ATT);
        waveform.info.fixed_vertical_gain     = ReadEnum(ByteArray,waveform.locations.FIXED_VERT_GAIN);
        waveform.info.bandwidth_limit         = ReadEnum(ByteArray,waveform.locations.BANDWIDTH_LIMIT);
        waveform.info.vertical_vernier        = ReadFloat(ByteArray,waveform.locations.VERTICAL_VERNIER);
        waveform.info.acq_vertical_offset     = ReadFloat(ByteArray,waveform.locations.ACQ_VERT_OFFSET);
        waveform.info.wave_source             = ReadEnum(ByteArray,waveform.locations.WAVE_SOURCE);
    end
    function decipher_enum
        tmp = ['byte';'word'];
        waveform.info.comm_type = tmp(1+waveform.info.comm_type,:);
        
        tmp = ['HIFIRST';'LOFIRST'];
        waveform.info.comm_order = tmp(1+waveform.info.comm_order,:);
        
        tmp=[
        'single_sweep      ';	'interleaved       '; 'histogram         ';
        'graph             ';	'filter_coefficient'; 'complex           ';
        'extrema           ';	'sequence_obsolete '; 'centered_RIS      ';	
        'peak_detect       '];
        waveform.info.recording_type = deblank(tmp(1+waveform.info.recording_type,:));
        
        tmp=[
        'no_processing';   'fir_filter   '; 'interpolated ';   'sparsed      ';
        'autoscaled   ';   'no_result    '; 'rolling      ';   'cumulative   '];
        waveform.info.processing_done		= deblank(tmp (1+waveform.info.processing_done,:));
        
        if waveform.info.timebase == 100
            waveform.info.timebase = 'EXTERNAL';
        else
            tmp=[
            '1 ps / div  ';'2 ps / div  ';'5 ps / div  ';'10 ps / div ';'20 ps / div ';'50 ps / div ';'100 ps / div';'200 ps / div';'500 ps / div';
            '1 ns / div  ';'2 ns / div  ';'5 ns / div  ';'10 ns / div ';'20 ns / div ';'50 ns / div ';'100 ns / div';'200 ns / div';'500 ns / div';
            '1 us / div  ';'2 us / div  ';'5 us / div  ';'10 us / div ';'20 us / div ';'50 us / div ';'100 us / div';'200 us / div';'500 us / div';
            '1 ms / div  ';'2 ms / div  ';'5 ms / div  ';'10 ms / div ';'20 ms / div ';'50 ms / div ';'100 ms / div';'200 ms / div';'500 ms / div';
            '1 s / div   ';'2 s / div   ';'5 s / div   ';'10 s / div  ';'20 s / div  ';'50 s / div  ';'100 s / div ';'200 s / div ';'500 s / div ';
            '1 ks / div  ';'2 ks / div  ';'5 ks / div  '];
            waveform.info.timebase = deblank(tmp(1+waveform.info.timebase,:));
        end
        
        tmp=['DC_50_Ohms'; 'ground    ';'DC 1MOhm  ';'ground    ';'AC 1MOhm  '];
        waveform.info.vertical_coupling		= deblank(tmp(1+waveform.info.vertical_coupling,:));
        
        tmp=[
        '1 uV / div  ';'2 uV / div  ';'5 uV / div  ';'10 uV / div ';'20 uV / div ';'50 uV / div ';'100 uV / div';'200 uV / div';'500 uV / div';
        '1 mV / div  ';'2 mV / div  ';'5 mV / div  ';'10 mV / div ';'20 mV / div ';'50 mV / div ';'100 mV / div';'200 mV / div';'500 mV / div';
        '1 V / div   ';'2 V / div   ';'5 V / div   ';'10 V / div  ';'20 V / div  ';'50 V / div  ';'100 V / div ';'200 V / div ';'500 V / div ';
        '1 kV / div  '];
        waveform.info.fixed_vertical_gain = deblank(tmp(1+waveform.info.fixed_vertical_gain,:));
        
        tmp=['off'; 'on '];
        waveform.info.bandwidth_limit	= deblank(tmp(1+waveform.info.bandwidth_limit,:));
        
        if waveform.info.wave_source == 9
            waveform.info.wave_source = 'UNKNOWN';
        else
            tmp=['C1     ';'C2     ';'C3     ';'C4     ';'UNKNOWN'];
            waveform.info.wave_source = deblank(tmp (1+waveform.info.wave_source,:));
        end
        
        clearvars tmp
        
    end
    function read_user_text
        if logical(waveform.info.user_text)
            disp('THIS FILE CONTAINS INFORMATION THAT MAY NOT HAVE BEEN IMPORTED, PLEASE SAVE AS .dat ON SCOPE AND SEND LIAM THE .trc FILE')
            start_idx = offset + waveform.info.wave_descriptor;
            end_idx   = start_idx + waveform.info.user_text - 1;
            waveform.usertext = char(ByteArray(startidx:end_idx));
        end
    end 
    function get_trigtime_array
        if logical(waveform.info.trigtime_array)
            disp('THIS FILE CONTAINS INFORMATION THAT MAY NOT HAVE BEEN IMPORTED, PLEASE SAVE AS .dat ON SCOPE AND SEND LIAM THE .trc FILE')
%             waveform.trigtime_array.trigger_time = [];
%             waveform.trigtime_array.trigger_offset = [];
%             for i = 0:(waveform.info.nom_subarray_count-1)
%                 waveform.trigtime_array.trigger_time(i+1) = ReadDouble(fid,offset+waveform.info.wave_descriptor + waveform.info.user_text + (i*16));
%                 waveform.trigtime_array.trigger_offset(i+1) = ReadDouble(fid,offset+waveform.info.wave_descriptor + waveform.info.user_text + (i*16) + 8);
%             end
%             waveform.trigtime_array.trigger_time = ReadDouble(fid,offset+waveform.info.wave_descriptor + waveform.info.user_text);
%             waveform.trigtime_array.trigger_offset = ReadDouble(fid,offset+waveform.info.wave_descriptor + waveform.info.user_text + 8);
        end
    end %% NOT ADAPTED
    function get_ris_time_array
        if logical(waveform.info.ris_time_array)
            disp('THIS FILE CONTAINS INFORMATION THAT MAY NOT HAVE BEEN IMPORTED, PLEASE SAVE AS .dat ON SCOPE AND SEND LIAM THE .trc FILE')
%             fseek(fid,offset+waveform.info.wave_descriptor + waveform.info.user_text+waveform.info.trigtime_array,'bof');
%             waveform.ris_time_array.ris_offset = fread(fid,waveform.info.ris_sweeps,'float64');
        end
    end %% NOT ADAPTED
    function read_voltages
        start_idx = offset + waveform_raw.info.wave_descriptor + waveform_raw.info.user_text + waveform_raw.info.trigtime_array + waveform.info.ris_time_array;
        end_idx = start_idx + waveform.info.wave_array1 - 1;
        if logical(waveform_raw.info.comm_type) %word
            waveform.voltage = double(typecast(uint8(ByteArray(start_idx:end_idx)),'int16'))';
        else %byte
            waveform.voltage = ByteArray(start_idx:end_idx);
        end
        
        waveform.voltage = waveform.voltage * waveform.info.vertical_gain - waveform.info.vertical_offset;    
    end
    function read_second_voltages
        if logical(waveform.info.wave_array2)
            disp('THIS FILE CONTAINS INFORMATION THAT MAY NOT HAVE BEEN IMPORTED, PLEASE SAVE AS .dat ON SCOPE AND SEND LIAM THE .trc FILE')
            start_idx = offset + waveform_raw.info.wave_descriptor + waveform_raw.info.user_text + waveform_raw.info.trigtime_array + waveform.info.ris_time_array + waveform.info.wave_array1;
            end_idx = start_idx + waveform.info.wave_array2 - 1;
            if logical(waveform_raw.info.comm_type) %word
                waveform.voltage = double(typecast(uint8(ByteArray(start_idx:end_idx)),'int16'))';
            else %byte
                waveform.voltage = ByteArray(start_idx:end_idx);
            end
            waveform.voltage2 = waveform.voltage2 * waveform.info.vertical_gain - waveform.info.vertical_offset;               
        end
    end 
    function generate_time_series
        waveform.time = (0:waveform.info.wave_array_count-1) * waveform.info.horizontal_interval + waveform.info.horizontal_offset;
        waveform.time = waveform.time(:);
    end
end


%% Subordinate functions that are repeatedly called to read different data types from the file.
function s=ReadString(ByteArray, Addr)
	s=deblank(char(ByteArray(Addr:Addr+15))); %read the next 16 characters of the line (all strings in lecroy binary file are 16 characters long)
end 
function e=ReadEnum(ByteArray,Addr)
    e = double(typecast(uint8(ByteArray(Addr:Addr+1)),'int16'));
end
function l=ReadLong(ByteArray, Addr)
    l = double(typecast(uint8(ByteArray(Addr:Addr+3)),'int32'));
end
function w=ReadWord(ByteArray, Addr)
    w = double(typecast(uint8(ByteArray(Addr:Addr+1)),'int16'));	
end
function f=ReadFloat(ByteArray, Addr)
    f = double(typecast(uint8(ByteArray(Addr:Addr+3)),'single'));	
end
function d=ReadDouble(ByteArray, Addr)
    d = double(typecast(uint8(ByteArray(Addr:Addr+7)),'double'));
end
function s=ReadUnitDefinition(ByteArray, Addr)
	s=deblank(char(ByteArray(Addr:Addr+47))); %read the next 48 characters of the line (all unit definitions in lecroy binary file are 48 characters long)
end
function t=ReadTimestamp(ByteArray, Addr)
    seconds = double(typecast(uint8(ByteArray(Addr:Addr+7)),'double'));
    minutes	= ByteArray(Addr+8);
    hours	= ByteArray(Addr+9);
    days	= ByteArray(Addr+10);
    months	= ByteArray(Addr+11);
    year = double(typecast(uint8(ByteArray(Addr+12:Addr+13)),'int16'));
 
    t=sprintf('%i.%i.%i, %i:%i:%2.0f', days, months, year, hours, minutes, seconds);
end