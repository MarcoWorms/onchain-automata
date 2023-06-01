pragma solidity ^0.8.0;

contract GameOfLife {
    // State variables to store the grid size and the grid itself
    uint public x;
    uint public y;
    bool[][] public grid;
    
    // Events to be emitted when the grid is initialized, a cell is activated, and an iteration is completed
    event GridInitialized(uint width, uint height);
    event CellActivated(uint xCoord, uint yCoord);
    event NextIterationCompleted(bool[][] newGrid);

    // Constructor to initialize the grid with the specified size
    constructor(uint _width, uint _height) {
        require(_width > 0 && _height > 0, "Width and height sizes must be greater than 0");
        width = _width;
        height = _height;
        grid = new bool[][](width);
        for (uint i = 0; i < width; i++) {
            grid[i] = new bool[](height);
        }
        emit GridInitialized(width, height);
    }

    // Function to activate a single cell in the grid
    function activateCell(uint xCoord, uint yCoord) public {
        require(xCoord < x && yCoord < y, "Invalid coordinates");
        grid[xCoord][yCoord] = true;
        emit CellActivated(xCoord, yCoord);
    }

    // Function to activate multiple cells in the grid at once
    function activateCells(uint[] memory xCoords, uint[] memory yCoords) public {
        require(xCoords.length == yCoords.length, "Coordinate arrays must have the same length");

        for (uint i = 0; i < xCoords.length; i++) {
            activateCell(xCoords[i], yCoords[i]);
        }
    }

    // Function to compute the next iteration of the grid based on Conway's Game of Life rules
    function nextIteration() public {
        // Create a new grid to store the updated state
        bool[][] memory newGrid = new bool[][](x);
        for (uint i = 0; i < x; i++) {
            newGrid[i] = new bool[](y);
        }

        // Iterate through each cell in the grid
        for (uint xCoord = 0; xCoord < x; xCoord++) {
            for (uint yCoord = 0; yCoord < y; yCoord++) {
                // Count the number of live neighbors for the current cell
                uint8 neighbors = countNeighbors(xCoord, yCoord);

                // Apply the rules of Conway's Game of Life to update the new grid
                if (grid[xCoord][yCoord]) {
                    newGrid[xCoord][yCoord] = neighbors == 2 || neighbors == 3;
                } else {
                    newGrid[xCoord][yCoord] = neighbors == 3;
                }
            }
        }

        // Update the grid state with the new grid
        grid = newGrid;
        emit NextIterationCompleted(grid);
    }

    // Function to count the number of live neighbors for a given cell
    function countNeighbors(uint xCoord, uint yCoord) private view returns (uint8) {
        uint8 count = 0;
        // Iterate through the neighboring cells
        for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
                // Skip the current cell itself
                if (i == 0 && j == 0) continue;

                // Calculate the coordinates of the neighboring cell
                uint newX = xCoord + uint(i);
                uint newY = yCoord + uint(j);

                // Check if the neighboring cell is within the grid boundaries and is alive
                if (newX < x && newY < y && grid[newX][newY]) {
                    count++;
                }
            }
        }

        return count;
    }
}
