function time = get_time(obj)
    
    switch obj.raw_info.Waveform_static_file_information.Byte_order_verification
        case 61680 %equivalent to hexidecimal 0xF0F0, which is big endian
            fid = fopen(obj.path,"r","ieee-be"); %reopening file with big endian format
        case 3855 %equivalent to hexidecimal 0x0F0F, which is little endian
            fid = fopen(obj.path,"r","ieee-le"); %reopening file with little endian format
        otherwise
            time = "Invalid Import";
            return
    end

    npts = obj.raw_info.Waveform_header.Implicit_Dimension_1.Dim_size;
    scle = obj.raw_info.Waveform_header.Implicit_Dimension_1.Dim_scale;
    offs = obj.raw_info.Waveform_header.Implicit_Dimension_1.Dim_offset;
    
    time = (1:npts) * scle + offs;
    time = time';
    
    fclose(fid);
end
