function get_info(obj)
    
    path = obj.path.extractBefore(".") + "CompressedTime";
    
    if ~isfile(path)
        fid = fopen(obj.path, "r");
        tmp = fscanf(fid, "%f %*f");
        fclose(fid);

        obj.info.StartTime          = tmp(1);
        obj.info.EndTime            = tmp(end);
        obj.info.NumberOfPoints     = numel(tmp);
        obj.info.HorizontalInterval = mean(diff(tmp));

        lib.compressed_waveform.write_time(path, ...
                                           [obj.info.StartTime, ...
                                            obj.info.EndTime, ...
                                            obj.info.HorizontalInterval, ...
                                            obj.info.NumberOfPoints]);

    else
        tmp = lib.compressed_waveform.read_time(path);
        
        obj.info.StartTime          = tmp(1);
        obj.info.EndTime            = tmp(2);
        obj.info.HorizontalInterval = tmp(3);
        obj.info.NumberOfPoints     = tmp(4);
        
    end
    
    obj.valid_import = true;
end
