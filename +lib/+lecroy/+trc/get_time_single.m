function [time, error] = get_time_single(obj)
    arguments
        obj (1,1) scopetrace
    end
    
    time  = lib.lecroy.try.get_time(obj);
    time  = single(time);

    error = double(eps(time(end)));
    error = error / obj.info.horizontal_interval;
end
