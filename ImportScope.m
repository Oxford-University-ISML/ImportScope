function waveform = ImportScope
%% Getting file
[filename,pathname] = uigetfile('*');

%% Checking file format
if strcmp(filename(end-2:end),'trc')
    file_type = 'lecroy';
    disp('Well tested import function, please check imported correctly before removing trace from scope')
elseif strcmp(filename(end-2:end),'wfm')
    file_type = 'tek_wfm';
    disp('Fairly well tested import function, please check imported correctly before removing trace from scope')
elseif strcmp(filename(end-2:end),'isf')
    file_type = 'tek_isf';
    disp('Basically untested import function, please carefully check and if neccessary send .isf file to Liam')
else
    disp('Unknown filetype, check selection.')
    file_type = NaN;
end

%% Setting filename into correct format
filename = [pathname,filename];
clearvars pathname

%% Importing file based on previosuly determined file type.
if ~isnan(file_type)
    if strcmp(file_type,'lecroy')
        waveform = ImportScopeLecroy(filename);
    elseif strcmp(file_type,'tek_wfm')
        waveform = ImportScopeTekWFM(filename);
    elseif strcmp(file_type,'tek_isf')
        waveform = ImportScopeTekISF(filename);
    end
end

end

%% Each import function
function waveform = ImportScopeTekISF(filename)
%% Initialising Locations & Waveform Variables and opening the binary file.
fid = fopen(filename,'r'); % Opening the file that has been selected

waveform = struct(); %Building the waveform struct
locations = struct(); % building the locations struct, this is used for working out where to read the data in the file, locations found by Liam on 4054 isf file, could vary scope to scope as no specific format for tek scopes.

%% Reading in the opening 1000 bytes, converting to character and then finding the endian-ness

data = fread(fid,1000,'*char')';
locations.byte_order = find_location('BYT_O');
waveform.information.byte_order = data(locations.byte_order.start:locations.byte_order.start+locations.byte_order.length);

%% Closing then reopening the file with the correct endianness

fclose(fid);
if strcmp(waveform.information.byte_order,'MSB') % if most significant byte first then big-endian
    fopen(filename,'r','ieee-be');
elseif strcmp(waveform.information.byte_order,'LSB') % if least significant bye first then little-endian
    fopen(filename,'r','ieee-le');
else % if its neither of these then something has gone very wrong
    waveform = NaN;
    disp('WAVEFORM NOT IMPORTED CORRECTLY, PLEASE SAFE AS .CSV & SNED .ISF TO LIAM.')
    return
end
clearvars filename %not needed anymore so saving RAM

%% Importing the header information first getting lcoations then pulling the information

get_locations
get_informations
clean_strings

clearvars locations

%% Finding the start fo the data array and then calculating the no of points in said array
fseek(fid,regexp(data,'#','once'),'bof');

