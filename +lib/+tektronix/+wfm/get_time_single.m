function [time, error] = get_time_single(obj)
    time  = lib.tektronix.wfm.get_time(obj);
    time  = single(time);
    error = double(eps(time(end))) / obj.info.horizontal_resolution;
end
