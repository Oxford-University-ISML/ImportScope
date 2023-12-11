function ris_time_array = get_ris_time_array(obj) %#ok<STOUT>
    
    if logical(obj.info.ris_time_array)
    
        fmt = struct("HIFIRST", "ieee-le", "LOFIRST", "ieee-be").(obj.info.comm_order);
        fid = fopen(obj.path, "r", fmt);
    
        % Remove this fclose once implemented.
        fclose(fid);

        % Error as not yet show to be stable.
        eid = "importscope:not_yet_implemented";
        msg = "Uncertain on validity of object, take this .trc to Liam and save as (.dat)";
        throwAsCaller(MException(eid, msg))

        % Suggested implementation.
        % fseek(fid,obj.Offset+obj.info.wave_descriptor + obj.info.user_text+obj.info.trigtime_array,"bof");
        % ris_time_array.ris_offset = fread(fid,obj.info.ris_sweeps,"float64");
        % fclose(fid);
    end

end
