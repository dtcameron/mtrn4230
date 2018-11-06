classdef Block < handle
    properties
        centroidx
        centroidy
        orientation
        colour
        shape
        letter
    end
    methods
        function obj = Block()
            obj.centroidx = -1;
            obj.centroidy = -1;
            obj.orientation = -1;
            obj.shape = -1;
            obj.letter = -1;
        end
        
        function boolean = Checkifempty(obj)
            boolean = obj.centroidx == -1 && obj.centroidy == -1 && obj.orientation == -1 && obj.shape == -1 && obj.letter == -1;
        end
    end
end
