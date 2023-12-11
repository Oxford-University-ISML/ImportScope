function voltage = get_second_voltage(obj) %#ok<STOUT>
if logical(obj.info.wave_array2)

    fmt = struct("HIFIRST", "ieee-le", "LOFIRST", "ieee-be").(obj.info.comm_order);
    fid = fopen(obj.path, "r", fmt);

    % Remove this fclose once implemented.
    fclose(fid);

    % Error as not yet show to be stable.
    eid = "importscope:not_yet_implemented";
    msg = "Uncertain on validity of object, take this .trc to Liam and save as (.dat)";
    throwAsCaller(MException(eid, msg))
    
    % Suggested implementation.
    % fseek(fid, ...
    %       obj.Offset + ...
    %       obj.info.wave_descriptor + ...
    %       obj.info.user_text + ...
    %       obj.info.trigtime_array + ...
    %       obj.info.ris_time_array + ...
    %       obj.info.wave_array1, ...
    %       "bof");
    % 
    % switch obj.info.comm_type
    %     case "word"
    %         voltage = fread(fid,obj.info.wave_array2 / 2,"int16");
    %     case "byte"
    %         voltage = fread(fid,obj.info.wave_array2    ,"int8");
    % end
    % voltage = voltage * obj.info.vertical_gain - obj.info.vertical_offset;
    % fclose(fid);

end
end
