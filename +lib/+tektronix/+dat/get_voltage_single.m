function [voltage, error] = get_voltage_single(obj)
arguments
    obj (1,1) ScopeTrace
end
voltage = single(obj.tektronix.dat.get_voltage);
error = double(eps(max(abs(voltage)))) / min(abs(diff(unique(voltage))));
end
