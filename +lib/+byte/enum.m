function e = enum(fid, Addr)
    % Move to the address listed in relation to the beginning of the file.
    fseek(fid, Addr, "bof");
    
    e = fread(fid, 1, "int16");
end
