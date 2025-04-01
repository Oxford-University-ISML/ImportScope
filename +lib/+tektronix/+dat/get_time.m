function time = get_time(obj)
    time = linspace(obj.info.StartTime, ...
                    obj.info.EndTime, ...
                    obj.info.NumberOfPoints)';
end
