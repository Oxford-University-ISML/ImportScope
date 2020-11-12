%% This file is designed to read Tektronix binary (.wfm) files. 
% You should run the ImportTek function with no input.
% The output will be a struct containg file information, time series, and voltage. 
% Any issues contact Liam.

function waveform = ImportTekWFM()

%% Initialising Locations & Waveform Variables and opening the binary file.
[filename,pathname] = uigetfile('*');
filename = [pathname filename];
clearvars pathname

% IF IN EXAMPLE MODE
% filename = 'examples/example_wfm.wfm';

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
        waveform.Waveform_header.Reference_file_data.SetType                         = ReadEnum(fid,  locations.Waveform_header.Reference_file_data.SetType);                                %enum (int)         4
        waveform.Waveform_header.Reference_file_data.WfmCnt                          = ReadULong(fid, locations.Waveform_header.Reference_file_data.WfmCnt);                                 %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Wfm_update_specification_count  = ReadULong(fid, locations.Waveform_header.Reference_file_data.Wfm_update_specification_count);         %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Imp_dim_ref_count               = ReadULong(fid, locations.Waveform_header.Reference_file_data.Imp_dim_ref_count);                 %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Exp_dim_ref_count               = ReadULong(fid, locations.Waveform_header.Reference_file_data.Exp_dim_ref_count);                 %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Data_type                       = ReadEnum(fid,  locations.Waveform_header.Reference_file_data.Data_type);                              %enum (int)         4
        waveform.Waveform_header.Reference_file_data.Curve_ref_count                 = ReadULong(fid, locations.Waveform_header.Reference_file_data.Curve_ref_count);                        %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Number_of_requested_fast_frames = ReadULong(fid, locations.Waveform_header.Reference_file_data.Number_of_requested_fast_frames);            %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames   = ReadULong(fid, locations.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames);              %unsigned long      4
        waveform.Waveform_header.Reference_file_data.Summary_frame_type              = ReadUShort(fid,locations.Waveform_header.Reference_file_data.Summary_frame_type);                     %unsigned short     2
        waveform.Waveform_header.Reference_file_data.Pix_map_display_format          = ReadEnum(fid,  locations.Waveform_header.Reference_file_data.Pix_map_display_format);                 %enum (int)         4
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
            waveform.Waveform_header.Explicit_Dimension_1.Format                    = ReadEnum(fid,  locations.Waveform_header.Explicit_Dimension_1.Format);                                     %enum(int)          4
            waveform.Waveform_header.Explicit_Dimension_1.Storage_type              = ReadEnum(fid,  locations.Waveform_header.Explicit_Dimension_1.Storage_type);                               %enum(int)          4
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
            waveform.Waveform_header.Explicit_Dimension_2.Format                    = ReadEnum(fid,  locations.Waveform_header.Explicit_Dimension_2.Format);                                     %enum(int)          4
            waveform.Waveform_header.Explicit_Dimension_2.Storage_type              = ReadEnum(fid,  locations.Waveform_header.Explicit_Dimension_2.Storage_type);                               %enum(int)          4
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
            waveform.Waveform_header.Implicit_Dimension_1.Spacing                   = ReadEnum(  fid,locations.Waveform_header.Implicit_Dimension_1.Spacing);                                    %enum(int)          4
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
            waveform.Waveform_header.Implicit_Dimension_2.Spacing                   = ReadEnum(  fid,locations.Waveform_header.Implicit_Dimension_2.Spacing);                                    %enum(int)          4
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
            waveform.Waveform_header.TimeBase_Info1.Sweep                           = ReadEnum( fid,locations.Waveform_header.TimeBase_Info1.Sweep);                                             %enum(int)          4
            waveform.Waveform_header.TimeBase_Info1.Type_of_base                    = ReadEnum( fid,locations.Waveform_header.TimeBase_Info1.Type_of_base);                                      %enum(int)          4
        end
        if waveform.Waveform_header.Reference_file_data.Curve_ref_count > 1
            waveform.Waveform_header.TimeBase_Info2.Real_point_spacing              = ReadULong(fid,locations.Waveform_header.TimeBase_Info2.Real_point_spacing);                                %unsigned long      4
            waveform.Waveform_header.TimeBase_Info2.Sweep                           = ReadEnum( fid,locations.Waveform_header.TimeBase_Info2.Sweep);                                             %enum(int)          4
            waveform.Waveform_header.TimeBase_Info2.Type_of_base                    = ReadEnum( fid,locations.Waveform_header.TimeBase_Info2.Type_of_base);                                      %enum(int)          4
        end
        
        %% Importing Waveform Update Spec
        waveform.Waveform_header.WfmUpdateSpec.Real_point_offset                = ReadULong( fid,locations.Waveform_header.WfmUpdateSpec.Real_point_offset);                                %unsigned long      4
        waveform.Waveform_header.WfmUpdateSpec.TT_offset                        = ReadDouble(fid,locations.Waveform_header.WfmUpdateSpec.TT_offset);                                         %double             8
        waveform.Waveform_header.WfmUpdateSpec.Frac_sec                         = ReadDouble(fid,locations.Waveform_header.WfmUpdateSpec.Frac_sec);                                          %double             8
        waveform.Waveform_header.WfmUpdateSpec.Gmt_sec                          = ReadLong(  fid,locations.Waveform_header.WfmUpdateSpec.Gmt_sec);                                           %long               4
        
        %% Importing Waveform Curve Objects
        waveform.Waveform_header.WfmCurveObject.State_flags                     = ReadULong(fid,locations.Waveform_header.WfmCurveObject.State_flags);                                       %unsigned long      4
        waveform.Waveform_header.WfmCurveObject.Type_of_check_sum               = ReadEnum( fid,locations.Waveform_header.WfmCurveObject.Type_of_check_sum);                                 %enum(int)          4
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

%% Functions called to read various data types.
function l=ReadULong(fid,Addr)
    fseek(fid,Addr,'bof');
    l = fread(fid,1,'ulong');
end
function l=ReadULongLong(fid,Addr)
    fseek(fid,Addr,'bof');
    l = fread(fid,1,'int64');
end
function s=ReadUShort(fid,Addr)
    fseek(fid,Addr,'bof');
    s = fread(fid,1,'ushort');
end
function d=ReadDouble(fid, Addr)
	fseek(fid,Addr,'bof');
	d=fread(fid,1,'double');
end
function f=ReadFloat(fid,Addr)
	fseek(fid,Addr,'bof');
	f=fread(fid,1,'float');
end
function l=ReadLong(fid,Addr)
	fseek(fid,Addr,'bof');
	l=fread(fid,1,'long');
end
function s=ReadShort(fid,Addr)
    fseek(fid,Addr,'bof');
    s = fread(fid,1,'short');
end
function c=ReadChar(fid,Addr,No_of_char,DoNotConvert)
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
function e=ReadEnum(fid,Addr)
    fseek(fid,Addr,'bof');
    e = fread(fid,1,'int');
end
function c = ReadDefinedFormat(fid,Addr,No_of_elem,format)
    fseek(fid,Addr,'bof');
    c = fread(fid,No_of_elem,format);
end


