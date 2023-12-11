function t = time(fid, Addr)
    fseek(fid, Addr, "bof");
    
    seconds	= fread(fid, 1, "float64");
    minutes	= fread(fid, 1, "int8");
    hours	= fread(fid, 1, "int8");
    days	= fread(fid, 1, "int8");
    months	= fread(fid, 1, "int8");
    year	= fread(fid, 1, "int16");
    
    t=sprintf("%i.%i.%i, %i:%i:%2.0f", days, months, year, hours, minutes, seconds);
end
        