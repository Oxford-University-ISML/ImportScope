function time = get_time(obj)
    
    npts = obj.raw_info.Waveform_header.Implicit_Dimension_1.Dim_size;
    scle = obj.raw_info.Waveform_header.Implicit_Dimension_1.Dim_scale;
    offs = obj.raw_info.Waveform_header.Implicit_Dimension_1.Dim_offset;
    
    time = (1:npts) * scle + offs;
    time = time';
    
end
