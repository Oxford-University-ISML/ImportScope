function get_type(obj)
    
    switch obj.path.extractAfter(".")
        case "trc"
            obj.type = "LeCroy (.trc)";
        case "isf"
            obj.type = "Tektronix (.isf)";
        case "wfm"
            obj.type = "Tektronix (.wfm)";
        case "dat"
            obj.type = decipher_dat_type(obj.path);
        case "SimpleCSV"
            obj.type = "Simple CSV (.SimpleCSV)";
        otherwise
            obj.type = "Unsupported Trace Type";
    end
end