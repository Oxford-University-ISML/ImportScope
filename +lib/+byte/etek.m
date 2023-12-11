function e = etek(       fid, Addr)
% Read tektronix enum
    fseek(fid, Addr, "bof");
    e = fread(fid, 1, "int");
end