function voltage = get_voltage(obj)

fid = fopen(obj.path,"r");
start_loc = char(fread(fid, 1000, "uchar")');
start_loc = regexp(start_loc, "#", "once");
fclose(fid);

fmt = struct("LSB", "ieee-le", "MSB", "ieee-be").(obj.info.byte_order);
fid = fopen(obj.path, "r", fmt);

fseek(fid, start_loc, "bof");
NoOfPoints = str2double(fread(fid, 1         , "*char")');
NoOfPoints = str2double(fread(fid, NoOfPoints, "*char")');

AltNoOfPoints = obj.info.no_of_points * obj.info.bytes_per_point;

InCorrectNumberOfPoints = AltNoOfPoints             ~= NoOfPoints;
InCorrectByteEncodings  = obj.info.bits_per_point/8 ~= obj.info.bytes_per_point;
if  InCorrectNumberOfPoints || InCorrectByteEncodings
    voltage = "Error Reading Voltage";
    fclose(fid);
    return
end

if ~ismember(obj.info.bytes_per_point, [1 2])
    fclose(fid);
    return
end

fmt = "int" + obj.info.bytes_per_point * 8;
voltage = fread(fid, obj.info.no_of_points, fmt);
        
vzro = obj.info.vertical_zero;
scle = obj.info.vertical_scale_factor;
offs = obj.info.vertical_offset;
voltage = vzro + scle * (voltage - offs);

fread(fid, 1); %sometimes need to read off the end of file for some reason
if ~feof(fid) %checking to ensure we are at the end of the file (we should be)
    voltage = "Error Reading Voltage";
    fclose(fid);
    return
end

fclose(fid);
end
