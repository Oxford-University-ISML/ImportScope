function voltage = get_voltage(obj)

% Working out if the file is formatted big-endidan or little-endian
switch obj.raw_info.Waveform_static_file_information.Byte_order_verification
    
    % 61680 == 0xF0F0 == B-E
    case 61680 
        fmt = "ieee-be"; % Specify B-E format
    
    % 3855 == 0x0F0F == L-E
    case 3855 
        fmt = "ieee-le"; % Specify L-E format
    
    otherwise
        voltage = "Invalid Import";
        return
end

fid = fopen(obj.path, "r", fmt);

% Reading the buffer from the file.
offs = obj.raw_info.Waveform_static_file_information.Byte_offset_to_beginning_of_curve_buffer;
npts = obj.raw_info.Waveform_header.Implicit_Dimension_1.Dim_size;
fmt  = obj.raw_info.Waveform_header.Explicit_Dimension_1.Format;
voltage = lib.byte.type(fid, offs, npts, fmt);

% Scaling and offsetting signal into double format
scle = obj.raw_info.Waveform_header.Explicit_Dimension_1.Dim_scale;
offs = obj.raw_info.Waveform_header.Explicit_Dimension_1.Dim_offset;
voltage = voltage * scle + offs;

fclose(fid);
end
