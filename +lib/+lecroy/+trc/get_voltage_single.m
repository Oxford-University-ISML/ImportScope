function [voltage, error] = get_voltage_single(obj)
    arguments
        obj (1,1) scopetrace
    end
    
    voltage = lib.lecroy.trc.get_voltage(obj);
    voltage = single(voltage);
    
    error = double(eps(max(abs(voltage))));
    error = error / obj.info.vertical_gain;
end