clearvars data 
no_of_points = str2double(fread(fid,1,'*char'));
no_of_points = str2double(fread(fid,no_of_points,'*char')');

if ~waveform.information.no_of_points * waveform.information.bytes_per_point == no_of_points || ~waveform.information.bits_per_point/8 == waveform.information.bytes_per_point
    waveform = NaN;
    disp('WAVEFORM NOT IMPORTED CORRECTLY, PLEASE SAFE AS .CSV & SNED .ISF TO LIAM.')
    return
end
clearvars -except fid waveform

%% Reading the Curve data
if waveform.information.bytes_per_point == 1
    waveform.voltage = fread(fid,waveform.information.no_of_points,'int8');
elseif waveform.information.bytes_per_point == 2
    waveform.voltage = fread(fid,waveform.information.no_of_points,'int16');
else
    waveform = NaN;
end

%% Creating the time and voltage fields.
waveform.voltage = waveform.information.vertical_zero + waveform.information.vertical_scale_factor * (waveform.voltage - waveform.information.vertical_offset);
waveform.time = waveform.information.horizontal_interval * ((1:waveform.information.no_of_points)' - waveform.information.trigger_point_offset);

%% Cleaning the information struct
clean_information_struct

%% Checking at the end of the file
fread(fid,1); %sometimes need to read off the end of file for some reason
if ~feof(fid) %checking to ensure we are at the end of the file (we should be)
    waveform = NaN;
    disp('WAVEFORM NOT IMPORTED CORRECTLY, PLEASE SAFE AS .CSV & SNED .ISF TO LIAM.')
    return
end

%% packaging for output

fclose(fid);
clearvars ans fid

%% functions nested to make the code easier to read
    function get_locations
        locations.no_of_points              = find_location('NR_P');
        locations.bytes_per_point           = find_location('BYT_N');
        locations.bits_per_point            = find_location('BIT_N');
        locations.encoding                  = find_location('ENC');
        locations.binary_format             = find_location('BN_F');
        locations.byte_order                = find_location('BYT_O');
        locations.waveform_identifier       = find_location('WFI');
        locations.point_format              = find_location('PT_F');
        locations.horizontal_unit           = find_location('XUN');
        locations.horizontal_interval       = find_location('XIN');
        locations.horizontal_zero           = find_location('XZE');
        locations.trigger_point_offset      = find_location('PT_O');
        locations.vertical_unit             = find_location('YUN');
        locations.vertical_scale_factor     = find_location('YMU');
        locations.vertical_offset           = find_location('YOF');
        locations.vertical_zero             = find_location('YZE');
        locations.vertical_scale            = find_location('VSCALE');
        locations.horizontal_scale          = find_location('HSCALE');
        locations.vertical_position_unknown = find_location('VPOS');
        locations.vertical_offset_unknown   = find_location('VOFFSET');
        locations.horizontal_delay_unknown  = find_location('HDELAY');
    end
    function [location] = find_location(string)
        location = struct();
        location.start = regexp(data,string,'once'); %finding the start of the entry
        location.start = location.start + regexp(data(location.start:end),' ','once'); % finding the space in between entry and value
        location.length = regexp(data(location.start:end),';','once')-2;
    end
    
    function get_informations
        waveform.information.no_of_points              = str2double(get_information(locations.no_of_points));
        waveform.information.bytes_per_point           = str2double(get_information(locations.bytes_per_point));
        waveform.information.bits_per_point            = str2double(get_information(locations.bits_per_point));
        waveform.information.encoding                  = get_information(locations.encoding);
        waveform.information.binary_format             = get_information(locations.binary_format);
        waveform.information.byte_order                = get_information(locations.byte_order);
        waveform.information.waveform_identifier       = get_information(locations.waveform_identifier);
        waveform.information.point_format              = get_information(locations.point_format);
        waveform.information.horizontal_unit           = get_information(locations.horizontal_unit);
        waveform.information.horizontal_interval       = str2double(get_information(locations.horizontal_interval));
        waveform.information.horizontal_zero           = str2double(get_information(locations.horizontal_zero));
        waveform.information.trigger_point_offset      = str2double(get_information(locations.trigger_point_offset));
        waveform.information.vertical_unit             = get_information(locations.vertical_unit);
        waveform.information.vertical_scale_factor     = str2double(get_information(locations.vertical_scale_factor));
        waveform.information.vertical_offset           = str2double(get_information(locations.vertical_offset));
        waveform.information.vertical_zero             = str2double(get_information(locations.vertical_zero));
        waveform.information.vertical_scale            = str2double(get_information(locations.vertical_scale));
        waveform.information.horizontal_scale          = str2double(get_information(locations.horizontal_scale));
        waveform.information.vertical_position_unknown = get_information(locations.vertical_offset_unknown);
        waveform.information.horizontal_delay_unknown  = get_information(locations.horizontal_delay_unknown);
    end
    function [out] = get_information(location)
        out = data(location.start:location.start+location.length);
    end

    function clean_strings
        waveform.information.waveform_identifier    = regexprep(waveform.information.waveform_identifier,'"','');
        waveform.information.horizontal_unit        = regexprep(waveform.information.horizontal_unit,'"','');
        waveform.information.vertical_unit          = regexprep(waveform.information.vertical_unit,'"','');
    end
    function clean_information_struct
        %% Removing feilds containing information needed by the end user
        waveform.information = rmfield(waveform.information,'byte_order');
        waveform.information = rmfield(waveform.information,'bits_per_point');
        waveform.information = rmfield(waveform.information,'encoding');
        waveform.information = rmfield(waveform.information,'binary_format');
        waveform.information = rmfield(waveform.information,'point_format');
        waveform.information = rmfield(waveform.information,'horizontal_zero');
        waveform.information = rmfield(waveform.information,'trigger_point_offset');
        waveform.information = rmfield(waveform.information,'vertical_offset');
        waveform.information = rmfield(waveform.information,'vertical_zero');
        waveform.information = rmfield(waveform.information,'vertical_scale');
        waveform.information = rmfield(waveform.information,'horizontal_scale');
        waveform.information = rmfield(waveform.information,'vertical_position_unknown');
        waveform.information = rmfield(waveform.information,'horizontal_delay_unknown');
        
        %% Changing field name to match horizontal feilds
        waveform.information.vertical_interval = waveform.information.vertical_scale_factor;
        waveform.information = rmfield(waveform.information,'vertical_scale_factor');
        
    end

end
function waveform = ImportScopeTekWFM(filename)

%% Initialising Locations & Waveform Variables and opening the binary file.
fid = fopen(filename,'r'); % Opening the file that has been selected

%% Creating waveform and locations structs
waveform = struct(); %Building the waveform struct
locations = struct(); % building the locations struct, this is used for working out where to read the data in the file, locations found by Liam on 4054 isf file, could vary scope to scope as no specific format for tek scopes.

%% Determining the byte orde (LE or BE) then closing and reopening the file with the appropriate format.

byte_order = fread(fid,1,'ushort'); %reading the byte order
fclose(fid);

if byte_order==61680 %equivalent to hexidecimal 0xF0F0, which is big endian
    fid = fopen(filename,'r','ieee-be'); %reopening file with big endian format
elseif byte_order == 3855 %equivalent to hexidecimal 0x0F0F, which is little endian
    fid = fopen(filename,'r','ieee-le'); %reopening file with litee endian format
else
    waveform = NaN;
    return
end

clearvars filename byte_order ans

%% Importing the Waveform static file information and the Waveform header

get_Waveform_static_file_information_locations
get_Waveform_static_file_information

get_Waveform_Header_locations
get_Waveform_Header
decipher_Waveform_Header_enums

%% Checking file before importing the curve object
% Making sure there are no FastFrame objects, if so I need to carefully
% check the file.
if waveform.Waveform_static_file_information.N_number_of_FastFrames_minus_one ~= 0
    disp('Waveform not processed correctly, contact Liam and keep the .wfm file to supply for testing')
    waveform = NaN;
    return
end

% Making sure the file is of the 3rd Revision format (the 7254 uses this
% format, if not then the locations ALL change becuase Tektronix are not
% very sensible.
if ~strcmp(waveform.Waveform_static_file_information.Version_number,'WFM#003')
    disp('Waveform not processed correctly, contact Liam and keep the .wfm file to supply for testing')
    waveform = NaN;
    return
end

% Making sure there is only 1 curve recorded, if not then i need to check
% the file.
if waveform.Waveform_header.Reference_file_data.Curve_ref_count ~= 1
    disp('Waveform not processed correctly, contact Liam and keep the .wfm file to supply for testing')
    waveform = NaN;
    return
end

%% Importing the FastFrame Frames, CurveBuffer & Checksum

get_FastFrame_Frames_locations
get_FastFrame_Frames

get_CurveBuffer_locations
get_CurveBuffer

%% More checking of the file
% Checking to ensure there are no FastFrame objects.
if locations.fast_frame_frames.N_WfmUpdateSpec_object ~= locations.CurveBuffer.Curve_buffer || locations.fast_frame_frames.N_WfmCurveSpec_objects ~= locations.CurveBuffer.Curve_buffer
    disp('Waveform not processed correctly, contact Liam and keep the .wfm file to supply for testing')
    waveform = NaN;
    return
end

%% Importing the WfmFileChecksum

get_WfmFileChecksum_locations
get_WfmFileChecksum

%% Nested functions to make the script simpler to read.

    function get_Waveform_static_file_information_locations
        %location ref                                                                          location  format              length in bytes
        locations.Waveform_static_file_information.Byte_order_verification                   = 0;        %unsigned short     2
        locations.Waveform_static_file_information.Version_number                            = 3;        %char               8
        locations.Waveform_static_file_information.Number_of_digits_in_byte_count            = 10;       %char               1
        locations.Waveform_static_file_information.Number_of_bytes_to_the_end_of_file        = 11;       %longint            4
        locations.Waveform_static_file_information.Number_of_bytes_per_point                 = 15;       %char               1
        locations.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer  = 16;       %long int           4 
        locations.Waveform_static_file_information.Waveform_label                            = 40;       %char               32
        locations.Waveform_static_file_information.N_number_of_FastFrames_minus_one          = 72;       %unsigned long      4
        locations.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes      = 76;       %unsigned short     2
    end
    function get_Waveform_static_file_information
        waveform.Waveform_static_file_information.Byte_order_verification                   = ReadUShort(fid,locations.Waveform_static_file_information.Byte_order_verification);                           %unsigned short     2
        waveform.Waveform_static_file_information.Version_number                            = ReadChar(fid,  locations.Waveform_static_file_information.Version_number,7);                                  %char               8
        waveform.Waveform_static_file_information.Number_of_digits_in_byte_count            = ReadChar(fid,  locations.Waveform_static_file_information.Number_of_digits_in_byte_count,1,'DoNotConvert');   %char               1
        waveform.Waveform_static_file_information.Number_of_bytes_to_the_end_of_file        = 15 + ReadLong(fid,  locations.Waveform_static_file_information.Number_of_bytes_to_the_end_of_file);                %longint            4
        waveform.Waveform_static_file_information.Number_of_bytes_per_point                 = ReadChar(fid,  locations.Waveform_static_file_information.Number_of_bytes_per_point,1,'DoNotConvert');        %char               1
        waveform.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer  = ReadLong(fid,  locations.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer);          %long int           4 
        waveform.Waveform_static_file_information.Waveform_label                            = ReadChar(fid,  locations.Waveform_static_file_information.Waveform_label,32);                                 %char               32
        waveform.Waveform_static_file_information.N_number_of_FastFrames_minus_one          = ReadULong(fid, locations.Waveform_static_file_information.N_number_of_FastFrames_minus_one);                  %unsigned long      4
        waveform.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes      = ReadUShort(fid,locations.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes);              %unsigned short     2
    end

    function get_Waveform_Header_locations
        %location ref                                                                             location  format              length in bytes
        locations.Waveform_header.Reference_file_data.SetType                                   = 78;       %enum (int)         4
        locations.Waveform_header.Reference_file_data.WfmCnt                                    = 82;       %unsigned long      4
        locations.Waveform_header.Reference_file_data.Wfm_update_specification_count            = 110;      %unsigned long      4
        locations.Waveform_header.Reference_file_data.Imp_dim_ref_count                         = 114;      %unsigned long      4
        locations.Waveform_header.Reference_file_data.Exp_dim_ref_count                         = 118;      %unsigned long      4
        locations.Waveform_header.Reference_file_data.Data_type                                 = 122;      %enum (int)         4
        locations.Waveform_header.Reference_file_data.Curve_ref_count                           = 142;      %unsigned long      4
        locations.Waveform_header.Reference_file_data.Number_of_requested_fast_frames           = 146;      %unsigned long      4
        locations.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames             = 150;      %unsigned long      4
        locations.Waveform_header.Reference_file_data.Summary_frame_type                        = 154;      %unsigned short     2
        locations.Waveform_header.Reference_file_data.Pix_map_display_format                    = 156;      %enum (int)         4
        locations.Waveform_header.Reference_file_data.Pix_map_max_value                         = 160;      %unsigned long long 8

        
        locations.Waveform_header.Explicit_Dimension_1.Dim_scale                                = 168;      %double             8
        locations.Waveform_header.Explicit_Dimension_1.Dim_offset                               = 176;      %double             8
        locations.Waveform_header.Explicit_Dimension_1.Dim_size                                 = 184;      %unsigned long      4
        locations.Waveform_header.Explicit_Dimension_1.Units                                    = 188;      %char               20
        locations.Waveform_header.Explicit_Dimension_1.Dim_extent_min                           = 208;      %double             8
        locations.Waveform_header.Explicit_Dimension_1.Dim_extent_max                           = 216;      %double             8
        locations.Waveform_header.Explicit_Dimension_1.Dim_resolution                           = 224;      %double             8
        locations.Waveform_header.Explicit_Dimension_1.Dim_ref_point                            = 232;      %double             8
        locations.Waveform_header.Explicit_Dimension_1.Format                                   = 240;      %enum(int)          4
        locations.Waveform_header.Explicit_Dimension_1.Storage_type                             = 244;      %enum(int)          4
        locations.Waveform_header.Explicit_Dimension_1.N_value                                  = 248;      %4byte              4
        locations.Waveform_header.Explicit_Dimension_1.Over_range                               = 252;      %4byte              4
        locations.Waveform_header.Explicit_Dimension_1.Under_range                              = 256;      %4byte              4
        locations.Waveform_header.Explicit_Dimension_1.High_range                               = 260;      %4byte              4
        locations.Waveform_header.Explicit_Dimension_1.Row_range                                = 264;      %4byte              4
        locations.Waveform_header.Explicit_Dimension_1.User_scale                               = 268;      %double             8
        locations.Waveform_header.Explicit_Dimension_1.User_units                               = 276;      %char               20
        locations.Waveform_header.Explicit_Dimension_1.User_offset                              = 296;      %double             8
        locations.Waveform_header.Explicit_Dimension_1.Point_density                            = 304;      %double             8
        locations.Waveform_header.Explicit_Dimension_1.HRef_in_percent                          = 312;      %double             8
        locations.Waveform_header.Explicit_Dimension_1.TrigDelay_in_seconds                     = 320;      %double             8
                
        locations.Waveform_header.Explicit_Dimension_2.Dim_scale                                = 328;      %double             8
        locations.Waveform_header.Explicit_Dimension_2.Dim_offset                               = 336;      %double             8
        locations.Waveform_header.Explicit_Dimension_2.Dim_size                                 = 344;      %unsigned long      4
        locations.Waveform_header.Explicit_Dimension_2.Units                                    = 348;      %char               20
        locations.Waveform_header.Explicit_Dimension_2.Dim_extent_min                           = 368;      %double             8
        locations.Waveform_header.Explicit_Dimension_2.Dim_extent_max                           = 376;      %double             8
        locations.Waveform_header.Explicit_Dimension_2.Dim_resolution                           = 384;      %double             8
        locations.Waveform_header.Explicit_Dimension_2.Dim_ref_point                            = 392;      %double             8
        locations.Waveform_header.Explicit_Dimension_2.Format                                   = 400;      %enum(int)          4
        locations.Waveform_header.Explicit_Dimension_2.Storage_type                             = 404;      %enum(int)          4
        locations.Waveform_header.Explicit_Dimension_2.N_value                                  = 408;      %4byte              4
        locations.Waveform_header.Explicit_Dimension_2.Over_range                               = 412;      %4byte              4
        locations.Waveform_header.Explicit_Dimension_2.Under_range                              = 416;      %4byte              4
        locations.Waveform_header.Explicit_Dimension_2.High_range                               = 420;      %4byte              4
        locations.Waveform_header.Explicit_Dimension_2.Low_range                                = 424;      %4byte              4
        locations.Waveform_header.Explicit_Dimension_2.User_scale                               = 428;      %double             8
        locations.Waveform_header.Explicit_Dimension_2.User_units                               = 436;      %char               20
        locations.Waveform_header.Explicit_Dimension_2.User_offset                              = 456;      %double             8
        locations.Waveform_header.Explicit_Dimension_2.Point_density                            = 464;      %double             8
        locations.Waveform_header.Explicit_Dimension_2.HRef_in_percent                          = 472;      %double             8
        locations.Waveform_header.Explicit_Dimension_2.TrigDelay_in_seconds                     = 480;      %double             8
        
        locations.Waveform_header.Implicit_Dimension_1.Dim_scale                                = 488;      %double             8
        locations.Waveform_header.Implicit_Dimension_1.Dim_offset                               = 496;      %double             8
        locations.Waveform_header.Implicit_Dimension_1.Dim_size                                 = 504;      %unsigned long      4
        locations.Waveform_header.Implicit_Dimension_1.Units                                    = 508;      %char               20
        locations.Waveform_header.Implicit_Dimension_1.Dim_extent_min                           = 528;      %double             8
        locations.Waveform_header.Implicit_Dimension_1.Dim_extent_max                           = 536;      %double             8
        locations.Waveform_header.Implicit_Dimension_1.Dim_resolution                           = 544;      %double             8
        locations.Waveform_header.Implicit_Dimension_1.Dim_ref_point                            = 552;      %double             8
        locations.Waveform_header.Implicit_Dimension_1.Spacing                                  = 560;      %enum(int)          4
        locations.Waveform_header.Implicit_Dimension_1.User_scale                               = 564;      %double             8
        locations.Waveform_header.Implicit_Dimension_1.User_units                               = 572;      %char               20
        locations.Waveform_header.Implicit_Dimension_1.User_offset                              = 592;      %double             8
        locations.Waveform_header.Implicit_Dimension_1.Point_density                            = 600;      %double             8
        locations.Waveform_header.Implicit_Dimension_1.HRef_in_percent                          = 608;      %double             8
        locations.Waveform_header.Implicit_Dimension_1.TrigDelay_in_seconds                     = 616;      %double             8
        
        locations.Waveform_header.Implicit_Dimension_2.Dim_scale                                = 624;      %double             8
        locations.Waveform_header.Implicit_Dimension_2.Dim_offset                               = 632;      %double             8
        locations.Waveform_header.Implicit_Dimension_2.Dim_size                                 = 640;      %unsigned long      4
        locations.Waveform_header.Implicit_Dimension_2.Units                                    = 644;      %char               20
        locations.Waveform_header.Implicit_Dimension_2.Dim_extent_min                           = 664;      %double             8
        locations.Waveform_header.Implicit_Dimension_2.Dim_extent_max                           = 672;      %double             8
        locations.Waveform_header.Implicit_Dimension_2.Dim_resolution                           = 680;      %double             8
        locations.Waveform_header.Implicit_Dimension_2.Dim_ref_point                            = 688;      %double             8
        locations.Waveform_header.Implicit_Dimension_2.Spacing                                  = 696;      %enum(int)          4
        locations.Waveform_header.Implicit_Dimension_2.User_scale                               = 700;      %double             8
        locations.Waveform_header.Implicit_Dimension_2.User_units                               = 708;      %char               20
        locations.Waveform_header.Implicit_Dimension_2.User_offset                              = 728;      %double             8
        locations.Waveform_header.Implicit_Dimension_2.Point_density                            = 736;      %double             8
        locations.Waveform_header.Implicit_Dimension_2.HRef_in_percent                          = 744;      %double             8
        locations.Waveform_header.Implicit_Dimension_2.TrigDelay_in_seconds                     = 752;      %double             8
        
        locations.Waveform_header.TimeBase_Info1.Real_point_spacing                             = 760;      %unsigned long      4
        locations.Waveform_header.TimeBase_Info1.Sweep                                          = 764;      %enum(int)          4
        locations.Waveform_header.TimeBase_Info1.Type_of_base                                   = 768;      %enum(int)          4

        locations.Waveform_header.TimeBase_Info2.Real_point_spacing                             = 772;      %unsigned long      4
        locations.Waveform_header.TimeBase_Info2.Sweep                                          = 776;      %enum(int)          4
        locations.Waveform_header.TimeBase_Info2.Type_of_base                                   = 780;      %enum(int)          4
        
        locations.Waveform_header.WfmUpdateSpec.Real_point_offset                               = 784;      %unsigned long      4
        locations.Waveform_header.WfmUpdateSpec.TT_offset                                       = 788;      %double             8
        locations.Waveform_header.WfmUpdateSpec.Frac_sec                                        = 796;      %double             8
        locations.Waveform_header.WfmUpdateSpec.Gmt_sec                                         = 804;      %long               4
        
        locations.Waveform_header.WfmCurveObject.State_flags                                    = 808;      %unsigned long      4
        locations.Waveform_header.WfmCurveObject.Type_of_check_sum                              = 812;      %enum(int)          4
        locations.Waveform_header.WfmCurveObject.Check_sum                                      = 816;      %short              2
        locations.Waveform_header.WfmCurveObject.Precharge_start_offset                         = 818;      %unsigned long      4
        locations.Waveform_header.WfmCurveObject.Data_start_offset                              = 822;      %unsigned long      4
        locations.Waveform_header.WfmCurveObject.Postcharge_start_offset                        = 826;      %unsigned long      4
        locations.Waveform_header.WfmCurveObject.Postcharge_stop_offset                         = 830;      %unsigned long      4
        locations.Waveform_header.WfmCurveObject.End_of_curve_buffer                            = 834;      %unsigned long      4
            
    end
    function get_Waveform_Header
        %% Importing Reference file data
        waveform.Waveform_header.Reference_file_data.SetType                         = ReadEnumTek(fid,  locations.Waveform_header.Reference_file_data.SetType);                                %enum (int)         4
        waveform.Waveform_header.Reference_file_data.WfmCnt                          = ReadULong(fid, locations.Waveform_header.Reference_file_data.WfmCnt);                                 %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Wfm_update_specification_count  = ReadULong(fid, locations.Waveform_header.Reference_file_data.Wfm_update_specification_count);         %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Imp_dim_ref_count               = ReadULong(fid, locations.Waveform_header.Reference_file_data.Imp_dim_ref_count);                 %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Exp_dim_ref_count               = ReadULong(fid, locations.Waveform_header.Reference_file_data.Exp_dim_ref_count);                 %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Data_type                       = ReadEnumTek(fid,  locations.Waveform_header.Reference_file_data.Data_type);                              %enum (int)         4
        waveform.Waveform_header.Reference_file_data.Curve_ref_count                 = ReadULong(fid, locations.Waveform_header.Reference_file_data.Curve_ref_count);                        %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Number_of_requested_fast_frames = ReadULong(fid, locations.Waveform_header.Reference_file_data.Number_of_requested_fast_frames);            %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames   = ReadULong(fid, locations.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames);              %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Summary_frame_type              = ReadUShort(fid,locations.Waveform_header.Reference_file_data.Summary_frame_type);                     %unsigned short     2
        waveform.Waveform_header.Reference_file_data.Pix_map_display_format          = ReadEnumTek(fid,  locations.Waveform_header.Reference_file_data.Pix_map_display_format);                 %enum (int)         4
        waveform.Waveform_header.Reference_file_data.Pix_map_max_value               = ReadULong(fid, locations.Waveform_header.Reference_file_data.Pix_map_max_value);                      %unsigned long long 8
        
        %% Importing explicit dimension information
        if waveform.Waveform_header.Reference_file_data.Exp_dim_ref_count > 0
            waveform.Waveform_header.Explicit_Dimension_1.Dim_scale                 = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_1.Dim_scale);                                  %double             8
            waveform.Waveform_header.Explicit_Dimension_1.Dim_offset                = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_1.Dim_offset);                                 %double             8
            waveform.Waveform_header.Explicit_Dimension_1.Dim_size                  = ReadULong(fid, locations.Waveform_header.Explicit_Dimension_1.Dim_size);                                   %unsigned long      4
            waveform.Waveform_header.Explicit_Dimension_1.Units                     = ReadChar(fid,  locations.Waveform_header.Explicit_Dimension_1.Units,20);                                   %char               20
            waveform.Waveform_header.Explicit_Dimension_1.Dim_extent_min            = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_1.Dim_extent_min);                             %double             8
            waveform.Waveform_header.Explicit_Dimension_1.Dim_extent_max            = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_1.Dim_extent_max);                             %double             8
            waveform.Waveform_header.Explicit_Dimension_1.Dim_resolution            = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_1.Dim_resolution);                             %double             8
            waveform.Waveform_header.Explicit_Dimension_1.Dim_ref_point             = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_1.Dim_ref_point);                              %double             8
            waveform.Waveform_header.Explicit_Dimension_1.Format                    = ReadEnumTek(fid,  locations.Waveform_header.Explicit_Dimension_1.Format);                                     %enum(int)          4
            waveform.Waveform_header.Explicit_Dimension_1.Storage_type              = ReadEnumTek(fid,  locations.Waveform_header.Explicit_Dimension_1.Storage_type);                               %enum(int)          4
    %         waveform.Waveform_header.Explicit_Dimension_1.n_value                                  = 246;      %4byte              4
    %         waveform.Waveform_header.Explicit_Dimension_1.over_range                               = 250;      %4byte              4
    %         waveform.Waveform_header.Explicit_Dimension_1.under_range                              = 254;      %4byte              4
    %         waveform.Waveform_header.Explicit_Dimension_1.high_range                               = 258;      %4byte              4
    %         waveform.Waveform_header.Explicit_Dimension_1.low_range                                = 262;      %4byte              4
            waveform.Waveform_header.Explicit_Dimension_1.User_scale                = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_1.User_scale);                                 %double             8
            waveform.Waveform_header.Explicit_Dimension_1.User_units                = ReadChar(fid,  locations.Waveform_header.Explicit_Dimension_1.User_units,20);                              %char               20
            waveform.Waveform_header.Explicit_Dimension_1.User_offset               = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_1.User_offset);                                %double             8
            waveform.Waveform_header.Explicit_Dimension_1.Point_density             = ReadULong(fid, locations.Waveform_header.Explicit_Dimension_1.Point_density);                              %unsigned long      4
            waveform.Waveform_header.Explicit_Dimension_1.HRef_in_percent           = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_1.HRef_in_percent);                            %double             8
            waveform.Waveform_header.Explicit_Dimension_1.TrigDelay_in_seconds      = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_1.TrigDelay_in_seconds);                       %double             8
        end
        if waveform.Waveform_header.Reference_file_data.Exp_dim_ref_count > 1
            waveform.Waveform_header.Explicit_Dimension_2.Dim_scale                 = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_2.Dim_scale);                                  %double             8
            waveform.Waveform_header.Explicit_Dimension_2.Dim_offset                = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_2.Dim_offset);                                 %double             8
            waveform.Waveform_header.Explicit_Dimension_2.Dim_size                  = ReadULong(fid, locations.Waveform_header.Explicit_Dimension_2.Dim_size);                                   %unsigned long      4
            waveform.Waveform_header.Explicit_Dimension_2.Units                     = ReadChar(fid,  locations.Waveform_header.Explicit_Dimension_2.Units,20);                                   %char               20
            waveform.Waveform_header.Explicit_Dimension_2.Dim_extent_min            = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_2.Dim_extent_min);                             %double             8
            waveform.Waveform_header.Explicit_Dimension_2.Dim_extent_max            = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_2.Dim_extent_max);                             %double             8
            waveform.Waveform_header.Explicit_Dimension_2.Dim_resolution            = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_2.Dim_resolution);                             %double             8
            waveform.Waveform_header.Explicit_Dimension_2.Dim_ref_point             = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_2.Dim_ref_point);                              %double             8
            waveform.Waveform_header.Explicit_Dimension_2.Format                    = ReadEnumTek(fid,  locations.Waveform_header.Explicit_Dimension_2.Format);                                     %enum(int)          4
            waveform.Waveform_header.Explicit_Dimension_2.Storage_type              = ReadEnumTek(fid,  locations.Waveform_header.Explicit_Dimension_2.Storage_type);                               %enum(int)          4
    %         waveform.Waveform_header.Explicit_Dimension_2.n_value                                  = 402;      %4byte              4
    %         waveform.Waveform_header.Explicit_Dimension_2.over_range                               = 406;      %4byte              4
    %         waveform.Waveform_header.Explicit_Dimension_2.under_range                              = 410;      %4byte              4
    %         waveform.Waveform_header.Explicit_Dimension_2.high_range                               = 414;      %4byte              4
    %         waveform.Waveform_header.Explicit_Dimension_2.low_range                                = 418;      %4byte              4
            waveform.Waveform_header.Explicit_Dimension_2.User_scale                = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_2.User_scale);                                 %double             8
            waveform.Waveform_header.Explicit_Dimension_2.User_units                = ReadChar(  fid,locations.Waveform_header.Explicit_Dimension_2.User_units,20);                              %char               20
            waveform.Waveform_header.Explicit_Dimension_2.User_offset               = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_2.User_offset);                                %double             8
            waveform.Waveform_header.Explicit_Dimension_2.Point_density             = ReadULong( fid,locations.Waveform_header.Explicit_Dimension_2.Point_density);                              %unsigned long      4
            waveform.Waveform_header.Explicit_Dimension_2.HRef_in_percent           = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_2.HRef_in_percent);                            %double             8
            waveform.Waveform_header.Explicit_Dimension_2.TrigDelay_in_seconds      = ReadDouble(fid,locations.Waveform_header.Explicit_Dimension_2.TrigDelay_in_seconds);                       %double             8
        end
        
        %% Importing implicit dimension information
        if waveform.Waveform_header.Reference_file_data.Imp_dim_ref_count > 0
            waveform.Waveform_header.Implicit_Dimension_1.Dim_scale                 = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_1.Dim_scale);                                  %double             8
            waveform.Waveform_header.Implicit_Dimension_1.Dim_offset                = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_1.Dim_offset);                                 %double             8
            waveform.Waveform_header.Implicit_Dimension_1.Dim_size                  = ReadULong( fid,locations.Waveform_header.Implicit_Dimension_1.Dim_size);                                   %unsigned long      4
            waveform.Waveform_header.Implicit_Dimension_1.Units                     = ReadChar(  fid,locations.Waveform_header.Implicit_Dimension_1.Units,20);                                   %char               20
            waveform.Waveform_header.Implicit_Dimension_1.Dim_extent_min            = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_1.Dim_extent_min);                             %double             8
            waveform.Waveform_header.Implicit_Dimension_1.Dim_extent_max            = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_1.Dim_extent_max);                             %double             8
            waveform.Waveform_header.Implicit_Dimension_1.Dim_resolution            = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_1.Dim_resolution);                             %double             8
            waveform.Waveform_header.Implicit_Dimension_1.Dim_ref_point             = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_1.Dim_ref_point);                              %double             8
            waveform.Waveform_header.Implicit_Dimension_1.Spacing                   = ReadEnumTek(  fid,locations.Waveform_header.Implicit_Dimension_1.Spacing);                                    %enum(int)          4
            waveform.Waveform_header.Implicit_Dimension_1.User_scale                = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_1.User_scale);                                 %double             8
            waveform.Waveform_header.Implicit_Dimension_1.User_units                = ReadChar(  fid,locations.Waveform_header.Implicit_Dimension_1.User_units,20);                              %char               20
            waveform.Waveform_header.Implicit_Dimension_1.User_offset               = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_1.User_offset);                                %double             8
            waveform.Waveform_header.Implicit_Dimension_1.Point_density             = ReadULong( fid,locations.Waveform_header.Implicit_Dimension_1.Point_density);                              %unsigned long      4
            waveform.Waveform_header.Implicit_Dimension_1.HRef_in_percent           = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_1.HRef_in_percent);                            %double             8
            waveform.Waveform_header.Implicit_Dimension_1.TrigDelay_in_seconds      = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_1.TrigDelay_in_seconds);                       %double             8
        end
        if waveform.Waveform_header.Reference_file_data.Imp_dim_ref_count > 1
            waveform.Waveform_header.Implicit_Dimension_2.Dim_scale                 = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_2.Dim_scale);                                  %double             8
            waveform.Waveform_header.Implicit_Dimension_2.Dim_offset                = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_2.Dim_offset);                                 %double             8
            waveform.Waveform_header.Implicit_Dimension_2.Dim_size                  = ReadULong( fid,locations.Waveform_header.Implicit_Dimension_2.Dim_size);                                   %unsigned long      4
            waveform.Waveform_header.Implicit_Dimension_2.Units                     = ReadChar(  fid,locations.Waveform_header.Implicit_Dimension_2.Units,20);                                   %char               20
            waveform.Waveform_header.Implicit_Dimension_2.Dim_extent_min            = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_2.Dim_extent_min);                             %double             8
            waveform.Waveform_header.Implicit_Dimension_2.Dim_extent_max            = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_2.Dim_extent_max);                             %double             8
            waveform.Waveform_header.Implicit_Dimension_2.Dim_resolution            = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_2.Dim_resolution);                             %double             8
            waveform.Waveform_header.Implicit_Dimension_2.Dim_ref_point             = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_2.Dim_ref_point);                              %double             8
            waveform.Waveform_header.Implicit_Dimension_2.Spacing                   = ReadEnumTek(  fid,locations.Waveform_header.Implicit_Dimension_2.Spacing);                                    %enum(int)          4
            waveform.Waveform_header.Implicit_Dimension_2.User_scale                = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_2.User_scale);                                 %double             8
            waveform.Waveform_header.Implicit_Dimension_2.User_units                = ReadChar(  fid,locations.Waveform_header.Implicit_Dimension_2.User_units,20);                              %char               20
            waveform.Waveform_header.Implicit_Dimension_2.User_offset               = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_2.User_offset);                                %double             8
            waveform.Waveform_header.Implicit_Dimension_2.Point_density             = ReadULong( fid,locations.Waveform_header.Implicit_Dimension_2.Point_density);                              %unsigned long      4
            waveform.Waveform_header.Implicit_Dimension_2.HRef_in_percent           = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_2.HRef_in_percent);                            %double             8
            waveform.Waveform_header.Implicit_Dimension_2.TrigDelay_in_seconds      = ReadDouble(fid,locations.Waveform_header.Implicit_Dimension_2.TrigDelay_in_seconds);                       %double             8
        end
        
        %% Importing TimeBase Information
        if waveform.Waveform_header.Reference_file_data.Curve_ref_count > 0
            waveform.Waveform_header.TimeBase_Info1.Real_point_spacing              = ReadULong(fid,locations.Waveform_header.TimeBase_Info1.Real_point_spacing);                                %unsigned long      4
            waveform.Waveform_header.TimeBase_Info1.Sweep                           = ReadEnumTek( fid,locations.Waveform_header.TimeBase_Info1.Sweep);                                             %enum(int)          4
            waveform.Waveform_header.TimeBase_Info1.Type_of_base                    = ReadEnumTek( fid,locations.Waveform_header.TimeBase_Info1.Type_of_base);                                      %enum(int)          4
        end
        if waveform.Waveform_header.Reference_file_data.Curve_ref_count > 1
            waveform.Waveform_header.TimeBase_Info2.Real_point_spacing              = ReadULong(fid,locations.Waveform_header.TimeBase_Info2.Real_point_spacing);                                %unsigned long      4
            waveform.Waveform_header.TimeBase_Info2.Sweep                           = ReadEnumTek( fid,locations.Waveform_header.TimeBase_Info2.Sweep);                                             %enum(int)          4
            waveform.Waveform_header.TimeBase_Info2.Type_of_base                    = ReadEnumTek( fid,locations.Waveform_header.TimeBase_Info2.Type_of_base);                                      %enum(int)          4
        end
        
        %% Importing Waveform Update Spec
        waveform.Waveform_header.WfmUpdateSpec.Real_point_offset                = ReadULong( fid,locations.Waveform_header.WfmUpdateSpec.Real_point_offset);                                %unsigned long      4
        waveform.Waveform_header.WfmUpdateSpec.TT_offset                        = ReadDouble(fid,locations.Waveform_header.WfmUpdateSpec.TT_offset);                                         %double             8
        waveform.Waveform_header.WfmUpdateSpec.Frac_sec                         = ReadDouble(fid,locations.Waveform_header.WfmUpdateSpec.Frac_sec);                                          %double             8
        waveform.Waveform_header.WfmUpdateSpec.Gmt_sec                          = ReadLong(  fid,locations.Waveform_header.WfmUpdateSpec.Gmt_sec);                                           %long               4
        
        %% Importing Waveform Curve Objects
        waveform.Waveform_header.WfmCurveObject.State_flags                     = ReadULong(fid,locations.Waveform_header.WfmCurveObject.State_flags);                                       %unsigned long      4
        waveform.Waveform_header.WfmCurveObject.Type_of_check_sum               = ReadEnumTek( fid,locations.Waveform_header.WfmCurveObject.Type_of_check_sum);                                 %enum(int)          4
        waveform.Waveform_header.WfmCurveObject.Check_sum                       = ReadShort(fid,locations.Waveform_header.WfmCurveObject.Check_sum);                                         %short              2
        waveform.Waveform_header.WfmCurveObject.Precharge_start_offset          = ReadULong(fid,locations.Waveform_header.WfmCurveObject.Precharge_start_offset);                            %unsigned long      4
        waveform.Waveform_header.WfmCurveObject.Data_start_offset               = ReadULong(fid,locations.Waveform_header.WfmCurveObject.Data_start_offset);                                 %unsigned long      4
        waveform.Waveform_header.WfmCurveObject.Postcharge_start_offset         = ReadULong(fid,locations.Waveform_header.WfmCurveObject.Postcharge_start_offset);                           %unsigned long      4
        waveform.Waveform_header.WfmCurveObject.Postcharge_stop_offset          = ReadULong(fid,locations.Waveform_header.WfmCurveObject.Postcharge_stop_offset);                            %unsigned long      4
        waveform.Waveform_header.WfmCurveObject.End_of_curve_buffer             = ReadULong(fid,locations.Waveform_header.WfmCurveObject.End_of_curve_buffer);                               %unsigned long      4
    
    end
    function decipher_Waveform_Header_enums
        %% Deciphering Enums in Reference_file_data
        if waveform.Waveform_header.Reference_file_data.SetType == 0
            waveform.Waveform_header.Reference_file_data.SetType = 'Single Waveform Set';
        elseif waveform.Waveform_header.Reference_file_data.SetType == 1
            waveform.Waveform_header.Reference_file_data.SetType = 'FastFrame Set';
            disp('This waveform contains FastFrame data, it will not have imported correctly, save as .dat and give the .wfm to Liam')
            waveform = Nan;
            return
        else
            disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
            waveform = Nan;
            return
        end
        if waveform.Waveform_header.Reference_file_data.Data_type == 0
            waveform.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_SCALAR_MEAS';
        elseif waveform.Waveform_header.Reference_file_data.Data_type == 1
            waveform.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_SCALAR_CONST';
        elseif waveform.Waveform_header.Reference_file_data.Data_type == 2
            waveform.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_VECTOR';
        elseif waveform.Waveform_header.Reference_file_data.Data_type == 4
            waveform.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_INVALID';
        elseif waveform.Waveform_header.Reference_file_data.Data_type == 5
            waveform.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_WFMDB';
        elseif waveform.Waveform_header.Reference_file_data.Data_type == 6
            waveform.Waveform_header.Reference_file_data.Data_type = 'WFMDATA_DIGITAL';
        else
            disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
            waveform = Nan;
            return
        end
        if waveform.Waveform_header.Reference_file_data.Pix_map_display_format == 0
            waveform.Waveform_header.Reference_file_data.Pix_map_display_format = 'DSY_FORMAT_INVALID';
        elseif waveform.Waveform_header.Reference_file_data.Pix_map_display_format == 1
            waveform.Waveform_header.Reference_file_data.Pix_map_display_format = 'DSY_FORMAT_YT';
        elseif waveform.Waveform_header.Reference_file_data.Pix_map_display_format == 2
            waveform.Waveform_header.Reference_file_data.Pix_map_display_format = 'DSY_FORMAT_XY';
        elseif waveform.Waveform_header.Reference_file_data.Pix_map_display_format == 3
            waveform.Waveform_header.Reference_file_data.Pix_map_display_format = 'DSY_FORMAT_XYZ';
        else
            disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
            waveform = Nan;
            return
        end
        
        %% Deciphering enums in Explicit_Dimension section(s)
        if waveform.Waveform_header.Reference_file_data.Exp_dim_ref_count > 0
            if waveform.Waveform_header.Explicit_Dimension_1.Format == 0
                waveform.Waveform_header.Explicit_Dimension_1.Format = 'int16';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Format == 1
                waveform.Waveform_header.Explicit_Dimension_1.Format = 'int32';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Format == 2
                waveform.Waveform_header.Explicit_Dimension_1.Format = 'uint32';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Format == 3
                waveform.Waveform_header.Explicit_Dimension_1.Format = 'uint64';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Format == 4
                waveform.Waveform_header.Explicit_Dimension_1.Format = 'float32';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Format == 5
                waveform.Waveform_header.Explicit_Dimension_1.Format = 'float64';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Format == 6
                waveform.Waveform_header.Explicit_Dimension_1.Format = 'uint8';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Format == 7
                waveform.Waveform_header.Explicit_Dimension_1.Format = 'int8';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Format == 8
                waveform.Waveform_header.Explicit_Dimension_1.Format = 'EXP_INVALID_DATA_FORMAT';
            else
                disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
                waveform = Nan;
                return
            end
            if waveform.Waveform_header.Explicit_Dimension_1.Storage_type == 0
                waveform.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_SAMPLE';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Storage_type == 1
                waveform.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_MIN_MAX';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Storage_type == 2
                waveform.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_VERT_HIST';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Storage_type == 3
                waveform.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_HOR_HIST';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Storage_type == 4
                waveform.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_ROW_ORDER';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Storage_type == 5
                waveform.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_COLUMN_ORDER';
            elseif waveform.Waveform_header.Explicit_Dimension_1.Storage_type == 6
                waveform.Waveform_header.Explicit_Dimension_1.Storage_type = 'EXPLICIT_INVALID_STORAGE';
            else
                disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
                waveform = Nan;
                return
            end
        end
        if waveform.Waveform_header.Reference_file_data.Exp_dim_ref_count > 1
            if waveform.Waveform_header.Explicit_Dimension_2.Format == 0
                waveform.Waveform_header.Explicit_Dimension_2.Format = 'int16';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Format == 1
                waveform.Waveform_header.Explicit_Dimension_2.Format = 'int32';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Format == 2
                waveform.Waveform_header.Explicit_Dimension_2.Format = 'uint32';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Format == 3
                waveform.Waveform_header.Explicit_Dimension_2.Format = 'uint64';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Format == 4
                waveform.Waveform_header.Explicit_Dimension_2.Format = 'float32';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Format == 5
                waveform.Waveform_header.Explicit_Dimension_2.Format = 'float64';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Format == 6
                waveform.Waveform_header.Explicit_Dimension_2.Format = 'uint8';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Format == 7
                waveform.Waveform_header.Explicit_Dimension_2.Format = 'int8';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Format == 8
                waveform.Waveform_header.Explicit_Dimension_2.Format = 'EXP_INVALID_DATA_FORMAT';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Format == 9
                waveform.Waveform_header.Explicit_Dimension_2.Format = 'DIMENSION NOT IN USE';
            else
                disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
                waveform = Nan;
                return
            end
            if waveform.Waveform_header.Explicit_Dimension_2.Storage_type == 0
                waveform.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_SAMPLE';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Storage_type == 1
                waveform.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_MIN_MAX';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Storage_type == 2
                waveform.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_VERT_HIST';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Storage_type == 3
                waveform.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_HOR_HIST';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Storage_type == 4
                waveform.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_ROW_ORDER';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Storage_type == 5
                waveform.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_COLUMN_ORDER';
            elseif waveform.Waveform_header.Explicit_Dimension_2.Storage_type == 6
                waveform.Waveform_header.Explicit_Dimension_2.Storage_type = 'EXPLICIT_INVALID_STORAGE';
            else
                disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
                waveform = Nan;
                return
            end
        end
        
        %% Deciphering enums in TimeBase_Info secition(s)
        if waveform.Waveform_header.Reference_file_data.Curve_ref_count > 0
            if waveform.Waveform_header.TimeBase_Info1.Sweep == 0
                waveform.Waveform_header.TimeBase_Info1.Sweep = 'SWEEP_ROLL';
            elseif waveform.Waveform_header.TimeBase_Info1.Sweep == 1
                waveform.Waveform_header.TimeBase_Info1.Sweep = 'SWEEP_SAMPLE';
            elseif waveform.Waveform_header.TimeBase_Info1.Sweep == 2
                waveform.Waveform_header.TimeBase_Info1.Sweep = 'SWEEP_ET';
            elseif waveform.Waveform_header.TimeBase_Info1.Sweep == 3
                waveform.Waveform_header.TimeBase_Info1.Sweep = 'SWEEP_INVALID';
            else
                disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
                waveform = Nan;
                return
            end
            if waveform.Waveform_header.TimeBase_Info1.Type_of_base == 0
                waveform.Waveform_header.TimeBase_Info1.Type_of_base = 'BASE_TIME';
            elseif waveform.Waveform_header.TimeBase_Info1.Type_of_base == 1
                waveform.Waveform_header.TimeBase_Info1.Type_of_base = 'BASE_SPECTRAL_MAG';
            elseif waveform.Waveform_header.TimeBase_Info1.Type_of_base == 2
                waveform.Waveform_header.TimeBase_Info1.Type_of_base = 'BASE_SPRECTRAL_PHASE';
            elseif waveform.Waveform_header.TimeBase_Info1.Type_of_base == 3
                waveform.Waveform_header.TimeBase_Info1.Type_of_base = 'BASE_INVALID';
            else
                disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
                waveform = Nan;
                return
            end
        end
        if waveform.Waveform_header.Reference_file_data.Curve_ref_count > 1
            if waveform.Waveform_header.TimeBase_Info2.Sweep == 0
                waveform.Waveform_header.TimeBase_Info2.Sweep = 'SWEEP_ROLL';
            elseif waveform.Waveform_header.TimeBase_Info2.Sweep == 1
                waveform.Waveform_header.TimeBase_Info2.Sweep = 'SWEEP_SAMPLE';
            elseif waveform.Waveform_header.TimeBase_Info2.Sweep == 2
                waveform.Waveform_header.TimeBase_Info2.Sweep = 'SWEEP_ET';
            elseif waveform.Waveform_header.TimeBase_Info2.Sweep == 3
                waveform.Waveform_header.TimeBase_Info2.Sweep = 'SWEEP_INVALID';
            else
                disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
                waveform = Nan;
                return
            end
            if waveform.Waveform_header.TimeBase_Info2.Type_of_base == 0
                waveform.Waveform_header.TimeBase_Info2.Type_of_base = 'BASE_TIME';
            elseif waveform.Waveform_header.TimeBase_Info2.Type_of_base == 1
                waveform.Waveform_header.TimeBase_Info2.Type_of_base = 'BASE_SPECTRAL_MAG';
            elseif waveform.Waveform_header.TimeBase_Info2.Type_of_base == 2
                waveform.Waveform_header.TimeBase_Info2.Type_of_base = 'BASE_SPRECTRAL_PHASE';
            elseif waveform.Waveform_header.TimeBase_Info2.Type_of_base == 3
                waveform.Waveform_header.TimeBase_Info2.Type_of_base = 'BASE_INVALID';
            else
                disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
                waveform = Nan;
                return
            end
        end
        
        %% Deciphering enums in WfmCurveObject
        if waveform.Waveform_header.WfmCurveObject.Type_of_check_sum == 0
            waveform.Waveform_header.WfmCurveObject.Type_of_check_sum = 'NO_CHECKSUM';
        elseif waveform.Waveform_header.WfmCurveObject.Type_of_check_sum == 1
            waveform.Waveform_header.WfmCurveObject.Type_of_check_sum = 'CTYPE_CRC16';
        elseif waveform.Waveform_header.WfmCurveObject.Type_of_check_sum == 2
            waveform.Waveform_header.WfmCurveObject.Type_of_check_sum = 'CTYPE_SUM16';
        elseif waveform.Waveform_header.WfmCurveObject.Type_of_check_sum == 3
            waveform.Waveform_header.WfmCurveObject.Type_of_check_sum = 'CTYPE_CRC32';
        elseif waveform.Waveform_header.WfmCurveObject.Type_of_check_sum == 4
            waveform.Waveform_header.WfmCurveObject.Type_of_check_sum = 'CTYPE_SUM32';
        else
            disp('This waveform has not imported correctly, save as .dat and give the .wfm to Liam')
            waveform = Nan;
            return
        end   
        
    end

    function get_FastFrame_Frames_locations
        locations.fast_frame_frames.N_WfmUpdateSpec_object = 78 + waveform.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes;
        locations.fast_frame_frames.N_WfmCurveSpec_objects = 78 + waveform.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes + (24 * waveform.Waveform_static_file_information.N_number_of_FastFrames_minus_one);
    end
    function get_FastFrame_Frames
        %% This has not been written, however I don't have any FastFrame_Frames examples to write from, so will once i have the need.
    end

    function get_CurveBuffer_locations
        locations.CurveBuffer.Curve_buffer                       = waveform.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer;
    end
    function get_CurveBuffer 
        
        number_of_data_points = waveform.Waveform_header.Implicit_Dimension_1.Dim_size;
        if number_of_data_points ~= waveform.Waveform_header.WfmCurveObject.Postcharge_stop_offset / waveform.Waveform_static_file_information.Number_of_bytes_per_point
            disp('Error in format of waveform curve data, save alternate format and give Liam the .wfm')
        end
        data_point_format = waveform.Waveform_header.Explicit_Dimension_1.Format;
        waveform.CurveBuffer.Curve_buffer  = ReadDefinedFormat(fid,locations.CurveBuffer.Curve_buffer,number_of_data_points,data_point_format);
        clearvars number_of_data_points data_point_format
        
    end

    function get_WfmFileChecksum_locations
        locations.CurveBufferWfmFileChecksum.Waveform_file_checksum   = waveform.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer+waveform.Waveform_header.WfmCurveObject.End_of_curve_buffer; % Needs correcting as this assumes no user marks.
    end
    function get_WfmFileChecksum % WRITE ME
        frewind(fid)
        waveform.WfmFileChecksum.Waveform_file_checksum_calculated = sum(fread(fid,838+500032,'uchar'));
        waveform.WfmFileChecksum.Waveform_file_checksum = ReadULongLong(fid,locations.CurveBufferWfmFileChecksum.Waveform_file_checksum);
    end

