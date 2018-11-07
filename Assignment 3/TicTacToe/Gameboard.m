classdef Gameboard < handle
    properties
        elements
        
        elementsxo
        
        numblocks
    end
    properties (Constant)
        gridsize = 3;
    end
    methods
        function obj = Gameboard()
            Gameboard.reset();
        end
        
        function reset(obj)
            obj.elements = cell(obj.gridsize,obj.gridsize);
            obj.elementsxo = zeros(obj.gridsize,obj.gridsize);
            for i = 1:obj.gridsize
                for j = 1:obj.gridsize
                    obj.elements(i,j) = {Block()};
                end
            end
            obj.numblocks = 0;
        end
        
        function Addblock(obj,block,row,col,pnum)
            if isempty(block)
                disp('Block is empty');
                return;
            end
            if col < 1 || col > obj.gridSize || row < 1 || row > obj.gridSize
                disp('This is only 3x3 matrix');
                return;
            end
            obj.elements(row,col) = {block};
            if pnum == 1
            obj.elementsxo(row,col) = 1;
            elseif pnum == 2
            obj.elementsxo(row,col) = 2;
            end
            obj.numblocks = obj.numblocks + 1;
        end
        function block = Getblock(obj,row,col)
            if col < 1 || col > obj.gridSize || row < 1 || row > obj.gridSize
                 disp('This is only 3x3 matrix');
                 block = false;
                return;
            end
            block = obj.elements{row,col};
        end
        
        
        %% Checking legal moves
    end
end