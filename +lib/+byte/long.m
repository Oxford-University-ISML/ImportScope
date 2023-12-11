function l = long(fid, Addr)
    fseek(fid, Addr, "bof");
    l = fread(fid, 1, "long");
end
