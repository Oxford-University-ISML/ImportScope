function [voltage, error]   = get_voltage_single(obj)
    arguments
        obj (1,1) scopetrace
    end
    
    voltage = lib.tektronix.isf.get_voltage(obj);
    voltage = single(voltage);
    
    error = double(eps(max(abs(voltage))));
    error = error / obj.info.vertical_scale_factor;
end
