function get_info(obj)
    arguments
        obj (1,1) scopetrace
    end
    
    path = obj.path.insertBefore(".", "_hdr");
    
    if ~isfile(path)
        eid = "importscope:tektronix:dat:no_header";
        msg = "The tektronix .dat filetype should be accompanied by a " + ...
              "_hdr.dat file that contains critical information. Find it!";
        throwAsCaller(MException(eid, msg))
    end
    
    obj.header_path = path;
    
    fid = fopen(obj.header_path);
    hdr = fscanf(fid, "%f");
    fclose(fid);
    
    obj.info.NumberOfPoints       = hdr(1);
    obj.info.HorizontalInterval   = hdr(2);
    obj.info.TriggerPositionIdx   = hdr(3);
    obj.info.FractionalTriggerPos = hdr(4);
    obj.info.StartTime            = hdr(5);
    obj.info.EndTime              = hdr(5) + hdr(2) * hdr(1) - hdr(2);
    
    obj.valid_import = true;
end
