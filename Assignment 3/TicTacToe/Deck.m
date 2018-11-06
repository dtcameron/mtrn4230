classdef Deck < handle
    properties
        blocks

        numblocks
        
    end
    
    properties (Constant)
        maxblocks = 6;
    end
    
    
    methods
        function obj = Deck()
            obj.reset();
        end
        
        function obj = Addablock(obj,block,i)
            if obj.numblocks == obj.maxblocks
                disp('This deck has maximum possible blocks')
            end
            if obj.blocks{i}.Checkifempty
                obj.blocks(i) = {block};
            else
                disp('The position was not empty')
            end
        end
        
        function block = get(obj, i)
            if checkifemptypos(obj,i)
            disp('That location is empty')
            return;
            else
            block = obj.blocks{i};
            end
        end
        
        
        function boolean = checkifemptypos(obj, i)
        block = obj.blocks{i};
        boolean = block.Checkifempty();
        end

        function boolean = checkifempty(obj)
            boolean = obj.numblocks == 0;
        end

        
        
        function reset(obj)
            obj.blocks = cell(obj.maxblocks,1);
            
            for i = 1:obj.maxblocks
                obj.blocks(i) = {Tile()};
            end
            obj.numblocks = 0;
            
        end
    end
end
