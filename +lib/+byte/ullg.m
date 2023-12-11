function l = ullg(fid, Addr) % TODO Check me Ulong long == uint64 not int64??
    fseek(fid, Addr, "bof");
    l = fread(fid, 1, "int64");
end
        