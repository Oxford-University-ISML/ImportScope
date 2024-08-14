function get_info(obj)
% Locations found by Liam on 4054 isf file, could vary scope to scope as no specific format for tek scopes.

fid = fopen(obj.path, "r");
hdr = char(fread(fid, 1000, "uchar")');
obj.locs.byte_order = find_loc(hdr, "BYT_O");
obj.info.byte_order      = read_loc(hdr, obj.locs.byte_order);
fclose(fid);

obj.locs.no_of_points              = find_loc(hdr, "NR_P"   );
obj.locs.bytes_per_point           = find_loc(hdr, "BYT_N"  );
obj.locs.bits_per_point            = find_loc(hdr, "BIT_N"  );
obj.locs.encoding                  = find_loc(hdr, "ENC"    );
obj.locs.binary_format             = find_loc(hdr, "BN_F"   );
obj.locs.byte_order                = find_loc(hdr, "BYT_O"  );
obj.locs.waveform_identifier       = find_loc(hdr, "WFI"    );
obj.locs.point_format              = find_loc(hdr, "PT_F"   );
obj.locs.horizontal_unit           = find_loc(hdr, "XUN"    );
obj.locs.horizontal_interval       = find_loc(hdr, "XIN"    );
obj.locs.horizontal_zero           = find_loc(hdr, "XZE"    );
obj.locs.trigger_point_offset      = find_loc(hdr, "PT_O"   );
obj.locs.vertical_unit             = find_loc(hdr, "YUN"    );
obj.locs.vertical_scale_factor     = find_loc(hdr, "YMU"    );
obj.locs.vertical_offset           = find_loc(hdr, "YOF"    );
obj.locs.vertical_zero             = find_loc(hdr, "YZE"    );
obj.locs.vertical_scale            = find_loc(hdr, "VSCALE" );
obj.locs.horizontal_scale          = find_loc(hdr, "HSCALE" );
obj.locs.vertical_position_unknown = find_loc(hdr, "VPOS"   );
obj.locs.vertical_offset_unknown   = find_loc(hdr, "VOFFSET");
obj.locs.horizontal_delay_unknown  = find_loc(hdr, "HDELAY" );

obj.info.no_of_points              = str2double(read_loc(hdr, obj.locs.no_of_points));
obj.info.bytes_per_point           = str2double(read_loc(hdr, obj.locs.bytes_per_point));
obj.info.bits_per_point            = str2double(read_loc(hdr, obj.locs.bits_per_point));
obj.info.encoding                  =     string(read_loc(hdr, obj.locs.encoding));
obj.info.binary_format             =     string(read_loc(hdr, obj.locs.binary_format));
obj.info.byte_order                =     string(read_loc(hdr, obj.locs.byte_order));
obj.info.waveform_identifier       =     string(read_loc(hdr, obj.locs.waveform_identifier));
obj.info.point_format              =     string(read_loc(hdr, obj.locs.point_format));
obj.info.horizontal_unit           =     string(read_loc(hdr, obj.locs.horizontal_unit));
obj.info.horizontal_interval       = str2double(read_loc(hdr, obj.locs.horizontal_interval));
obj.info.horizontal_zero           = str2double(read_loc(hdr, obj.locs.horizontal_zero));
obj.info.trigger_point_offset      = str2double(read_loc(hdr, obj.locs.trigger_point_offset));
obj.info.vertical_unit             =     string(read_loc(hdr, obj.locs.vertical_unit));
obj.info.vertical_scale_factor     = str2double(read_loc(hdr, obj.locs.vertical_scale_factor));
obj.info.vertical_offset           = str2double(read_loc(hdr, obj.locs.vertical_offset));
obj.info.vertical_zero             = str2double(read_loc(hdr, obj.locs.vertical_zero));
obj.info.vertical_scale            = str2double(read_loc(hdr, obj.locs.vertical_scale));
obj.info.horizontal_scale          = str2double(read_loc(hdr ,obj.locs.horizontal_scale));
obj.info.vertical_position_unknown = str2double(read_loc(hdr, obj.locs.vertical_offset_unknown));
obj.info.horizontal_delay_unknown  = str2double(read_loc(hdr, obj.locs.horizontal_delay_unknown));

obj.info.waveform_identifier = regexprep(obj.info.waveform_identifier,"""","");
obj.info.horizontal_unit     = regexprep(obj.info.horizontal_unit,    """","");
obj.info.vertical_unit       = regexprep(obj.info.vertical_unit,      """","");

obj.valid_import = true;
end

function loc = find_loc(data, string)
loc.start  = regexp(data, string, "once"); %finding the start of the entry
loc.start  = loc.start + regexp(data(loc.start:end), " ", "once"); % finding the space in between entry and value
loc.length = regexp(data(loc.start:end), ";", "once") - 2;
end
function out = read_loc(data, location)
out = data(location.start:location.start+location.length);
end
