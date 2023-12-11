function voltage = get_voltage(obj)
    
    if logical(obj.info.wave_array1)
    
        fmt = struct("HIFIRST", "ieee-le", "LOFIRST", "ieee-be").(obj.info.comm_order);
        fid = fopen(obj.path, "r", fmt);
    
        fseek(fid, ...
              obj.offset                + ...
              obj.info.wave_descriptor  + ...
              obj.info.user_text        + ...
              obj.info.trigtime_array   + ...
              obj.info.ris_time_array, ...
              "bof");
    
        switch obj.info.comm_type
            case "word"
                voltage = fread(fid, obj.info.wave_array1 / 2, "int16");
            case "byte"
                voltage = fread(fid, obj.info.wave_array1    , "int8");
        end
        fclose(fid);

        scle = obj.info.vertical_gain;
        offs = obj.info.vertical_offset;
        voltage = voltage * scle - offs;
    
    end
end
