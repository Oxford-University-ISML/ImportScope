function time = get_time(obj)
    npts = obj.info.no_of_points;
    offs = obj.info.trigger_point_offset;
    scle = obj.info.horizontal_interval;
    xzer = obj.info.horizontal_zero;
    time = (1:npts)' - 1 - offs;
    time = time * scle + xzer;

end