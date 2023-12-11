function s = ssht(fid, Addr)
% Read signed short
fseek(fid, Addr, "bof");
s = fread(fid, 1, "short");
end
