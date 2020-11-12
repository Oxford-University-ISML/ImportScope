%% This file is designed to read Tektronix binary (.isf) files. 
% You should run the ImportTek function with no input.
% The output will be a struct containg file information, time series, and voltage. 
% Any issues contact Liam.

function waveform = ImportTekISF
%% Initialising Locations & Waveform Variables and opening the binary file.
[filename,pathname] = uigetfile('*');
filename = [pathname filename];
clearvars pathname

fid = fopen(filename,'r'); % Opening the file that has been selected

waveform = struct(); %Building the waveform struct
locations = struct(); % building the locations struct, this is used for working out where to read the data in the file, locations found by Liam on 4054 isf file, could vary scope to scope as no specific format for tek scopes.

%% Reading in the opening 1000 bytes, converting to character and then finding the endian-ness

data = fread(fid,1000,'*char')';
locations.byte_order = find_location('BYT_O');
waveform.information.byte_order = data(locations.byte_order.start:locations.byte_order.start+locations.byte_order.length);

%% Closing then reopening the file with the correct endianness

fclose(fid);
if strcmp(waveform.information.byte_order,'MSB') % if most significant byte first then big-endian
    fopen(filename,'r','ieee-be');
elseif strcmp(waveform.information.byte_order,'LSB') % if least significant bye first then little-endian
    fopen(filename,'r','ieee-le');
else % if its neither of these then something has gone very wrong
    waveform = NaN;
    disp('WAVEFORM NOT IMPORTED CORRECTLY, PLEASE SAFE AS .CSV & SNED .ISF TO LIAM.')
    return
end
clearvars filename %not needed anymore so saving RAM

%% Importing the header information first getting lcoations then pulling the information

get_locations
get_informations
clean_strings

clearvars locations

%% Finding the start fo the data array and then calculating the no of points in said array
fseek(fid,regexp(data,'#','once'),'bof');

