import React, { useState, useEffect } from 'react';
import Web3 from 'web3';

const CONTRACT_ADDRESS = '0xAE0983F8f28C164288d94741c93486aAC954273c';
const ABI = [{"inputs":[{"internalType":"uint256","name":"_width","type":"uint256"},{"internalType":"uint256","name":"_height","type":"uint256"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"xCoord","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"yCoord","type":"uint256"}],"name":"CellActivated","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"width","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"height","type":"uint256"}],"name":"GridInitialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bool[][]","name":"newGrid","type":"bool[][]"}],"name":"NextIterationCompleted","type":"event"},{"inputs":[{"internalType":"uint256","name":"xCoord","type":"uint256"},{"internalType":"uint256","name":"yCoord","type":"uint256"}],"name":"activateCell","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256[]","name":"xCoords","type":"uint256[]"},{"internalType":"uint256[]","name":"yCoords","type":"uint256[]"}],"name":"activateCells","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getGrid","outputs":[{"internalType":"bool[][]","name":"","type":"bool[][]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"grid","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"height","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"nextIteration","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"width","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]

function EventsHistory({ events }) {
  return (
    <div>
      <h2>Events History</h2>
      <ul>
        {events.map((event, index) => (
          <li key={index}>
            {event.event === 'CellActivated'
              ? `Cell Activated at (${event.returnValues.xCoord},${event.returnValues.yCoord})`
              : 'Next Iteration Completed'}
          </li>
        ))}
      </ul>
    </div>
  );
}

function App() {
  const [web3, setWeb3] = useState(null);
  const [contract, setContract] = useState(null);
  const [grid, setGrid] = useState([]);
  const [paintGrid, setPaintGrid] = useState([]);
  const [selectedCells, setSelectedCells] = useState([]);
  const [isMouseDown, setIsMouseDown] = useState(false);
  const [isErasing, setIsErasing] = useState(false);
  const [eventsHistory, setEventsHistory] = useState([]);


  useEffect(() => {
    async function connectWallet() {
      if (window.ethereum) {
        try {
          await window.ethereum.request({ method: 'eth_requestAccounts' });
          const instance = new Web3(window.ethereum);
          setWeb3(instance);
  
          const gameOfLifeContract = new instance.eth.Contract(ABI, CONTRACT_ADDRESS);
          setContract(gameOfLifeContract);
        } catch (error) {
          alert('Please connect your MetaMask wallet to use this dApp.');
        }
      } else {
        alert('Please install MetaMask to use this dApp.');
      }
    }
  
    connectWallet();
  }, []);

  useEffect(() => {
    if (!contract) return;

    const fetchGrid = async () => {
      const gridData = await contract.methods.getGrid().call();
      setGrid(gridData);
    };

    const fetchGridAndSetPaintGridSize = async () => {
      const gridData = await contract.methods.getGrid().call();
      setGrid(gridData);
      setPaintGrid(JSON.parse(JSON.stringify(gridData)));
    };

    fetchGridAndSetPaintGridSize();

    const intervalId = setInterval(fetchGrid, 10000);

    return () => clearInterval(intervalId);
  }, [contract]);

  const handleMouseDown = (e, x, y) => {
    e.preventDefault();
    setIsMouseDown(true);
    setIsErasing(e.button === 2);
    handleClick(x, y);
  };

  const handleMouseUp = () => {
    setIsMouseDown(false);
  };

  const handleMouseOver = (x, y) => {
    if (isMouseDown) {
      handleClick(x, y);
    }
  };

  const handleClick = (x, y) => {
    if (isErasing) {
      setSelectedCells(selectedCells.filter(cell => !(cell.x === x && cell.y === y)));
    } else {
      if (selectedCells.some(cell => cell.x === x && cell.y === y)) {
        return;
      }
      setSelectedCells([...selectedCells, { x, y }]);
    }
  
    const newGrid = JSON.parse(JSON.stringify(paintGrid));
    newGrid[x][y] = !isErasing;
    setPaintGrid(newGrid);
  };

  const handleActivateMany = async () => {
    const xCoords = selectedCells.map(cell => cell.x);
    const yCoords = selectedCells.map(cell => cell.y);

    await contract.methods.activateCells(xCoords, yCoords).send({ from: (await web3.eth.getAccounts())[0] });
    const gridData = await contract.methods.getGrid().call()
    setGrid(gridData);
    setPaintGrid(gridData);
    setSelectedCells([]);
  };

  const handleNextIteration = async () => {
    await contract.methods.nextIteration().send({ from: (await web3.eth.getAccounts())[0] });
    const gridData = await contract.methods.getGrid().call()
    setGrid(gridData);
    setPaintGrid(gridData);
    setSelectedCells([]);
  };
  

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      width: '100vw',
      minHeight: '100vh',
      alignItems: 'center',
      fontFamily: 'Arial, sans-serif',
      background: 'white',
    }}>
      <h1 style={{
        // color: 'white',
        marginTop: 20,
        margin: 20,
        marginBottom: 10,
      }}>Onchan Conway's Game of Life</h1>
      <p style={{
        color: 'grey', 
        margin: 20,
        fontStyle: 'italic',
      }}><a href="https://github.com/MarcoWorms/onchain-automata">Source Code</a>. Deployed at <a href="https://chainlist.org/chain/250">Fantom Opera</a>. Paint with left mouse button and erase with right mouse button.</p>
      <div style={{
        margin: 20,
        display: 'flex',
        marginBottom: 20,
        flexWrap: 'wrap',
        width: '50%',
        justifyContent: 'space-around',
      }}>
        <button style={{
          padding: '10px 20px',
          // borderRadius: '5px',
          border: 'none',
          background: 'lightgreen',
          // color: 'white',
          fontSize: '16px',
          cursor: 'pointer',
          border: 'solid 1px black',
        }} onClick={handleActivateMany}>Activate Painted Cells</button>
        <button style={{
          padding: '10px 20px',
          // borderRadius: '5px',
          border: 'none',
          background: 'lightgrey',
          // color: 'white',
          fontSize: '16px',
          cursor: 'pointer',
          border: 'solid 1px black',
        }} onClick={handleNextIteration}>Step One Generation</button>
      </div>
      <div
        style={{
          marginTop: 20,
          border: 'dashed 2px lightgrey',
        }}
      >
        {grid.map((row, x) => (
          <div
            style={{
              display: 'flex',
            }}
            key={x}
          >
            {row.map((cell, y) => (
              <button
                key={`${x}-${y}`}
                onMouseDown={(e) => handleMouseDown(e, x, y)}
                onMouseUp={handleMouseUp}
                onMouseOver={() => handleMouseOver(x, y)}
                onContextMenu={(e) => e.preventDefault()}
                style={{
                  width: 'calc(min(75vw, 75vh) / 20)',
                  height: 'calc(min(75vw, 75vh) / 20)',
                  background: cell ? 'black' : paintGrid?.[x]?.[y] ? 'lightgreen' : 'white',
                  // border: 'solid 1px #eee',
                  border: 'none',
                  margin: '0',
                  padding: '0',
                  transition: 'background-color 0.3s ease',
                }}
              />          
            ))}
          </div>
        ))}
      </div>
      
    </div>
  );
}

export default App;
