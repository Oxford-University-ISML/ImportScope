function d = dble(fid, Addr)
    fseek(fid, Addr, "bof");
    d = fread(fid, 1, "float64");
end
