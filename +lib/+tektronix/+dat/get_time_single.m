function [time, error] = get_time_single(obj)
time  = lib.tektronix.dat.get_time(obj);
time  = single(time);
error = double(eps(time(end))) / obj.info.HorizontalInterval;
end
