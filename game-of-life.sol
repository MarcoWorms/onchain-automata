pragma solidity ^0.8.0;

contract GameOfLife {
    uint public rows;
    uint public columns;
    bool[][] public grid;
    
    event GridInitialized(uint rows, uint columns);
    event CellActivated(uint row, uint column);
    event NextIterationCompleted(bool[][] newGrid);

    constructor(uint _rows, uint _columns) {
        require(_rows > 0 && _columns > 0, "Row and column sizes must be greater than 0");
        rows = _rows;
        columns = _columns;
        grid = new bool[][](rows);
        for (uint i = 0; i < rows; i++) {
            grid[i] = new bool[](columns);
        }
        emit GridInitialized(rows, columns);
    }

    function activateCell(uint row, uint column) public {
        require(row < rows && column < columns, "Invalid coordinates");
        grid[row][column] = true;
        emit CellActivated(row, column);
    }

    function activateCells(uint[] memory rowCoords, uint[] memory colCoords) public {
        require(rowCoords.length == colCoords.length, "Coordinate arrays must have the same length");

        for (uint i = 0; i < rowCoords.length; i++) {
            activateCell(rowCoords[i], colCoords[i]);
        }
    }

    function nextIteration() public {
        bool[][] memory newGrid = new bool[][](rows);
        for (uint i = 0; i < rows; i++) {
            newGrid[i] = new bool[](columns);
        }

        for (uint row = 0; row < rows; row++) {
            for (uint column = 0; column < columns; column++) {
                uint8 neighbors = countNeighbors(row, column);

                if (grid[row][column]) {
                    newGrid[row][column] = neighbors == 2 || neighbors == 3;
                } else {
                    newGrid[row][column] = neighbors == 3;
                }
            }
        }

        grid = newGrid;
        emit NextIterationCompleted(grid);
    }

    function countNeighbors(uint row, uint column) private view returns (uint8) {
        uint8 count = 0;
        for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
                if (i == 0 && j == 0) continue;

                uint newRow = row + uint(i);
                uint newColumn = column + uint(j);

                if (newRow < rows && newColumn < columns && grid[newRow][newColumn]) {
                    count++;
                }
            }
        }

        return count;
    }
}
