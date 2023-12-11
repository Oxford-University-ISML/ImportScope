function f = flot(fid, Addr)
    fseek(fid, Addr, "bof");
    f = fread(fid, 1, "float");
end
        