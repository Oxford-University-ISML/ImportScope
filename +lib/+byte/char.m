function c = char(fid, Addr, No_of_char, DoNotConvert)
    fseek(fid, Addr, "bof");
    if nargin < 4
        DoNotConvert = "Convert";
    end
    c = fread(fid, No_of_char, "char")';
    if ~strcmp(DoNotConvert, "DoNotConvert")
        c = string(char(c));
    end
end