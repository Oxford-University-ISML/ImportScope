function s = text(fid, addr)

% Move to the address listed in relation to the beginning of the file
fseek(fid, addr, "bof");

% Read the next 16 characters of the line (all strings in lecroy binary file are 16 characters long)
s = string(deblank(fgets(fid, 16)));
end