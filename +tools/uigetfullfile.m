function out = uigetfullfile()
    [file, path] = uigetfile("*");
    
    out = fullfile(path, file);

    if ~isfile(out)
        eid = "uigetfullfile:no_selection";
        msg = "The fullfile processed output from uigetfile was: """ + out + """ which is not a file.";
        throwAsCaller(MException(eid, msg))
    end
end