if waveform.WfmFileChecksum.Waveform_file_checksum_calculated == waveform.WfmFileChecksum.Waveform_file_checksum
    %disp('Checksum matches, File imported correctly')
else
    disp('File Not imported correctly, record in different format and send .wfm to Liam')
end

%% Moving through to the end of the file (there seems to be a single blank byte which may be involved with the USER MARKS not being used but not sure.

blank_line_count = 0;
while ~feof(fid)
    blank_line_count = blank_line_count+1;
    fread(fid,1,'int8');
end

if blank_line_count == 1
    %disp('Single Blank byte at end of file, as expected')
else
    disp('More blank lines than expected, below is the number recorded')
    disp(blank_line_count)
end
clearvars blank_line_count

%% Creating Voltage & Time Series
if waveform.Waveform_header.Reference_file_data.Curve_ref_count == 1
    waveform.voltage    = (waveform.CurveBuffer.Curve_buffer * waveform.Waveform_header.Explicit_Dimension_1.Dim_scale)+waveform.Waveform_header.Explicit_Dimension_1.Dim_offset;
    waveform.time       = (((1:waveform.Waveform_header.Implicit_Dimension_1.Dim_size) * waveform.Waveform_header.Implicit_Dimension_1.Dim_scale) + waveform.Waveform_header.Implicit_Dimension_1.Dim_offset)';
else
    disp('Time and Voltage series for curve not generated correctly, record in different format and send .wfm to Liam')
end

%% Creating info struct containing extra information in understandable format

waveform.info.horizontal_resolution         = waveform.Waveform_header.Implicit_Dimension_1.Dim_scale;
waveform.info.vertical_resolution           = waveform.Waveform_header.Explicit_Dimension_1.Dim_scale;
waveform.info.horizontal_unit               = waveform.Waveform_header.Implicit_Dimension_1.Units;
waveform.info.vertical_unit                 = waveform.Waveform_header.Explicit_Dimension_1.Units;
waveform.info.no_of_points                  = waveform.Waveform_header.Implicit_Dimension_1.Dim_size;
waveform.info.time_of_aquisition            = datetime(waveform.Waveform_header.WfmUpdateSpec.Gmt_sec,'ConvertFrom','posixtime'); %Reckon scope clock wrong
waveform.info.version_number                = waveform.Waveform_static_file_information.Version_number;
waveform.info.no_of_bytes_per_data_point    = waveform.Waveform_static_file_information.Number_of_bytes_per_point;
waveform.info.waveform_label                = waveform.Waveform_static_file_information.Waveform_label;

waveform = rmfield(waveform,'Waveform_header');
waveform = rmfield(waveform,'WfmFileChecksum');
waveform = rmfield(waveform,'Waveform_static_file_information');
waveform = rmfield(waveform,'CurveBuffer');

clearvars locations

end
function waveform = ImportScopeLecroy(filename)
%% Initialising Variables and opening the binary file.
waveform = struct(); %Building the waveform struct

fid = fopen(filename,'r'); % Opening the file that has been selected

%% Finind the start location of the binary files, all lecroy binary files start with the characters WAVEDESC which is used as a reference location 

init_offset_search = fread(fid,50,'char')'; 
offset = strfind(init_offset_search,'WAVEDESC') - 1;
get_locations

%% Closing and reopening the file such that the byte order (HIFIRST or LOFIRST) is considered.
if logical(ReadEnumLecroy(fid,waveform.locations.COMM_ORDER))
    fclose(fid);
    fid=fopen(filename,'r','ieee-le');		% HIFIRST
else
    fclose(fid);
    fid=fopen(filename,'r','ieee-be');		% LOFIRST
end
clearvars filename init_offset_search COMM_ORDER ans

%% Reading information from the file, each 
get_waveform_info

waveform_raw = waveform; %Need info settings in raw format for a few bits, so copy struct in raw from before mapping Enums to their meaning.
decipher_enum

read_user_text
get_trigtime_array
get_ris_time_array
read_voltages
read_second_voltages
generate_time_series

%% Removing unneccessary information from the waveform struct before it is returned
waveform = rmfield(waveform,'locations');
fid = fclose(fid);
clearvars waveform_raw offset fid

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
        waveform.info.template_name           = ReadString(fid,waveform.locations.TEMPLATE_NAME);
        waveform.info.comm_type               = ReadEnumLecroy(fid,waveform.locations.COMM_TYPE);
        waveform.info.comm_order              = ReadEnumLecroy(fid,waveform.locations.COMM_ORDER);
        waveform.info.wave_descriptor         = ReadLong(fid,waveform.locations.WAVE_DESCRIPTOR);
        waveform.info.user_text               = ReadLong(fid,waveform.locations.USER_TEXT);
        waveform.info.res_desc1               = ReadLong(fid,waveform.locations.RES_DESC1);
        waveform.info.trigtime_array          = ReadLong(fid,waveform.locations.TRIGTIME_ARRAY);
        waveform.info.ris_time_array          = ReadLong(fid,waveform.locations.RIS_TIME_ARRAY);
        waveform.info.res_array               = ReadLong(fid,waveform.locations.RES_ARRAY);
        waveform.info.wave_array1             = ReadLong(fid,waveform.locations.WAVE_ARRAY_1);
        waveform.info.wave_array2             = ReadLong(fid,waveform.locations.WAVE_ARRAY_2);
        waveform.info.res_array2              = ReadLong(fid,waveform.locations.RES_ARRAY2);
        waveform.info.res_array3              = ReadLong(fid,waveform.locations.RES_ARRAY3);
        waveform.info.instrument_name         = ReadString(fid,waveform.locations.INSTRUMENT_NAME);
        waveform.info.instrument_number       = ReadLong(fid,waveform.locations.INSTRUMENT_NUMBER);
        waveform.info.trace_label             = ReadString(fid,waveform.locations.TRACE_LABEL);
        waveform.info.reserved1               = ReadWord(fid,waveform.locations.RESERVED1);
        waveform.info.reserved2               = ReadWord(fid,waveform.locations.RESERVED2);
        waveform.info.wave_array_count        = ReadLong(fid,waveform.locations.WAVE_ARRAY_COUNT);
        waveform.info.points_per_screen       = ReadLong(fid,waveform.locations.PNTS_PER_SCREEN);
        waveform.info.first_valid_point       = ReadLong(fid,waveform.locations.FIRST_VALID_PNT);
        waveform.info.last_valid_point        = ReadLong(fid,waveform.locations.LAST_VALID_PNT);
        waveform.info.first_point             = ReadLong(fid,waveform.locations.FIRST_POINT);
        waveform.info.sparsing_factor         = ReadLong(fid,waveform.locations.SPARSING_FACTOR);
        waveform.info.segment_index           = ReadLong(fid,waveform.locations.SEGMENT_INDEX);
        waveform.info.subarray_count          = ReadLong(fid,waveform.locations.SUBARRAY_COUNT);
        waveform.info.sweeps_per_aqg          = ReadLong(fid,waveform.locations.SWEEPS_PER_AQG);
        waveform.info.points_per_pair         = ReadWord(fid,waveform.locations.POINTS_PER_PAIR);
        waveform.info.pair_offset             = ReadWord(fid,waveform.locations.PAIR_OFFSET);
        waveform.info.vertical_gain           = ReadFloat(fid,waveform.locations.VERTICAL_GAIN);
        waveform.info.vertical_offset         = ReadFloat(fid,waveform.locations.VERTICAL_OFFSET);
        waveform.info.max_value               = ReadFloat(fid,waveform.locations.MAX_VALUE);
        waveform.info.min_value               = ReadFloat(fid,waveform.locations.MIN_VALUE);
        waveform.info.nominal_bits            = ReadWord(fid,waveform.locations.NOMINAL_BITS);
        waveform.info.nom_subarray_count      = ReadWord(fid,waveform.locations.NOM_SUBARRAY_COUNT);
        waveform.info.horizontal_interval     = ReadFloat(fid,waveform.locations.HORIZ_INTERVAL);
        waveform.info.horizontal_offset       = ReadDouble(fid,waveform.locations.HORIZ_OFFSET);
        waveform.info.pixel_offset            = ReadDouble(fid,waveform.locations.PIXEL_OFFSET);
        waveform.info.vertical_unit           = ReadUnitDefinition(fid,waveform.locations.VERTUNIT);
        waveform.info.horizontal_unit         = ReadUnitDefinition(fid,waveform.locations.HORUNIT);
        waveform.info.horizontal_uncertainty  = ReadFloat(fid,waveform.locations.HORIZ_UNCERTAINTY);
        waveform.info.trigger_time            = ReadTimestamp(fid,waveform.locations.TRIGGER_TIME);
        waveform.info.acq_duration            = ReadFloat(fid,waveform.locations.ACQ_DURATION);
        waveform.info.recording_type          = ReadEnumLecroy(fid,waveform.locations.RECORD_TYPE);
        waveform.info.processing_done         = ReadEnumLecroy(fid,waveform.locations.PROCESSING_DONE);
        waveform.info.reserved5               = ReadWord(fid,waveform.locations.RESERVED5);
        waveform.info.ris_sweeps              = ReadWord(fid,waveform.locations.RIS_SWEEPS);
        waveform.info.timebase                = ReadEnumLecroy(fid,waveform.locations.TIMEBASE);
        waveform.info.vertical_coupling       = ReadEnumLecroy(fid,waveform.locations.VERT_COUPLING);
        waveform.info.probe_attenuation       = ReadFloat(fid,waveform.locations.PROBE_ATT);
        waveform.info.fixed_vertical_gain     = ReadEnumLecroy(fid,waveform.locations.FIXED_VERT_GAIN);
        waveform.info.bandwidth_limit         = ReadEnumLecroy(fid,waveform.locations.BANDWIDTH_LIMIT);
        waveform.info.vertical_vernier        = ReadFloat(fid,waveform.locations.VERTICAL_VERNIER);
        waveform.info.acq_vertical_offset     = ReadFloat(fid,waveform.locations.ACQ_VERT_OFFSET);
        waveform.info.wave_source             = ReadEnumLecroy(fid,waveform.locations.WAVE_SOURCE);
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
            fseek(fid,offset+waveform.info.wave_descriptor,'bof');
            waveform.usertext = fread(fid,waveform.info.user_text,'char');
        end
    end 
    function get_trigtime_array
        if logical(waveform.info.trigtime_array)
            disp('THIS FILE CONTAINS INFORMATION THAT MAY NOT HAVE BEEN IMPORTED, PLEASE SAVE AS .dat ON SCOPE AND SEND LIAM THE .trc FILE')
            waveform.trigtime_array.trigger_time = [];
            waveform.trigtime_array.trigger_offset = [];
            for i = 0:(waveform.info.nom_subarray_count-1)
                waveform.trigtime_array.trigger_time(i+1) = ReadDouble(fid,offset+waveform.info.wave_descriptor + waveform.info.user_text + (i*16));
                waveform.trigtime_array.trigger_offset(i+1) = ReadDouble(fid,offset+waveform.info.wave_descriptor + waveform.info.user_text + (i*16) + 8);
            end
            waveform.trigtime_array.trigger_time = ReadDouble(fid,offset+waveform.info.wave_descriptor + waveform.info.user_text);
            waveform.trigtime_array.trigger_offset = ReadDouble(fid,offset+waveform.info.wave_descriptor + waveform.info.user_text + 8);
        end
    end 
    function get_ris_time_array
        if logical(waveform.info.ris_time_array)
            disp('THIS FILE CONTAINS INFORMATION THAT MAY NOT HAVE BEEN IMPORTED, PLEASE SAVE AS .dat ON SCOPE AND SEND LIAM THE .trc FILE')
            fseek(fid,offset+waveform.info.wave_descriptor + waveform.info.user_text+waveform.info.trigtime_array,'bof');
            waveform.ris_time_array.ris_offset = fread(fid,waveform.info.ris_sweeps,'float64');
        end
    end 
    function read_voltages
        fseek(fid, offset + waveform_raw.info.wave_descriptor + waveform_raw.info.user_text + waveform_raw.info.trigtime_array + waveform.info.ris_time_array, 'bof');
        if logical(waveform_raw.info.comm_type) %word
            waveform.voltage=fread(fid,waveform.info.wave_array1/2, 'int16');
        else %byte
            waveform.voltage=fread(fid,waveform.info.wave_array1,'int8');
        end
        
        waveform.voltage = waveform.voltage * waveform.info.vertical_gain - waveform.info.vertical_offset;    
    end
    function read_second_voltages
        if logical(waveform.info.wave_array2)
            disp('THIS FILE CONTAINS INFORMATION THAT MAY NOT HAVE BEEN IMPORTED, PLEASE SAVE AS .dat ON SCOPE AND SEND LIAM THE .trc FILE')
            fseek(fid, offset + waveform_raw.info.wave_descriptor + waveform_raw.info.user_text + waveform_raw.info.trigtime_array + waveform.info.ris_time_array +waveform.info.wave_array1 , 'bof');
            if logical(waveform_raw.info.comm_type) %word
                waveform.voltage=fread(fid,waveform.info.wave_array2/2,'int16');
            else %byte
                waveform.voltage=fread(fid,waveform.info.wave_array2,'int8');
            end
            waveform.voltage2 = waveform.voltage2 * waveform.info.vertical_gain - waveform.info.vertical_offset; 
        end
    end
    function generate_time_series
        waveform.time = (0:waveform.info.wave_array_count-1) * waveform.info.horizontal_interval + waveform.info.horizontal_offset;
        waveform.time = waveform.time(:);
    end

end

%% Low level import functions
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