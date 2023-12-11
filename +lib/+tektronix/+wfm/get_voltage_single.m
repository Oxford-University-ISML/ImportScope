function [voltage, error] = get_voltage_single(obj)
    voltage = lib.tektronix.wfm.get_voltage(obj);
    voltage = single(voltage);
    error = double(eps(max(abs(voltage)))) / obj.info.vertical_resolution;
end
