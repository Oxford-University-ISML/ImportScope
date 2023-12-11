function get_info(obj)
    arguments
        obj (1,1) scopetrace
    end
    keyboard % TODO Check the line below and how it should link onto compressed aliases.
    path = [obj.path(1:end-10),"_SimpleCSV_CompressedTime"]; 
    
    if ~isfile(path)
        % Read the csv and take out only the first row.
        tmp = readmatrix(obj.path, FileType = "text");
        tmp = tmp(:, 1);
        
        % Get key metrics for the csv.
        tmp = [min(tmp), ...
               max(tmp), ...
               numel(tmp), ... 
               mean(diff(tmp))];
        
        % write to file
        lib.compressed_waveform.write_time(path, tmp)
    else
        % read key metrics from file
        tmp = lib.compressed_waveform.read_time(path);
    end

    % pass into obj.info
    obj.info.StartTime          = tmp(1);
    obj.info.EndTime            = tmp(2);
    obj.info.NumberOfPoints     = tmp(3);
    obj.info.HorizontalInterval = tmp(4);
    
    obj.valid_import = true;
end
