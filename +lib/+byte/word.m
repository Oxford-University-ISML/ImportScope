function w = word(fid, Addr)
    fseek(fid, Addr, "bof");
    w = fread(fid, 1, "int16");
end
