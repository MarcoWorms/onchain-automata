pragma solidity ^0.8.0;

contract GameOfLife {
    uint public gridSize;
    bool[][] public grid;
    
    event GridInitialized(uint gridSize);
    event DotInserted(uint x, uint y);
    event NextIterationCompleted(bool[][] newGrid);

    constructor(uint _gridSize) {
        require(_gridSize > 0, "Grid size must be greater than 0");
        gridSize = _gridSize;
        grid = new bool[][](gridSize);
        for (uint i = 0; i < gridSize; i++) {
            grid[i] = new bool[](gridSize);
        }
        emit GridInitialized(gridSize);
    }

    function insertDot(uint x, uint y) public {
        require(x < gridSize && y < gridSize, "Invalid coordinates");
        grid[x][y] = true;
        emit DotInserted(x, y);
    }

    function insertDots(uint[] memory xs, uint[] memory ys) public {
        require(xs.length == ys.length, "Coordinate arrays must have the same length");

        for (uint i = 0; i < xs.length; i++) {
            insertDot(xs[i], ys[i]);
        }
    }

    function nextIteration() public {
        bool[][] memory newGrid = new bool[][](gridSize);
        for (uint i = 0; i < gridSize; i++) {
            newGrid[i] = new bool[](gridSize);
        }

        for (uint x = 0; x < gridSize; x++) {
            for (uint y = 0; y < gridSize; y++) {
                uint8 neighbors = countNeighbors(x, y);

                if (grid[x][y]) {
                    newGrid[x][y] = neighbors == 2 || neighbors == 3;
                } else {
                    newGrid[x][y] = neighbors == 3;
                }
            }
        }

        grid = newGrid;
        emit NextIterationCompleted(grid);
    }

    function countNeighbors(uint x, uint y) private view returns (uint8) {
        uint8 count = 0;
        for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
                if (i == 0 && j == 0) continue;

                uint newX = x + uint(i);
                uint newY = y + uint(j);

                if (newX < gridSize && newY < gridSize && grid[newX][newY]) {
                    count++;
                }
            }
        }

        return count;
    }
}
