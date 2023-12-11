function [time, error] = get_time_single(obj)
time  = single(lib.tektronix.isf.get_time(obj));
error = double(eps(time(end))) / obj.info.horizontal_interval;
end
