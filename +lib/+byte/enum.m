function e = enum(fid, Addr)
    fseek(fid, Addr, "bof");
    e = fread(fid, 1, "int16");
end
