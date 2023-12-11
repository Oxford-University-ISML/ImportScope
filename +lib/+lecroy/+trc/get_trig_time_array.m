function trig_time_array = get_trig_time_array(obj) %#ok<STOUT>
    if logical(obj.info.trigtime_array)
    
        fmt = struct("HIFIRST", "ieee-le", "LOFIRST", "ieee-be").(obj.info.comm_order);
        fid=fopen(obj.path, "r", fmt);
        
        % Remove this fclose once implemented.
        fclose(fid);

        % Error as not yet show to be stable.
        eid = "importscope:not_yet_implemented";
        msg = "Uncertain on validity of object, take this .trc to Liam and save as (.dat)";
        throwAsCaller(MException(eid, msg))

        % Suggested implementation
        % TrigtimeArray.trigger_time = [];
        % TrigtimeArray.trigger_offset = [];
        % for i = 0:(obj.info.nom_subarray_count-1)
        %     TrigtimeArray.trigger_time(  i+1) = obj.lib.byte.dble(fid, obj.Offset + obj.info.wave_descriptor + obj.info.user_text + (i*16));
        %     TrigtimeArray.trigger_offset(i+1) = obj.lib.byte.dble(fid, obj.Offset + obj.info.wave_descriptor + obj.info.user_text + (i*16) + 8);
        % end
        % TrigtimeArray.trigger_time   = obj.lib.byte.dble(fid, obj.Offset + obj.info.wave_descriptor + obj.info.user_text);
        % TrigtimeArray.trigger_offset = obj.lib.byte.dble(fid, obj.Offset + obj.info.wave_descriptor + obj.info.user_text + 8);
        % fclose(fid);
    end
end
