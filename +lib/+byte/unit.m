function s = unit(fid, Addr)
    % Move to the address listed in relation to the beginning of the file.
    fseek(fid, Addr, "bof");

    % Read the next 48 characters (all strings in lecroy .trc file are 16 characters long)
    s = string(deblank(fgets(fid, 48))); 
end
