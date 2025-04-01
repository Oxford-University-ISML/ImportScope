function get_info(obj)
    % Locations found by Liam on 7254, could vary scope to scope as no specific format for tek scopes.
    
    fid = fopen(obj.path, "r");
    byte_order = fread(fid, 1, "ushort"); %reading the byte order
    fclose(fid);
    switch byte_order
        case 61680 %equivalent to hexidecimal 0xF0F0, which is big endian
            fid = fopen(obj.path, "r", "ieee-be"); %reopening file with big endian format
        case 3855 %equivalent to hexidecimal 0x0F0F, which is little endian
            fid = fopen(obj.path, "r", "ieee-le"); %reopening file with little endian format
        otherwise
            obj.info = "Invalid Import";
            return
    end
    clearvars byte_order
    
    %% Static File Information                                                           location  format              length in bytes
    obj.locs.Waveform_static_file_information.Byte_order_verification                  = 0;        %unsigned short     2
    obj.locs.Waveform_static_file_information.Version_number                           = 3;        %char               8
    obj.locs.Waveform_static_file_information.Number_of_digits_in_byte_count           = 10;       %char               1
    obj.locs.Waveform_static_file_information.Number_of_bytes_to_the_end_of_file       = 11;       %longint            4
    obj.locs.Waveform_static_file_information.Number_of_bytes_per_point                = 15;       %char               1
    obj.locs.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer = 16;       %long int           4
    obj.locs.Waveform_static_file_information.Waveform_label                           = 40;       %char               32
    obj.locs.Waveform_static_file_information.N_number_of_FastFrames_minus_one         = 72;       %unsigned long      4
    obj.locs.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes     = 76;       %unsigned short     2
    obj.info.Waveform_static_file_information.Byte_order_verification                  = lib.byte.usht(fid, obj.locs.Waveform_static_file_information.Byte_order_verification                          );
    obj.info.Waveform_static_file_information.Version_number                           = lib.byte.char(fid, obj.locs.Waveform_static_file_information.Version_number,                 7                );
    obj.info.Waveform_static_file_information.Number_of_digits_in_byte_count           = lib.byte.char(fid, obj.locs.Waveform_static_file_information.Number_of_digits_in_byte_count, 1, "DoNotConvert");
    obj.info.Waveform_static_file_information.Number_of_bytes_to_the_end_of_file       = lib.byte.long(fid, obj.locs.Waveform_static_file_information.Number_of_bytes_to_the_end_of_file          ) + 15;
    obj.info.Waveform_static_file_information.Number_of_bytes_per_point                = lib.byte.char(fid, obj.locs.Waveform_static_file_information.Number_of_bytes_per_point,      1, "DoNotConvert");
    obj.info.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer = lib.byte.long(fid, obj.locs.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer         );
    obj.info.Waveform_static_file_information.Waveform_label                           = lib.byte.char(fid, obj.locs.Waveform_static_file_information.Waveform_label,                32                );
    obj.info.Waveform_static_file_information.N_number_of_FastFrames_minus_one         = lib.byte.ulng(fid, obj.locs.Waveform_static_file_information.N_number_of_FastFrames_minus_one                 );
    obj.info.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes     = lib.byte.usht(fid, obj.locs.Waveform_static_file_information.Size_of_the_waveform_header_in_bytes             );
    % Reference File Data
    obj.locs.Waveform_header.Reference_file_data.SetType                               = 78;       %enum (int)         4
    obj.locs.Waveform_header.Reference_file_data.WfmCnt                                = 82;       %unsigned long      4
    obj.locs.Waveform_header.Reference_file_data.Wfm_update_specification_count        = 110;      %unsigned long      4
    obj.locs.Waveform_header.Reference_file_data.Imp_dim_ref_count                     = 114;      %unsigned long      4
    obj.locs.Waveform_header.Reference_file_data.Exp_dim_ref_count                     = 118;      %unsigned long      4
    obj.locs.Waveform_header.Reference_file_data.Data_type                             = 122;      %enum (int)         4
    obj.locs.Waveform_header.Reference_file_data.Curve_ref_count                       = 142;      %unsigned long      4
    obj.locs.Waveform_header.Reference_file_data.Number_of_requested_fast_frames       = 146;      %unsigned long      4
    obj.locs.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames         = 150;      %unsigned long      4
    obj.locs.Waveform_header.Reference_file_data.Summary_frame_type                    = 154;      %unsigned short     2
    obj.locs.Waveform_header.Reference_file_data.Pix_map_display_format                = 156;      %enum (int)         4
    obj.locs.Waveform_header.Reference_file_data.Pix_map_max_value                     = 160;      %unsigned long long 8
    obj.info.Waveform_header.Reference_file_data.SetType                               = lib.byte.etek(fid, obj.locs.Waveform_header.Reference_file_data.SetType                        );
    obj.info.Waveform_header.Reference_file_data.WfmCnt                                = lib.byte.ulng(fid, obj.locs.Waveform_header.Reference_file_data.WfmCnt                         );
    obj.info.Waveform_header.Reference_file_data.Wfm_update_specification_count        = lib.byte.ulng(fid, obj.locs.Waveform_header.Reference_file_data.Wfm_update_specification_count );
    obj.info.Waveform_header.Reference_file_data.Imp_dim_ref_count                     = lib.byte.ulng(fid, obj.locs.Waveform_header.Reference_file_data.Imp_dim_ref_count              );
    obj.info.Waveform_header.Reference_file_data.Exp_dim_ref_count                     = lib.byte.ulng(fid, obj.locs.Waveform_header.Reference_file_data.Exp_dim_ref_count              );
    obj.info.Waveform_header.Reference_file_data.Data_type                             = lib.byte.etek(fid, obj.locs.Waveform_header.Reference_file_data.Data_type                      );
    obj.info.Waveform_header.Reference_file_data.Curve_ref_count                       = lib.byte.ulng(fid, obj.locs.Waveform_header.Reference_file_data.Curve_ref_count                );
    obj.info.Waveform_header.Reference_file_data.Number_of_requested_fast_frames       = lib.byte.ulng(fid, obj.locs.Waveform_header.Reference_file_data.Number_of_requested_fast_frames);
    obj.info.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames         = lib.byte.ulng(fid, obj.locs.Waveform_header.Reference_file_data.Number_of_aquired_fast_frames  );
    obj.info.Waveform_header.Reference_file_data.Summary_frame_type                    = lib.byte.usht(fid, obj.locs.Waveform_header.Reference_file_data.Summary_frame_type             );
    obj.info.Waveform_header.Reference_file_data.Pix_map_display_format                = lib.byte.etek(fid, obj.locs.Waveform_header.Reference_file_data.Pix_map_display_format         );
    obj.info.Waveform_header.Reference_file_data.Pix_map_max_value                     = lib.byte.ulng(fid, obj.locs.Waveform_header.Reference_file_data.Pix_map_max_value              );
    switch obj.info.Waveform_header.Reference_file_data.SetType
        case 0
            obj.info.Waveform_header.Reference_file_data.SetType = "Single Waveform Set";
        case 1
            obj.info.Waveform_header.Reference_file_data.SetType = "FastFrame Set";
            obj.info = "Invalid Import";
            return
        otherwise
            obj.info = "Invalid Import";
            return
    end
    switch obj.info.Waveform_header.Reference_file_data.Data_type
        case 0
            obj.info.Waveform_header.Reference_file_data.Data_type = "WFMDATA_SCALAR_MEAS";
        case 1
            obj.info.Waveform_header.Reference_file_data.Data_type = "WFMDATA_SCALAR_CONST";
        case 2
            obj.info.Waveform_header.Reference_file_data.Data_type = "WFMDATA_VECTOR";
        case 4
            obj.info.Waveform_header.Reference_file_data.Data_type = "WFMDATA_INVALID";
        case 5
            obj.info.Waveform_header.Reference_file_data.Data_type = "WFMDATA_WFMDB";
        case 6
            obj.info.Waveform_header.Reference_file_data.Data_type = "WFMDATA_DIGITAL";
        otherwise
            obj.info = "Invalid Import";
            return
    end
    switch obj.info.Waveform_header.Reference_file_data.Pix_map_display_format
        case 0
            obj.info.Waveform_header.Reference_file_data.Pix_map_display_format = "DSY_FORMAT_INVALID";
        case 1
            obj.info.Waveform_header.Reference_file_data.Pix_map_display_format = "DSY_FORMAT_YT";
        case 2
            obj.info.Waveform_header.Reference_file_data.Pix_map_display_format = "DSY_FORMAT_XY";
        case 3
            obj.info.Waveform_header.Reference_file_data.Pix_map_display_format = "DSY_FORMAT_XYZ";
        otherwise
            obj.info = "Invalid Import";
            return
    end

    %% Explicit Dimension 1
    if obj.info.Waveform_header.Reference_file_data.Exp_dim_ref_count > 0
        obj.locs.Waveform_header.Explicit_Dimension_1.Dim_scale            = 168;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_1.Dim_offset           = 176;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_1.Dim_size             = 184;      %unsigned long      4
        obj.locs.Waveform_header.Explicit_Dimension_1.Units                = 188;      %char               20
        obj.locs.Waveform_header.Explicit_Dimension_1.Dim_extent_min       = 208;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_1.Dim_extent_max       = 216;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_1.Dim_resolution       = 224;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_1.Dim_ref_point        = 232;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_1.Format               = 240;      %enum(int)          4
        obj.locs.Waveform_header.Explicit_Dimension_1.Storage_type         = 244;      %enum(int)          4
        obj.locs.Waveform_header.Explicit_Dimension_1.N_value              = 248;      %4byte              4
        obj.locs.Waveform_header.Explicit_Dimension_1.Over_range           = 252;      %4byte              4
        obj.locs.Waveform_header.Explicit_Dimension_1.Under_range          = 256;      %4byte              4
        obj.locs.Waveform_header.Explicit_Dimension_1.High_range           = 260;      %4byte              4
        obj.locs.Waveform_header.Explicit_Dimension_1.Row_range            = 264;      %4byte              4
        obj.locs.Waveform_header.Explicit_Dimension_1.User_scale           = 268;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_1.User_units           = 276;      %char               20
        obj.locs.Waveform_header.Explicit_Dimension_1.User_offset          = 296;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_1.Point_density        = 304;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_1.HRef_in_percent      = 312;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_1.TrigDelay_in_seconds = 320;      %double             8
        obj.info.Waveform_header.Explicit_Dimension_1.Dim_scale            = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Dim_scale     );
        obj.info.Waveform_header.Explicit_Dimension_1.Dim_offset           = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Dim_offset    );
        obj.info.Waveform_header.Explicit_Dimension_1.Dim_size             = lib.byte.ulng(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Dim_size      );
        obj.info.Waveform_header.Explicit_Dimension_1.Units                = lib.byte.char(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Units,      20);
        obj.info.Waveform_header.Explicit_Dimension_1.Dim_extent_min       = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Dim_extent_min);
        obj.info.Waveform_header.Explicit_Dimension_1.Dim_extent_max       = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Dim_extent_max);
        obj.info.Waveform_header.Explicit_Dimension_1.Dim_resolution       = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Dim_resolution);
        obj.info.Waveform_header.Explicit_Dimension_1.Dim_ref_point        = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Dim_ref_point );
        obj.info.Waveform_header.Explicit_Dimension_1.Format               = lib.byte.etek(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Format        );
        obj.info.Waveform_header.Explicit_Dimension_1.Storage_type         = lib.byte.etek(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Storage_type  );
        obj.info.Waveform_header.Explicit_Dimension_1.n_value              = 246;      %4byte              4
        obj.info.Waveform_header.Explicit_Dimension_1.over_range           = 250;      %4byte              4
        obj.info.Waveform_header.Explicit_Dimension_1.under_range          = 254;      %4byte              4
        obj.info.Waveform_header.Explicit_Dimension_1.high_range           = 258;      %4byte              4
        obj.info.Waveform_header.Explicit_Dimension_1.low_range            = 262;      %4byte              4
        obj.info.Waveform_header.Explicit_Dimension_1.User_scale           = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_1.User_scale          );
        obj.info.Waveform_header.Explicit_Dimension_1.User_units           = lib.byte.char(fid, obj.locs.Waveform_header.Explicit_Dimension_1.User_units,       20);
        obj.info.Waveform_header.Explicit_Dimension_1.User_offset          = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_1.User_offset         );
        obj.info.Waveform_header.Explicit_Dimension_1.Point_density        = lib.byte.ulng(fid, obj.locs.Waveform_header.Explicit_Dimension_1.Point_density       );
        obj.info.Waveform_header.Explicit_Dimension_1.HRef_in_percent      = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_1.HRef_in_percent     );
        obj.info.Waveform_header.Explicit_Dimension_1.TrigDelay_in_seconds = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_1.TrigDelay_in_seconds);
        switch obj.info.Waveform_header.Explicit_Dimension_1.Format
            case 0
                obj.info.Waveform_header.Explicit_Dimension_1.Format = "int16";
            case 1
                obj.info.Waveform_header.Explicit_Dimension_1.Format = "int32";
            case 2
                obj.info.Waveform_header.Explicit_Dimension_1.Format = "uint32";
            case 3
                obj.info.Waveform_header.Explicit_Dimension_1.Format = "uint64";
            case 4
                obj.info.Waveform_header.Explicit_Dimension_1.Format = "float32";
            case 5
                obj.info.Waveform_header.Explicit_Dimension_1.Format = "float64";
            case 6
                obj.info.Waveform_header.Explicit_Dimension_1.Format = "uint8";
            case 7
                obj.info.Waveform_header.Explicit_Dimension_1.Format = "int8";
            case 8
                obj.info.Waveform_header.Explicit_Dimension_1.Format = "EXP_INVALID_DATA_FORMAT";
            otherwise
                obj.info = "Invalid Import";
                return
        end
        switch obj.info.Waveform_header.Explicit_Dimension_1.Storage_type
            case 0
                obj.info.Waveform_header.Explicit_Dimension_1.Storage_type = "EXPLICIT_SAMPLE";
            case 1
                obj.info.Waveform_header.Explicit_Dimension_1.Storage_type = "EXPLICIT_MIN_MAX";
            case 2
                obj.info.Waveform_header.Explicit_Dimension_1.Storage_type = "EXPLICIT_VERT_HIST";
            case 3
                obj.info.Waveform_header.Explicit_Dimension_1.Storage_type = "EXPLICIT_HOR_HIST";
            case 4
                obj.info.Waveform_header.Explicit_Dimension_1.Storage_type = "EXPLICIT_ROW_ORDER";
            case 5
                obj.info.Waveform_header.Explicit_Dimension_1.Storage_type = "EXPLICIT_COLUMN_ORDER";
            case 6
                obj.info.Waveform_header.Explicit_Dimension_1.Storage_type = "EXPLICIT_INVALID_STORAGE";
            otherwise
                obj.info = "Invalid Import";
                return
        end
    end

    %% Explicit Dimension 2
    if obj.info.Waveform_header.Reference_file_data.Exp_dim_ref_count > 1
        obj.locs.Waveform_header.Explicit_Dimension_2.Dim_scale            = 328;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_2.Dim_offset           = 336;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_2.Dim_size             = 344;      %unsigned long      4
        obj.locs.Waveform_header.Explicit_Dimension_2.Units                = 348;      %char               20
        obj.locs.Waveform_header.Explicit_Dimension_2.Dim_extent_min       = 368;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_2.Dim_extent_max       = 376;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_2.Dim_resolution       = 384;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_2.Dim_ref_point        = 392;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_2.Format               = 400;      %enum(int)          4
        obj.locs.Waveform_header.Explicit_Dimension_2.Storage_type         = 404;      %enum(int)          4
        obj.locs.Waveform_header.Explicit_Dimension_2.N_value              = 408;      %4byte              4
        obj.locs.Waveform_header.Explicit_Dimension_2.Over_range           = 412;      %4byte              4
        obj.locs.Waveform_header.Explicit_Dimension_2.Under_range          = 416;      %4byte              4
        obj.locs.Waveform_header.Explicit_Dimension_2.High_range           = 420;      %4byte              4
        obj.locs.Waveform_header.Explicit_Dimension_2.Low_range            = 424;      %4byte              4
        obj.locs.Waveform_header.Explicit_Dimension_2.User_scale           = 428;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_2.User_units           = 436;      %char               20
        obj.locs.Waveform_header.Explicit_Dimension_2.User_offset          = 456;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_2.Point_density        = 464;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_2.HRef_in_percent      = 472;      %double             8
        obj.locs.Waveform_header.Explicit_Dimension_2.TrigDelay_in_seconds = 480;      %double             8
        obj.info.Waveform_header.Explicit_Dimension_2.Dim_scale            = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Dim_scale     );
        obj.info.Waveform_header.Explicit_Dimension_2.Dim_offset           = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Dim_offset    );
        obj.info.Waveform_header.Explicit_Dimension_2.Dim_size             = lib.byte.ulng(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Dim_size      );
        obj.info.Waveform_header.Explicit_Dimension_2.Units                = lib.byte.char(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Units,20      );
        obj.info.Waveform_header.Explicit_Dimension_2.Dim_extent_min       = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Dim_extent_min);
        obj.info.Waveform_header.Explicit_Dimension_2.Dim_extent_max       = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Dim_extent_max);
        obj.info.Waveform_header.Explicit_Dimension_2.Dim_resolution       = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Dim_resolution);
        obj.info.Waveform_header.Explicit_Dimension_2.Dim_ref_point        = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Dim_ref_point );
        obj.info.Waveform_header.Explicit_Dimension_2.Format               = lib.byte.etek(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Format        );
        obj.info.Waveform_header.Explicit_Dimension_2.Storage_type         = lib.byte.etek(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Storage_type  );
        obj.info.Waveform_header.Explicit_Dimension_2.n_value              = 402;      %4byte              4
        obj.info.Waveform_header.Explicit_Dimension_2.over_range           = 406;      %4byte              4
        obj.info.Waveform_header.Explicit_Dimension_2.under_range          = 410;      %4byte              4
        obj.info.Waveform_header.Explicit_Dimension_2.high_range           = 414;      %4byte              4
        obj.info.Waveform_header.Explicit_Dimension_2.low_range            = 418;      %4byte              4
        obj.info.Waveform_header.Explicit_Dimension_2.User_scale           = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_2.User_scale          );
        obj.info.Waveform_header.Explicit_Dimension_2.User_units           = lib.byte.char(fid, obj.locs.Waveform_header.Explicit_Dimension_2.User_units,20       );
        obj.info.Waveform_header.Explicit_Dimension_2.User_offset          = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_2.User_offset         );
        obj.info.Waveform_header.Explicit_Dimension_2.Point_density        = lib.byte.ulng(fid, obj.locs.Waveform_header.Explicit_Dimension_2.Point_density       );
        obj.info.Waveform_header.Explicit_Dimension_2.HRef_in_percent      = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_2.HRef_in_percent     );
        obj.info.Waveform_header.Explicit_Dimension_2.TrigDelay_in_seconds = lib.byte.dble(fid, obj.locs.Waveform_header.Explicit_Dimension_2.TrigDelay_in_seconds);
        switch obj.info.Waveform_header.Explicit_Dimension_2.Format
            case 0
                obj.info.Waveform_header.Explicit_Dimension_2.Format = "int16";
            case 1
                obj.info.Waveform_header.Explicit_Dimension_2.Format = "int32";
            case 2
                obj.info.Waveform_header.Explicit_Dimension_2.Format = "uint32";
            case 3
                obj.info.Waveform_header.Explicit_Dimension_2.Format = "uint64";
            case 4
                obj.info.Waveform_header.Explicit_Dimension_2.Format = "float32";
            case 5
                obj.info.Waveform_header.Explicit_Dimension_2.Format = "float64";
            case 6
                obj.info.Waveform_header.Explicit_Dimension_2.Format = "uint8";
            case 7
                obj.info.Waveform_header.Explicit_Dimension_2.Format = "int8";
            case 8
                obj.info.Waveform_header.Explicit_Dimension_2.Format = "EXP_INVALID_DATA_FORMAT";
            case 9
                obj.info.Waveform_header.Explicit_Dimension_2.Format = "DIMENSION NOT IN USE";
            otherwise
                obj.info = "Invalid Import";
                return
        end
        switch obj.info.Waveform_header.Explicit_Dimension_2.Storage_type
            case 0
                obj.info.Waveform_header.Explicit_Dimension_2.Storage_type = "EXPLICIT_SAMPLE";
            case 1
                obj.info.Waveform_header.Explicit_Dimension_2.Storage_type = "EXPLICIT_MIN_MAX";
            case 2
                obj.info.Waveform_header.Explicit_Dimension_2.Storage_type = "EXPLICIT_VERT_HIST";
            case 3
                obj.info.Waveform_header.Explicit_Dimension_2.Storage_type = "EXPLICIT_HOR_HIST";
            case 4
                obj.info.Waveform_header.Explicit_Dimension_2.Storage_type = "EXPLICIT_ROW_ORDER";
            case 5
                obj.info.Waveform_header.Explicit_Dimension_2.Storage_type = "EXPLICIT_COLUMN_ORDER";
            case 6
                obj.info.Waveform_header.Explicit_Dimension_2.Storage_type = "EXPLICIT_INVALID_STORAGE";
            otherwise
                obj.info = "Invalid Import";
                return
        end
    end

    %% Implicit Dimension 1
    if obj.info.Waveform_header.Reference_file_data.Imp_dim_ref_count > 0
        obj.locs.Waveform_header.Implicit_Dimension_1.Dim_scale            = 488;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_1.Dim_offset           = 496;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_1.Dim_size             = 504;      %unsigned long      4
        obj.locs.Waveform_header.Implicit_Dimension_1.Units                = 508;      %char               20
        obj.locs.Waveform_header.Implicit_Dimension_1.Dim_extent_min       = 528;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_1.Dim_extent_max       = 536;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_1.Dim_resolution       = 544;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_1.Dim_ref_point        = 552;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_1.Spacing              = 560;      %enum(int)          4
        obj.locs.Waveform_header.Implicit_Dimension_1.User_scale           = 564;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_1.User_units           = 572;      %char               20
        obj.locs.Waveform_header.Implicit_Dimension_1.User_offset          = 592;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_1.Point_density        = 600;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_1.HRef_in_percent      = 608;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_1.TrigDelay_in_seconds = 616;      %double             8
        obj.info.Waveform_header.Implicit_Dimension_1.Dim_scale            = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.Dim_scale           );
        obj.info.Waveform_header.Implicit_Dimension_1.Dim_offset           = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.Dim_offset          );
        obj.info.Waveform_header.Implicit_Dimension_1.Dim_size             = lib.byte.ulng(fid, obj.locs.Waveform_header.Implicit_Dimension_1.Dim_size            );
        obj.info.Waveform_header.Implicit_Dimension_1.Units                = lib.byte.char(fid, obj.locs.Waveform_header.Implicit_Dimension_1.Units,            20);
        obj.info.Waveform_header.Implicit_Dimension_1.Dim_extent_min       = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.Dim_extent_min      );
        obj.info.Waveform_header.Implicit_Dimension_1.Dim_extent_max       = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.Dim_extent_max      );
        obj.info.Waveform_header.Implicit_Dimension_1.Dim_resolution       = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.Dim_resolution      );
        obj.info.Waveform_header.Implicit_Dimension_1.Dim_ref_point        = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.Dim_ref_point       );
        obj.info.Waveform_header.Implicit_Dimension_1.Spacing              = lib.byte.etek(fid, obj.locs.Waveform_header.Implicit_Dimension_1.Spacing             );
        obj.info.Waveform_header.Implicit_Dimension_1.User_scale           = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.User_scale          );
        obj.info.Waveform_header.Implicit_Dimension_1.User_units           = lib.byte.char(fid, obj.locs.Waveform_header.Implicit_Dimension_1.User_units,       20);
        obj.info.Waveform_header.Implicit_Dimension_1.User_offset          = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.User_offset         );
        obj.info.Waveform_header.Implicit_Dimension_1.Point_density        = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.Point_density       );
        obj.info.Waveform_header.Implicit_Dimension_1.HRef_in_percent      = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.HRef_in_percent     );
        obj.info.Waveform_header.Implicit_Dimension_1.TrigDelay_in_seconds = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_1.TrigDelay_in_seconds);
    end

    %% Implicit Dimension 2
    if obj.info.Waveform_header.Reference_file_data.Imp_dim_ref_count > 1
        obj.locs.Waveform_header.Implicit_Dimension_2.Dim_scale            = 624;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_2.Dim_offset           = 632;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_2.Dim_size             = 640;      %unsigned long      4
        obj.locs.Waveform_header.Implicit_Dimension_2.Units                = 644;      %char               20
        obj.locs.Waveform_header.Implicit_Dimension_2.Dim_extent_min       = 664;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_2.Dim_extent_max       = 672;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_2.Dim_resolution       = 680;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_2.Dim_ref_point        = 688;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_2.Spacing              = 696;      %enum(int)          4
        obj.locs.Waveform_header.Implicit_Dimension_2.User_scale           = 700;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_2.User_units           = 708;      %char               20
        obj.locs.Waveform_header.Implicit_Dimension_2.User_offset          = 728;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_2.Point_density        = 736;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_2.HRef_in_percent      = 744;      %double             8
        obj.locs.Waveform_header.Implicit_Dimension_2.TrigDelay_in_seconds = 752;      %double             8
        obj.info.Waveform_header.Implicit_Dimension_2.Dim_scale            = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.Dim_scale           );
        obj.info.Waveform_header.Implicit_Dimension_2.Dim_offset           = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.Dim_offset          );
        obj.info.Waveform_header.Implicit_Dimension_2.Dim_size             = lib.byte.ulng(fid, obj.locs.Waveform_header.Implicit_Dimension_2.Dim_size            );
        obj.info.Waveform_header.Implicit_Dimension_2.Units                = lib.byte.char(fid, obj.locs.Waveform_header.Implicit_Dimension_2.Units,            20);
        obj.info.Waveform_header.Implicit_Dimension_2.Dim_extent_min       = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.Dim_extent_min      );
        obj.info.Waveform_header.Implicit_Dimension_2.Dim_extent_max       = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.Dim_extent_max      );
        obj.info.Waveform_header.Implicit_Dimension_2.Dim_resolution       = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.Dim_resolution      );
        obj.info.Waveform_header.Implicit_Dimension_2.Dim_ref_point        = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.Dim_ref_point       );
        obj.info.Waveform_header.Implicit_Dimension_2.Spacing              = lib.byte.etek(fid, obj.locs.Waveform_header.Implicit_Dimension_2.Spacing             );
        obj.info.Waveform_header.Implicit_Dimension_2.User_scale           = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.User_scale          );
        obj.info.Waveform_header.Implicit_Dimension_2.User_units           = lib.byte.char(fid, obj.locs.Waveform_header.Implicit_Dimension_2.User_units,       20);
        obj.info.Waveform_header.Implicit_Dimension_2.User_offset          = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.User_offset         );
        obj.info.Waveform_header.Implicit_Dimension_2.Point_density        = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.Point_density       );
        obj.info.Waveform_header.Implicit_Dimension_2.HRef_in_percent      = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.HRef_in_percent     );
        obj.info.Waveform_header.Implicit_Dimension_2.TrigDelay_in_seconds = lib.byte.dble(fid, obj.locs.Waveform_header.Implicit_Dimension_2.TrigDelay_in_seconds);
    end

    %% TimeBase Info 1
    if obj.info.Waveform_header.Reference_file_data.Curve_ref_count > 0
        obj.locs.Waveform_header.TimeBase_Info1.Real_point_spacing = 760;      %unsigned long      4
        obj.locs.Waveform_header.TimeBase_Info1.Sweep              = 764;      %enum(int)          4
        obj.locs.Waveform_header.TimeBase_Info1.Type_of_base       = 768;      %enum(int)          4
        obj.info.Waveform_header.TimeBase_Info1.Real_point_spacing = lib.byte.ulng(fid, obj.locs.Waveform_header.TimeBase_Info1.Real_point_spacing);
        obj.info.Waveform_header.TimeBase_Info1.Sweep              = lib.byte.etek(fid, obj.locs.Waveform_header.TimeBase_Info1.Sweep             );
        obj.info.Waveform_header.TimeBase_Info1.Type_of_base       = lib.byte.etek(fid, obj.locs.Waveform_header.TimeBase_Info1.Type_of_base      );
        switch obj.info.Waveform_header.TimeBase_Info1.Sweep
            case 0
                obj.info.Waveform_header.TimeBase_Info1.Sweep = "SWEEP_ROLL";
            case 1
                obj.info.Waveform_header.TimeBase_Info1.Sweep = "SWEEP_SAMPLE";
            case 2
                obj.info.Waveform_header.TimeBase_Info1.Sweep = "SWEEP_ET";
            case 3
                obj.info.Waveform_header.TimeBase_Info1.Sweep = "SWEEP_INVALID";
            otherwise
                obj.info = "Invalid Import";
                return
        end
        switch obj.info.Waveform_header.TimeBase_Info1.Type_of_base
            case 0
                obj.info.Waveform_header.TimeBase_Info1.Type_of_base = "BASE_TIME";
            case 1
                obj.info.Waveform_header.TimeBase_Info1.Type_of_base = "BASE_SPECTRAL_MAG";
            case 2
                obj.info.Waveform_header.TimeBase_Info1.Type_of_base = "BASE_SPRECTRAL_PHASE";
            case 3
                obj.info.Waveform_header.TimeBase_Info1.Type_of_base = "BASE_INVALID";
            otherwise
                obj.info = "Invalid Import";
                return
        end
    end

    %% TimeBase Info 2
    if obj.info.Waveform_header.Reference_file_data.Curve_ref_count > 1
        obj.locs.Waveform_header.TimeBase_Info2.Real_point_spacing = 772;      %unsigned long      4
        obj.locs.Waveform_header.TimeBase_Info2.Sweep              = 776;      %enum(int)          4
        obj.locs.Waveform_header.TimeBase_Info2.Type_of_base       = 780;      %enum(int)          4
        obj.info.Waveform_header.TimeBase_Info2.Real_point_spacing = lib.byte.ulng(fid, obj.locs.Waveform_header.TimeBase_Info2.Real_point_spacing);
        obj.info.Waveform_header.TimeBase_Info2.Sweep              = lib.byte.etek(fid, obj.locs.Waveform_header.TimeBase_Info2.Sweep             );
        obj.info.Waveform_header.TimeBase_Info2.Type_of_base       = lib.byte.etek(fid, obj.locs.Waveform_header.TimeBase_Info2.Type_of_base      );
        switch obj.info.Waveform_header.TimeBase_Info2.Sweep
            case 0
                obj.info.Waveform_header.TimeBase_Info2.Sweep = "SWEEP_ROLL";
            case 1
                obj.info.Waveform_header.TimeBase_Info2.Sweep = "SWEEP_SAMPLE";
            case 2
                obj.info.Waveform_header.TimeBase_Info2.Sweep = "SWEEP_ET";
            case 3
                obj.info.Waveform_header.TimeBase_Info2.Sweep = "SWEEP_INVALID";
            otherwise
                obj.info = "Invalid Import";
                return
        end
        switch obj.info.Waveform_header.TimeBase_Info2.Type_of_base
            case 0
                obj.info.Waveform_header.TimeBase_Info2.Type_of_base = "BASE_TIME";
            case 1
                obj.info.Waveform_header.TimeBase_Info2.Type_of_base = "BASE_SPECTRAL_MAG";
            case 2
                obj.info.Waveform_header.TimeBase_Info2.Type_of_base = "BASE_SPRECTRAL_PHASE";
            case 3
                obj.info.Waveform_header.TimeBase_Info2.Type_of_base = "BASE_INVALID";
            otherwise
                obj.info = "Invalid Import";
                return
        end
    end
    
    %% Wfm Update Spec
    obj.locs.Waveform_header.WfmUpdateSpec.Real_point_offset = 784;      %unsigned long      4
    obj.locs.Waveform_header.WfmUpdateSpec.TT_offset         = 788;      %double             8
    obj.locs.Waveform_header.WfmUpdateSpec.Frac_sec          = 796;      %double             8
    obj.locs.Waveform_header.WfmUpdateSpec.Gmt_sec           = 804;      %long               4
    obj.info.Waveform_header.WfmUpdateSpec.Real_point_offset = lib.byte.ulng(fid, obj.locs.Waveform_header.WfmUpdateSpec.Real_point_offset);
    obj.info.Waveform_header.WfmUpdateSpec.TT_offset         = lib.byte.dble(fid, obj.locs.Waveform_header.WfmUpdateSpec.TT_offset        );
    obj.info.Waveform_header.WfmUpdateSpec.Frac_sec          = lib.byte.dble(fid, obj.locs.Waveform_header.WfmUpdateSpec.Frac_sec         );
    obj.info.Waveform_header.WfmUpdateSpec.Gmt_sec           = lib.byte.long(fid, obj.locs.Waveform_header.WfmUpdateSpec.Gmt_sec          );
    
    %% Wfm Curve Object
    obj.locs.Waveform_header.WfmCurveObject.State_flags             = 808;      %unsigned long      4
    obj.locs.Waveform_header.WfmCurveObject.Type_of_check_sum       = 812;      %enum(int)          4
    obj.locs.Waveform_header.WfmCurveObject.Check_sum               = 816;      %short              2
    obj.locs.Waveform_header.WfmCurveObject.Precharge_start_offset  = 818;      %unsigned long      4
    obj.locs.Waveform_header.WfmCurveObject.Data_start_offset       = 822;      %unsigned long      4
    obj.locs.Waveform_header.WfmCurveObject.Postcharge_start_offset = 826;      %unsigned long      4
    obj.locs.Waveform_header.WfmCurveObject.Postcharge_stop_offset  = 830;      %unsigned long      4
    obj.locs.Waveform_header.WfmCurveObject.End_of_curve_buffer     = 834;      %unsigned long      4
    obj.info.Waveform_header.WfmCurveObject.State_flags             = lib.byte.ulng(fid, obj.locs.Waveform_header.WfmCurveObject.State_flags            );
    obj.info.Waveform_header.WfmCurveObject.Type_of_check_sum       = lib.byte.etek(fid, obj.locs.Waveform_header.WfmCurveObject.Type_of_check_sum      );
    obj.info.Waveform_header.WfmCurveObject.Check_sum               = lib.byte.ssht(fid, obj.locs.Waveform_header.WfmCurveObject.Check_sum              );
    obj.info.Waveform_header.WfmCurveObject.Precharge_start_offset  = lib.byte.ulng(fid, obj.locs.Waveform_header.WfmCurveObject.Precharge_start_offset );
    obj.info.Waveform_header.WfmCurveObject.Data_start_offset       = lib.byte.ulng(fid, obj.locs.Waveform_header.WfmCurveObject.Data_start_offset      );
    obj.info.Waveform_header.WfmCurveObject.Postcharge_start_offset = lib.byte.ulng(fid, obj.locs.Waveform_header.WfmCurveObject.Postcharge_start_offset);
    obj.info.Waveform_header.WfmCurveObject.Postcharge_stop_offset  = lib.byte.ulng(fid, obj.locs.Waveform_header.WfmCurveObject.Postcharge_stop_offset );
    obj.info.Waveform_header.WfmCurveObject.End_of_curve_buffer     = lib.byte.ulng(fid, obj.locs.Waveform_header.WfmCurveObject.End_of_curve_buffer    );
    switch obj.info.Waveform_header.WfmCurveObject.Type_of_check_sum
        case 0
            obj.info.Waveform_header.WfmCurveObject.Type_of_check_sum = "NO_CHECKSUM";
        case 1
            obj.info.Waveform_header.WfmCurveObject.Type_of_check_sum = "CTYPE_CRC16";
        case 2
            obj.info.Waveform_header.WfmCurveObject.Type_of_check_sum = "CTYPE_SUM16";
        case 3
            obj.info.Waveform_header.WfmCurveObject.Type_of_check_sum = "CTYPE_CRC32";
        case 4
            obj.info.Waveform_header.WfmCurveObject.Type_of_check_sum = "CTYPE_SUM32";
        otherwise
            obj.info = "Invalid Import";
            return
    end

    %% FastFrame Frames
    N = obj.info.Waveform_static_file_information.N_number_of_FastFrames_minus_one;
    obj.locs.fast_frame_frames.N_WfmUpdateSpec_object = 838;
    obj.locs.fast_frame_frames.N_WfmCurveSpec_objects = 838 + (N*24);
    
    %% CurveBuffer
    obj.locs.CurveBuffer.Curve_buffer                 = 838 + (N*54);
    
    %% Checksum
    obj.locs.CurveBufferWfmFileChecksum.Waveform_file_checksum   = obj.info.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer+obj.info.Waveform_header.WfmCurveObject.End_of_curve_buffer; % Needs correcting as this assumes no user marks.
    frewind(fid)
    obj.info.WfmFileChecksum.Waveform_file_checksum_calculated  = sum(fread(fid,obj.locs.CurveBufferWfmFileChecksum.Waveform_file_checksum,"uchar"));
    obj.info.WfmFileChecksum.Waveform_file_checksum             = lib.byte.ullg(fid,obj.locs.CurveBufferWfmFileChecksum.Waveform_file_checksum);
    
    %% Checks on waveform
    FastFramesPresentCheck1 = obj.info.Waveform_static_file_information.N_number_of_FastFrames_minus_one ~= 0;
    FastFramesPresentCheck2 = obj.locs.fast_frame_frames.N_WfmUpdateSpec_object ~= obj.locs.CurveBuffer.Curve_buffer;
    FastFramesPresentCheck3 = obj.locs.fast_frame_frames.N_WfmCurveSpec_objects ~= obj.locs.CurveBuffer.Curve_buffer;
    FastFramesPresent       = FastFramesPresentCheck1 || FastFramesPresentCheck2 || FastFramesPresentCheck3;
    NotValidVersion         = ~strcmp(obj.info.Waveform_static_file_information.Version_number,"WFM#003");
    MoreThanOneCurve        = obj.info.Waveform_header.Reference_file_data.Curve_ref_count ~= 1;
    CurveBeginsWrongPlace   = obj.info.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer ~= obj.locs.CurveBuffer.Curve_buffer;
    CurveTheWrongSize       = obj.info.Waveform_header.Implicit_Dimension_1.Dim_size ~= obj.info.Waveform_header.WfmCurveObject.End_of_curve_buffer / obj.info.Waveform_static_file_information.Number_of_bytes_per_point;
    ChecksumIssue           = obj.info.WfmFileChecksum.Waveform_file_checksum_calculated ~= obj.info.WfmFileChecksum.Waveform_file_checksum;
    if FastFramesPresent || NotValidVersion || MoreThanOneCurve || CurveBeginsWrongPlace || CurveTheWrongSize || ChecksumIssue
        obj.info = "Invalid Import";
        return
    end
    
    blank_line_count = 0;
    while ~feof(fid)
        blank_line_count = blank_line_count + 1;
        fread(fid, 1, "int8");
    end
    
    if blank_line_count ~= 1
        disp("More blank lines than expected, below is the number recorded")
        disp(blank_line_count)
    end
    clearvars blank_line_count
    
    obj.raw_info                        = obj.info;
    obj.info.horizontal_resolution      = obj.info.Waveform_header.Implicit_Dimension_1.Dim_scale;
    obj.info.vertical_resolution        = obj.info.Waveform_header.Explicit_Dimension_1.Dim_scale;
    obj.info.horizontal_unit            = deblank(obj.info.Waveform_header.Implicit_Dimension_1.Units);
    obj.info.vertical_unit              = deblank(obj.info.Waveform_header.Explicit_Dimension_1.Units);
    obj.info.no_of_points               = obj.info.Waveform_header.Implicit_Dimension_1.Dim_size;
    obj.info.time_of_aquisition         = datetime(obj.info.Waveform_header.WfmUpdateSpec.Gmt_sec, "ConvertFrom", "posixtime");
    obj.info.version_number             = obj.info.Waveform_static_file_information.Version_number;
    obj.info.no_of_bytes_per_data_point = obj.info.Waveform_static_file_information.Number_of_bytes_per_point;
    obj.info.waveform_label             = obj.info.Waveform_static_file_information.Waveform_label;
    
    obj.info = rmfield(obj.info, ["Waveform_header" "WfmFileChecksum" "Waveform_static_file_information"]);
    obj.valid_import = true;
end