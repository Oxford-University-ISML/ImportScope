function write_voltage(path, voltage)
    arguments
        path    (1,1) string
        voltage (:,1) double
    end
    
    %% Identify the unique voltages and how many there are
    lvls = unique(voltage);
    nlvl = numel(lvls);

    %% If less that 2^8 or 2^16 then store voltage as uint8 or uint16 map.
    if nlvl <= 255
        bytes = 1;
        
    elseif nlvl <= 65535
        bytes = 2;
    
    else
        eid = "compressedvoltage:write_error";
        msg = "There are more than 65535 unique values of voltage in " ...
            + "this signal, more than can be encoded with 16-bit " ...
            + "precision, take this waveform to Liam for debugging.";
        throwAcCaller(MException(eid, msg))
        return
    end
    
    %% Create the format tag then the array for mapped data
    fmt = "uint" + 8 * bytes;
    vec = zeros(size(voltage), fmt);

    %% For each uniqe voltage, tag the points matching it.
    for i = 1:nlvl
        vec(voltage == lvls(i)) = i;
    end
    
    %% Writing the file
    fid = fopen(path, "w");
    fwrite(fid, bytes, "uint8"  ); % How many bytes per point were needed.
    fwrite(fid, nlvl , "uint32" ); % How many float64 terms are following.
    fwrite(fid, lvls , "float64"); % Each float64 is assigned to the map index of itself.
    fwrite(fid, vec  , fmt      ); % The curve buffer in uint8 or uint16 form.
    fclose(fid);
end
