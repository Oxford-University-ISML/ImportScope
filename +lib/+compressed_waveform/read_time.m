function times      = read_time(path)
    arguments
        path (1,1) string {mustBeFile}
    end
    % TimeValues [4 Element Array]
    % Value 1: StartTime Float64
    % Value 2: StopTime  Float64
    % Value 3: Interval  Float64
    % Value 4: NumPts    uint32
    times = nan(4, 1);
    fid = fopen(path, "r");
    times(1) = fread(fid, 1, "float64=>double");
    times(2) = fread(fid, 1, "float64=>double");
    times(3) = fread(fid, 1, "float64=>double");
    times(4) = fread(fid, 1, "uint32=>double" );
    fclose(fid);
end