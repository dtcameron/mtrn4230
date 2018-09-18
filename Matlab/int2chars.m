function chars = int2chars(in)

    last = mod(in,256);
    first = floor((in-last)/256);
    chars = [char(first), char(last)];

end