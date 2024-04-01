function tf = validate(path)
    arguments (Input)
        path (1,1) string {mustBeFile}
    end
    arguments (Output)
        tf (1,1) logical
    end

    % Identify binary filetypes and SimpleCSV custom type
    if path.endsWith(".trc") || ...
       path.endsWith(".isf") || ...
       path.endsWith(".wfm") || ...
       path.endsWith(".SimpleCSV")
        tf = true;
        return
    end

    % If the filetype is a .dat file then we look to see if the 
    if path.endsWith(".dat")
        
        % Hunt for the matching CompressedTime and CompressedVoltage files that would go along with a .dat oscilloscope file
        basename = path.extractBefore(".");
        if isfile(basename + "CompressedTime") && isfile(basename + "CompressedVoltage")
            tf = true;
            return
        end

        % Last resort is to actually check the .dat file as this may 
        % just be one that has not been compressed upon import yet.
        try 
            decipher_dat_type(path);
            tf = true;
        catch
            tf = false;
        end
    end
    
end

