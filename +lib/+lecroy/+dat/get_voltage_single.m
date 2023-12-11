function [voltage, error] = get_voltage_single(obj)
    voltage = single(lib.lecroy.dat.get_voltage(obj));
    error = double(eps(max(abs(voltage)))) / min(abs(diff(unique(voltage))));
end
