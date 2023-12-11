function get_info(obj)
    
    fid = fopen(obj.path, "r");
    
    tmp = char(fread(fid, 30, "schar")');
    switch tmp(12:19)
        case "WAVEDESC" % This is seemingly always the case!
            obj.offset = 11;
        otherwise % This will find it if not.
            obj.offset = strfind(tmp, "WAVEDESC") - 1;
    end
    clearvars tmp
    
    obj.locs.TEMPLATE_NAME      = obj.offset + 16;   % string
    obj.locs.COMM_TYPE          = obj.offset + 32;   % enum
    obj.locs.COMM_ORDER         = obj.offset + 34;   % enum
    obj.locs.WAVE_DESCRIPTOR    = obj.offset + 36;   % long length of the descriptor block
    obj.locs.USER_TEXT          = obj.offset + 40;   % long  length of the usertext block
    obj.locs.RES_DESC1          = obj.offset + 44;   % long
    obj.locs.TRIGTIME_ARRAY     = obj.offset + 48;   % long
    obj.locs.RIS_TIME_ARRAY     = obj.offset + 52;   % long
    obj.locs.RES_ARRAY          = obj.offset + 56;   % long
    obj.locs.WAVE_ARRAY_1       = obj.offset + 60;   % long length (in Byte) of the sample array
    obj.locs.WAVE_ARRAY_2       = obj.offset + 64;   % long length (in Byte) of the optional second sample array
    obj.locs.RES_ARRAY2         = obj.offset + 68;   % long
    obj.locs.RES_ARRAY3         = obj.offset + 72;   % long
    obj.locs.INSTRUMENT_NAME    = obj.offset + 76;   % string
    obj.locs.INSTRUMENT_NUMBER  = obj.offset + 92;   % long
    obj.locs.TRACE_LABEL        = obj.offset + 96;   % string
    obj.locs.RESERVED1          = obj.offset + 112;  % word
    obj.locs.RESERVED2          = obj.offset + 114;  % word
    obj.locs.WAVE_ARRAY_COUNT   = obj.offset + 116;  % long
    obj.locs.PNTS_PER_SCREEN    = obj.offset + 120;  % long
    obj.locs.FIRST_VALID_PNT    = obj.offset + 124;  % long
    obj.locs.LAST_VALID_PNT     = obj.offset + 128;  % long
    obj.locs.FIRST_POINT        = obj.offset + 132;  % long
    obj.locs.SPARSING_FACTOR    = obj.offset + 136;  % long
    obj.locs.SEGMENT_INDEX      = obj.offset + 140;  % long
    obj.locs.SUBARRAY_COUNT     = obj.offset + 144;  % long
    obj.locs.SWEEPS_PER_AQG     = obj.offset + 148;  % long
    obj.locs.POINTS_PER_PAIR    = obj.offset + 152;  % word
    obj.locs.PAIR_OFFSET        = obj.offset + 154;  % word
    obj.locs.VERTICAL_GAIN      = obj.offset + 156;  % float
    obj.locs.VERTICAL_OFFSET    = obj.offset + 160;  % float
    obj.locs.MAX_VALUE          = obj.offset + 164;  % float
    obj.locs.MIN_VALUE          = obj.offset + 168;  % float
    obj.locs.NOMINAL_BITS       = obj.offset + 172;  % word
    obj.locs.NOM_SUBARRAY_COUNT = obj.offset + 174;  % word
    obj.locs.HORIZ_INTERVAL     = obj.offset + 176;  % float
    obj.locs.HORIZ_OFFSET       = obj.offset + 180;  % double
    obj.locs.PIXEL_OFFSET       = obj.offset + 188;  % double
    obj.locs.VERTUNIT           = obj.offset + 196;  % unit_definition
    obj.locs.HORUNIT            = obj.offset + 244;  % unit_definition
    obj.locs.HORIZ_UNCERTAINTY  = obj.offset + 292;  % float
    obj.locs.TRIGGER_TIME       = obj.offset + 296;  % time_stamp
    obj.locs.ACQ_DURATION       = obj.offset + 312;  % float
    obj.locs.RECORD_TYPE        = obj.offset + 316;  % enum
    obj.locs.PROCESSING_DONE    = obj.offset + 318;  % enum
    obj.locs.RESERVED5          = obj.offset + 320;  % word
    obj.locs.RIS_SWEEPS         = obj.offset + 322;  % word
    obj.locs.TIMEBASE           = obj.offset + 324;  % enum
    obj.locs.VERT_COUPLING      = obj.offset + 326;  % enum
    obj.locs.PROBE_ATT          = obj.offset + 328;  % float
    obj.locs.FIXED_VERT_GAIN    = obj.offset + 332;  % enum
    obj.locs.BANDWIDTH_LIMIT    = obj.offset + 334;  % enum
    obj.locs.VERTICAL_VERNIER   = obj.offset + 336;  % enum
    obj.locs.ACQ_VERT_OFFSET    = obj.offset + 340;  % float
    obj.locs.WAVE_SOURCE        = obj.offset + 344;  % enum
    
    if logical(lib.byte.enum(fid, obj.locs.COMM_ORDER))
        fmt = "ieee-le"; % HIFIRST
    else
        fmt = "ieee-be"; % LOFIRST
    end
    fclose(fid);
    fid = fopen(obj.path, "r", fmt);
    
    obj.info.template_name          = lib.byte.text(fid, obj.locs.TEMPLATE_NAME     );
    obj.info.comm_type              = lib.byte.enum(fid, obj.locs.COMM_TYPE         );
    obj.info.comm_order             = lib.byte.enum(fid, obj.locs.COMM_ORDER        );
    obj.info.wave_descriptor        = lib.byte.long(fid, obj.locs.WAVE_DESCRIPTOR   );
    obj.info.user_text              = lib.byte.long(fid, obj.locs.USER_TEXT         );
    obj.info.res_desc1              = lib.byte.long(fid, obj.locs.RES_DESC1         );
    obj.info.trigtime_array         = lib.byte.long(fid, obj.locs.TRIGTIME_ARRAY    );
    obj.info.ris_time_array         = lib.byte.long(fid, obj.locs.RIS_TIME_ARRAY    );
    obj.info.res_array              = lib.byte.long(fid, obj.locs.RES_ARRAY         );
    obj.info.wave_array1            = lib.byte.long(fid, obj.locs.WAVE_ARRAY_1      );
    obj.info.wave_array2            = lib.byte.long(fid, obj.locs.WAVE_ARRAY_2      );
    obj.info.res_array2             = lib.byte.long(fid, obj.locs.RES_ARRAY2        );
    obj.info.res_array3             = lib.byte.long(fid, obj.locs.RES_ARRAY3        );
    obj.info.instrument_name        = lib.byte.text(fid, obj.locs.INSTRUMENT_NAME   );
    obj.info.instrument_number      = lib.byte.long(fid, obj.locs.INSTRUMENT_NUMBER );
    obj.info.trace_label            = lib.byte.text(fid, obj.locs.TRACE_LABEL       );
    obj.info.reserved1              = lib.byte.word(fid, obj.locs.RESERVED1         );
    obj.info.reserved2              = lib.byte.word(fid, obj.locs.RESERVED2         );
    obj.info.wave_array_count       = lib.byte.long(fid, obj.locs.WAVE_ARRAY_COUNT  );
    obj.info.points_per_screen      = lib.byte.long(fid, obj.locs.PNTS_PER_SCREEN   );
    obj.info.first_valid_point      = lib.byte.long(fid, obj.locs.FIRST_VALID_PNT   );
    obj.info.last_valid_point       = lib.byte.long(fid, obj.locs.LAST_VALID_PNT    );
    obj.info.first_point            = lib.byte.long(fid, obj.locs.FIRST_POINT       );
    obj.info.sparsing_factor        = lib.byte.long(fid, obj.locs.SPARSING_FACTOR   );
    obj.info.segment_index          = lib.byte.long(fid, obj.locs.SEGMENT_INDEX     );
    obj.info.subarray_count         = lib.byte.long(fid, obj.locs.SUBARRAY_COUNT    );
    obj.info.sweeps_per_aqg         = lib.byte.long(fid, obj.locs.SWEEPS_PER_AQG    );
    obj.info.points_per_pair        = lib.byte.word(fid, obj.locs.POINTS_PER_PAIR   );
    obj.info.pair_offset            = lib.byte.word(fid, obj.locs.PAIR_OFFSET       );
    obj.info.vertical_gain          = lib.byte.flot(fid, obj.locs.VERTICAL_GAIN     );
    obj.info.vertical_offset        = lib.byte.flot(fid, obj.locs.VERTICAL_OFFSET   );
    obj.info.max_value              = lib.byte.flot(fid, obj.locs.MAX_VALUE         );
    obj.info.min_value              = lib.byte.flot(fid, obj.locs.MIN_VALUE         );
    obj.info.nominal_bits           = lib.byte.word(fid, obj.locs.NOMINAL_BITS      );
    obj.info.nom_subarray_count     = lib.byte.word(fid, obj.locs.NOM_SUBARRAY_COUNT);
    obj.info.horizontal_interval    = lib.byte.flot(fid, obj.locs.HORIZ_INTERVAL    );
    obj.info.horizontal_offset      = lib.byte.dble(fid, obj.locs.HORIZ_OFFSET      );
    obj.info.pixel_offset           = lib.byte.dble(fid, obj.locs.PIXEL_OFFSET      );
    obj.info.vertical_unit          = lib.byte.unit(fid, obj.locs.VERTUNIT          );
    obj.info.horizontal_unit        = lib.byte.unit(fid, obj.locs.HORUNIT           );
    obj.info.horizontal_uncertainty = lib.byte.flot(fid, obj.locs.HORIZ_UNCERTAINTY );
    obj.info.trigger_time           = lib.byte.time(fid, obj.locs.TRIGGER_TIME      );
    obj.info.acq_duration           = lib.byte.flot(fid, obj.locs.ACQ_DURATION      );
    obj.info.recording_type         = lib.byte.enum(fid, obj.locs.RECORD_TYPE       );
    obj.info.processing_done        = lib.byte.enum(fid, obj.locs.PROCESSING_DONE   );
    obj.info.reserved5              = lib.byte.word(fid, obj.locs.RESERVED5         );
    obj.info.ris_sweeps             = lib.byte.word(fid, obj.locs.RIS_SWEEPS        );
    obj.info.timebase               = lib.byte.enum(fid, obj.locs.TIMEBASE          );
    obj.info.vertical_coupling      = lib.byte.enum(fid, obj.locs.VERT_COUPLING     );
    obj.info.probe_attenuation      = lib.byte.flot(fid, obj.locs.PROBE_ATT         );
    obj.info.fixed_vertical_gain    = lib.byte.enum(fid, obj.locs.FIXED_VERT_GAIN   );
    obj.info.bandwidth_limit        = lib.byte.enum(fid, obj.locs.BANDWIDTH_LIMIT   );
    obj.info.vertical_vernier       = lib.byte.flot(fid, obj.locs.VERTICAL_VERNIER  );
    obj.info.acq_vertical_offset    = lib.byte.flot(fid, obj.locs.ACQ_VERT_OFFSET   );
    obj.info.wave_source            = lib.byte.enum(fid, obj.locs.WAVE_SOURCE       );
    
    % Close the file.
    fclose(fid);
    
    tmp = ["byte" "word"];
    obj.info.comm_type = tmp(1 + obj.info.comm_type);
    
    tmp = ["LOFIRST" "HIFIRST"];
    obj.info.comm_order = tmp(1 + obj.info.comm_order);
    
    tmp = ["single_sweep" "interleaved" "histogram" "graph" "filter_coefficient" "complex" "extrema" "sequence_obsolete" "centered_RIS" "peak_detect"];
    obj.info.recording_type = tmp(1 + obj.info.recording_type);
    
    tmp = ["no_processing" "fir_filter" "interpolated" "sparsed" "autoscaled" "no_result" "rolling" "cumulative"];
    obj.info.processing_done = tmp(1 + obj.info.processing_done);
    
    if obj.info.timebase == 100
        obj.info.timebase = "EXTERNAL";
    else
        tmp = [
            "1 ps / div";"2 ps / div";"5 ps / div";"10 ps / div";"20 ps / div";"50 ps / div";"100 ps / div";"200 ps / div";"500 ps / div";
            "1 ns / div";"2 ns / div";"5 ns / div";"10 ns / div";"20 ns / div";"50 ns / div";"100 ns / div";"200 ns / div";"500 ns / div";
            "1 us / div";"2 us / div";"5 us / div";"10 us / div";"20 us / div";"50 us / div";"100 us / div";"200 us / div";"500 us / div";
            "1 ms / div";"2 ms / div";"5 ms / div";"10 ms / div";"20 ms / div";"50 ms / div";"100 ms / div";"200 ms / div";"500 ms / div";
            "1 s / div" ;"2 s / div" ;"5 s / div" ;"10 s / div" ;"20 s / div" ;"50 s / div" ;"100 s / div" ;"200 s / div" ;"500 s / div" ;
            "1 ks / div";"2 ks / div";"5 ks / div"];
        obj.info.timebase = tmp(1 + obj.info.timebase);
    end
    
    tmp = ["DC_50_Ohms" "ground" "DC 1MOhm" "ground" "AC 1MOhm"];
    obj.info.vertical_coupling = tmp(1 + obj.info.vertical_coupling);
    
    tmp = [
        "1 uV / div";"2 uV / div";"5 uV / div";"10 uV / div";"20 uV / div";"50 uV / div";"100 uV / div";"200 uV / div";"500 uV / div";
        "1 mV / div";"2 mV / div";"5 mV / div";"10 mV / div";"20 mV / div";"50 mV / div";"100 mV / div";"200 mV / div";"500 mV / div";
        "1 V / div" ;"2 V / div" ;"5 V / div" ;"10 V / div" ;"20 V / div" ;"50 V / div" ;"100 V / div" ;"200 V / div" ;"500 V / div" ;
        "1 kV / div"];
    obj.info.fixed_vertical_gain = tmp(1 + obj.info.fixed_vertical_gain);
    
    tmp = ["off" "on"];
    obj.info.bandwidth_limit = tmp(1 + obj.info.bandwidth_limit);
    
    if obj.info.wave_source == 9
        obj.info.wave_source = "UNKNOWN";
    else
        tmp = ["C1" "C2" "C3" "C4" "UNKNOWN"];
        obj.info.wave_source = tmp(1 + obj.info.wave_source);
    end
    clearvars tmp
    
    obj.valid_import = true;
end        