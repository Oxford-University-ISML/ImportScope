function wfm = waveform(obj)
    %waveform - Get the waveform data from the object.
    %
    % INPUT     obj - The object.
    %
    % OUTPUT    Waveform - A struct containing time and voltage
    %                      values for the raw data in double
    %                      precision.
    %
    if obj.valid_import
        switch obj.TraceType
            case "LeCroy (.trc)"
                wfm.time    = lib.lecroy.trc.get_time(   obj);
                wfm.voltage = lib.lecroy.trc.get_voltage(obj);
            case "LeCroy (.dat)"
                wfm.time    = lib.lecroy.dat.get_time(   obj);
                wfm.voltage = lib.lecroy.dat.get_voltage(obj);
            case "Tektronix (.wfm)"
                wfm.time    = lib.tektronix.wfm.get_time(   obj);
                wfm.voltage = lib.tektronix.wfm.get_voltage(obj);
            case "Tektronix (.isf)"
                wfm.time    = lib.tektronix.isf.get_time(   obj);
                wfm.voltage = lib.tektronix.isf.get_voltage(obj);
            case "Tektronix (.dat)"
                wfm.time    = lib.tektronix.dat.get_time(   obj);
                wfm.voltage = lib.tektronix.dat.get_voltage(obj);
            case "Simple CSV (.SimpleCSV)"
                wfm.time    = lib.simplecsv.get_time(   obj);
                wfm.voltage = lib.simplecsv.get_voltage(obj);
        end

    else
        eid = "scopetrace:invalid_import";
        msg = "Cannot create a wavefrom struct from an invalid import.";
        throwAsCaller(MException(eid, msg))
        
    end
end