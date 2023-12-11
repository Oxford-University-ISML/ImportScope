function c = type( fid, Addr, No_of_elem, format)
    fseek(fid, Addr, "bof");
    c = fread(fid, No_of_elem, format);
end