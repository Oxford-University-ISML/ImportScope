function time = get_time(obj)

npts = obj.info.wave_array_count - 1; % Index in trc starts at 0
scle = obj.info.horizontal_interval;
offs = obj.info.horizontal_offset;

time = (0:npts) * scle + offs;
time = time';

end
