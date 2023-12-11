function [time, error] = get_time_single(obj)
    time  = single(lib.lecroy.dat.get_time(obj));
    error = double(eps(time(end))) / obj.info.HorizontalInterval;
end
