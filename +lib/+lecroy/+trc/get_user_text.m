function user_text = get_user_text(obj) %#ok<STOUT>
    if logical(obj.info.user_text)
    
        fmt = struct("HIFIRST", "ieee-le", "LOFIRST", "ieee-be").(obj.info.comm_order);
        fid=fopen(obj.path, "r", fmt);

        % Remove this fclose once implemented.
        fclose(fid);

        % Error as not yet show to be stable.
        eid = "importscope:not_yet_implemented";
        msg = "Uncertain on validity of object, take this .trc to Liam and save as (.dat)";
        throwAsCaller(MException(eid, msg))

        % Suggested implementation
        % fseek(fid, ...
        %       obj.Offset + obj.info.wave_descriptor, ...
        %       "bof");
        % user_text = fread(fid, obj.info.user_text, "char");
        % fclose(fid);
    end
end
