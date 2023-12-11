function voltage = read_voltage(path, npts)
    arguments
        path (1,1) string {mustBeFile}
        npts (1,1) double {mustBeInteger, mustBeNonnegative}
    end
    
    fid = fopen(path, "r");
    BytesPerPt = fread(fid, 1        , "uint8"  );
    NumLevels  = fread(fid, 1        , "uint32" );
    Levels     = fread(fid, NumLevels, "float64");
            
    switch BytesPerPt
        case 1
            voltage = fread(fid, npts, "uint8=>uint8"  );
        case 2
            voltage = fread(fid, npts, "uint16=>uint16");
    end
            
    fread(fid, 1);
    if ~feof(fid)
        return
    end
            
    voltage = Levels(voltage);
            
end
        