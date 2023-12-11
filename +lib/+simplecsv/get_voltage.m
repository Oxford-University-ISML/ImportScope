function voltage = get_voltage(obj)
    keyboard % TODO Check the path construction below.
    path = [obj.path(1:end-10), "CompressedVoltage"];
    
    if ~isfile(path)
        % Read from file and extract 2nd column.
        voltage = readmatrix(obj.path, FileType = "text");
        voltage = voltage(:, 2);

        % Write to compressed format.
        lib.compressed_waveform.write_voltage(path, voltage)
    else
        % Read from compressed format.
        voltage = lib.compressed_waveform.read_voltage(path, obj.info.NumberOfPoints);
    end
end