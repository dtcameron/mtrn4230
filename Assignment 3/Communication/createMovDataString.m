function data = createMovDataString(coords, quat)

    coords = ['[' strjoin(strsplit(int2str(coords)), ',') ']'];
    tQuat = ['[' strjoin(strsplit(int2str(quat)), ',') ']'];
    data = {coords tQuat};
    data = strjoin(data,'|');

end