clearvars data 
no_of_points = str2double(fread(fid,1,'*char'));
no_of_points = str2double(fread(fid,no_of_points,'*char')');

if ~waveform.information.no_of_points * waveform.information.bytes_per_point == no_of_points || ~waveform.information.bits_per_point/8 == waveform.information.bytes_per_point
    waveform = NaN;
    disp('WAVEFORM NOT IMPORTED CORRECTLY, PLEASE SAFE AS .CSV & SNED .ISF TO LIAM.')
    return
end
clearvars -except fid waveform

%% Reading the Curve data
if waveform.information.bytes_per_point == 1
    waveform.voltage = fread(fid,waveform.information.no_of_points,'int8');
elseif waveform.information.bytes_per_point == 2
    waveform.voltage = fread(fid,waveform.information.no_of_points,'int16');
else
    waveform = NaN;
end

%% Creating the time and voltage fields.
waveform.voltage = waveform.information.vertical_zero + waveform.information.vertical_scale_factor * (waveform.voltage - waveform.information.vertical_offset);
waveform.time = waveform.information.horizontal_interval * ((1:waveform.information.no_of_points)' - waveform.information.trigger_point_offset);

%% Cleaning the information struct
clean_information_struct

%% Checking at the end of the file
fread(fid,1); %sometimes need to read off the end of file for some reason
if ~feof(fid) %checking to ensure we are at the end of the file (we should be)
    waveform = NaN;
    disp('WAVEFORM NOT IMPORTED CORRECTLY, PLEASE SAFE AS .CSV & SNED .ISF TO LIAM.')
    return
end

%% packaging for output

fclose(fid);
clearvars ans fid

%% functions nested to make the code easier to read
    function get_locations
        locations.no_of_points              = find_location('NR_P');
        locations.bytes_per_point           = find_location('BYT_N');
        locations.bits_per_point            = find_location('BIT_N');
        locations.encoding                  = find_location('ENC');
        locations.binary_format             = find_location('BN_F');
        locations.byte_order                = find_location('BYT_O');
        locations.waveform_identifier       = find_location('WFI');
        locations.point_format              = find_location('PT_F');
        locations.horizontal_unit           = find_location('XUN');
        locations.horizontal_interval       = find_location('XIN');
        locations.horizontal_zero           = find_location('XZE');
        locations.trigger_point_offset      = find_location('PT_O');
        locations.vertical_unit             = find_location('YUN');
        locations.vertical_scale_factor     = find_location('YMU');
        locations.vertical_offset           = find_location('YOF');
        locations.vertical_zero             = find_location('YZE');
        locations.vertical_scale            = find_location('VSCALE');
        locations.horizontal_scale          = find_location('HSCALE');
        locations.vertical_position_unknown = find_location('VPOS');
        locations.vertical_offset_unknown   = find_location('VOFFSET');
        locations.horizontal_delay_unknown  = find_location('HDELAY');
    end
    function [location] = find_location(string)
        location = struct();
        location.start = regexp(data,string,'once'); %finding the start of the entry
        location.start = location.start + regexp(data(location.start:end),' ','once'); % finding the space in between entry and value
        location.length = regexp(data(location.start:end),';','once')-2;
    end
    
    function get_informations
        waveform.information.no_of_points              = str2double(get_information(locations.no_of_points));
        waveform.information.bytes_per_point           = str2double(get_information(locations.bytes_per_point));
        waveform.information.bits_per_point            = str2double(get_information(locations.bits_per_point));
        waveform.information.encoding                  = get_information(locations.encoding);
        waveform.information.binary_format             = get_information(locations.binary_format);
        waveform.information.byte_order                = get_information(locations.byte_order);
        waveform.information.waveform_identifier       = get_information(locations.waveform_identifier);
        waveform.information.point_format              = get_information(locations.point_format);
        waveform.information.horizontal_unit           = get_information(locations.horizontal_unit);
        waveform.information.horizontal_interval       = str2double(get_information(locations.horizontal_interval));
        waveform.information.horizontal_zero           = str2double(get_information(locations.horizontal_zero));
        waveform.information.trigger_point_offset      = str2double(get_information(locations.trigger_point_offset));
        waveform.information.vertical_unit             = get_information(locations.vertical_unit);
        waveform.information.vertical_scale_factor     = str2double(get_information(locations.vertical_scale_factor));
        waveform.information.vertical_offset           = str2double(get_information(locations.vertical_offset));
        waveform.information.vertical_zero             = str2double(get_information(locations.vertical_zero));
        waveform.information.vertical_scale            = str2double(get_information(locations.vertical_scale));
        waveform.information.horizontal_scale          = str2double(get_information(locations.horizontal_scale));
        waveform.information.vertical_position_unknown = get_information(locations.vertical_offset_unknown);
        waveform.information.horizontal_delay_unknown  = get_information(locations.horizontal_delay_unknown);
    end
    function [out] = get_information(location)
        out = data(location.start:location.start+location.length);
    end

    function clean_strings
        waveform.information.waveform_identifier    = regexprep(waveform.information.waveform_identifier,'"','');
        waveform.information.horizontal_unit        = regexprep(waveform.information.horizontal_unit,'"','');
        waveform.information.vertical_unit          = regexprep(waveform.information.vertical_unit,'"','');
    end
    function clean_information_struct
        %% Removing feilds containing information needed by the end user
        waveform.information = rmfield(waveform.information,'byte_order');
        waveform.information = rmfield(waveform.information,'bits_per_point');
        waveform.information = rmfield(waveform.information,'encoding');
        waveform.information = rmfield(waveform.information,'binary_format');
        waveform.information = rmfield(waveform.information,'point_format');
        waveform.information = rmfield(waveform.information,'horizontal_zero');
        waveform.information = rmfield(waveform.information,'trigger_point_offset');
        waveform.information = rmfield(waveform.information,'vertical_offset');
        waveform.information = rmfield(waveform.information,'vertical_zero');
        waveform.information = rmfield(waveform.information,'vertical_scale');
        waveform.information = rmfield(waveform.information,'horizontal_scale');
        waveform.information = rmfield(waveform.information,'vertical_position_unknown');
        waveform.information = rmfield(waveform.information,'horizontal_delay_unknown');
        
        %% Changing field name to match horizontal feilds
        waveform.information.vertical_interval = waveform.information.vertical_scale_factor;
        waveform.information = rmfield(waveform.information,'vertical_scale_factor');
        
    end

end