pragma solidity ^0.8.0;

contract GameOfLife {
    uint256 public width;
    uint256 public height;
    bool[][] public grid;

    event GridInitialized(uint256 width, uint256 height);
    event CellActivated(uint256 xCoord, uint256 yCoord);
    event NextIterationCompleted(bool[][] newGrid);

    constructor(uint256 _width, uint256 _height) {
        require(_width > 0 && _height > 0, "Width and height sizes must be greater than 0");
        width = _width;
        height = _height;
        grid = new bool[][](width);
        for (uint256 i = 0; i < width; i++) {
            grid[i] = new bool[](height);
        }
        emit GridInitialized(width, height);
    }

    function getGrid() public view returns (bool[][] memory) {
        return grid;
    }

    function activateCell(uint256 xCoord, uint256 yCoord) public {
        require(xCoord < width && yCoord < height, "Invalid coordinates");
        grid[xCoord][yCoord] = true;
        emit CellActivated(xCoord, yCoord);
    }

    function activateCells(uint256[] memory xCoords, uint256[] memory yCoords) public {
        require(xCoords.length == yCoords.length, "Coordinate arrays must have the same length");

        for (uint256 i = 0; i < xCoords.length; i++) {
            activateCell(xCoords[i], yCoords[i]);
        }
    }

    function nextIteration() public {
        bool[][] memory newGrid = new bool[][](width);
        for (uint256 i = 0; i < width;) {
            newGrid[i] = new bool[](height);
            unchecked {
                ++i;
            }
        }

        for (uint256 xCoord = 0; xCoord < width;) {
            for (uint256 yCoord = 0; yCoord < height;) {
                uint8 neighbors = countNeighbors(xCoord, yCoord);

                if (grid[xCoord][yCoord]) {
                    newGrid[xCoord][yCoord] = neighbors == 2 || neighbors == 3;
                } else {
                    newGrid[xCoord][yCoord] = neighbors == 3;
                }
                unchecked {
                    ++yCoord;
                }
            }
            unchecked {
                ++xCoord;
            }
        }

        grid = newGrid;
        emit NextIterationCompleted(grid);
    }

    function countNeighbors(uint256 xCoord, uint256 yCoord) private view returns (uint8) {
        uint8 count = 0;
        for (int256 i = -1; i <= 1;) {
            for (int256 j = -1; j <= 1;) {
                // Skip the current cell itself
                if (i == 0 && j == 0) continue;

                int256 newX = int256(xCoord) + i;
                int256 newY = int256(yCoord) + j;

                if (
                    newX >= 0 && newY >= 0 && uint256(newX) < width && uint256(newY) < height
                        && grid[uint256(newX)][uint256(newY)]
                ) {
                    count++;
                }

                unchecked {
                    ++j;
                }
            }
            unchecked {
                ++i;
            }
        }

        return count;
    }
}
