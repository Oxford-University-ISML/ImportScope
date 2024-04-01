function typ = decipher_dat_type(path)
    arguments
        path (1,1) string
    end

    fid = fopen(path, "r");
    txt = fgetl(fid);
    fclose(fid);
    
    if contains(txt, " ")
        StringsPerLine = 2;
    else
        StringsPerLine = 1;
    end
    
    HeaderExists = isfile(path.insertBefore(".", "_hdr"));

    if      HeaderExists && StringsPerLine == 1
        typ = "Tektronix (.dat)";

    elseif ~HeaderExists && StringsPerLine == 2
        typ = "LeCroy (.dat)";

    else
        eid = "importscope:unsupportedformat";
        msg = "This file formate doesn't appear to be supported yet.";
        throwAsCaller(MException(eid, msg))
        
    end
end
