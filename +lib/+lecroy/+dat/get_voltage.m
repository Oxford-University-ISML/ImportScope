function voltage = get_voltage(obj)

    path = obj.path.extractBefore(".") + "CompressedVoltage";
    
    if ~isfile(path)
        fid = fopen(obj.path);
        voltage = fscanf(fid,"%*f %f");
        fclose(fid);
        lib.compressed_waveform.write_voltage(path, voltage)
    else
        voltage = lib.compressed_waveform.read_voltage(path, obj.info.NumberOfPoints);
    end
end
