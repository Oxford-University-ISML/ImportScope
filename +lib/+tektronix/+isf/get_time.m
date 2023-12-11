function time = get_time(obj)
    npts = obj.info.no_of_points;
    offs = obj.info.trigger_point_offset;
    scle = obj.info.horizontal_interval;
    time = ((1:npts)' - offs) * scle;
end