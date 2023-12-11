function s = usht(fid, Addr)
    fseek(fid, Addr, "bof");
    s = fread(fid, 1, "ushort");
end
        