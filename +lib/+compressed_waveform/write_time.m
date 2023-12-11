function              write_time(path, time)
    arguments
        path (1,1) string
        time (4,1) double
    end
    % TimeValues [4 Element Array]
    % Value 1: StartTime Float64
    % Value 2: StopTime  Float64
    % Value 3: Interval  Float64
    % Value 4: NumPts    uint32
    fid = fopen(path, "w");
    fwrite(fid, time(1), "float64");
    fwrite(fid, time(2), "float64");
    fwrite(fid, time(3), "float64");
    fwrite(fid, time(4), "uint32" );
    fclose(fid);
end
