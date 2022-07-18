//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import { Verifier } from "./MainVerifier.sol";

contract Game {

    using Counters for Counters.Counter;
    Counters.Counter private gameCounter;
    Verifier private verifier;

    struct GameComponent {
        uint256 gameId;
        address[2] players;
        uint256[2] nonis;
        bool[2] verification;
        address turn;
        int8[9] game;
        // 0 = player0 won, 1 = player1 win, 2 = tie, 3 = unfinnished
        int8 state;
    }
    mapping(uint256 => GameComponent) public allGames;
    mapping(address => uint256[]) public gamesByOther;
    mapping(address => uint256[]) public gamesByMe;
    
    event GameDone(uint256 _gameId, int8 winner);
    event MoveDone(uint256 _gameId, int8[9] game);

    constructor() {
        verifier = new Verifier();
    }

    function initGame(address player1) public {
        require(msg.sender != player1, 'Cannot challenge yourself');
        uint256 _gameId = gameCounter.current();

        // The one who initiaites the game gets to start, maybe not optimal but let's
        // stick with this for a while
        GameComponent storage game = allGames[_gameId];
        game.gameId = _gameId;
        game.players[0] = msg.sender;
        game.players[1] = player1;
        game.verification[0] = false;
        game.verification[1] = false;
        game.turn = msg.sender;
        game.game = [int8(0),0,0,0,0,0,0,0,0];
        game.state = 3;

        gameCounter.increment();

        gamesByMe[msg.sender].push(_gameId);
        gamesByOther[player1].push(_gameId);
    }

    function verifyGame(uint256 _gameId, uint256 noni) public returns(bool succes) {

        if (msg.sender == allGames[_gameId].players[0]) {
            allGames[_gameId].verification[0] = true;
            allGames[_gameId].nonis[0] = noni; 
            return true;
        } 
        else if (msg.sender == allGames[_gameId].players[1]) {
            allGames[_gameId].verification[1] = true;
            allGames[_gameId].nonis[1] = noni; 
            return true;
        }
        else {
            return false;
        }
    }

    function makeMove(uint8 position, uint256 _gameId, uint[8] memory proof, uint[9] memory input) public {
        
        uint[2] memory a = [proof[0], proof[1]];
        uint[2][2] memory b = [[proof[2], proof[3]], [proof[4], proof[5]]];
        uint[2] memory c = [proof[6], proof[7]];

        require(verifier.verifyProof(a, b, c, input), "invalid proof");

        require(allGames[_gameId].verification[0] == true && allGames[_gameId].verification[1] == true, "Game has not been verified by both players");
        require(allGames[_gameId].state == 3, "Game has not been initiated or is finnished");
        require(msg.sender == allGames[_gameId].turn, "It's not your turn!");
        
        bool terminated = false;

        if (msg.sender == allGames[_gameId].players[0] && allGames[_gameId].game[position] == 0) {
            allGames[_gameId].game[position] = -1;
            terminated = gameState(_gameId, -1);
            allGames[_gameId].turn = allGames[_gameId].players[1];
        }
        else if (msg.sender == allGames[_gameId].players[1] && allGames[_gameId].game[position] == 0) {
            allGames[_gameId].game[position] = 1;
            terminated = gameState(_gameId, 1);
            allGames[_gameId].turn = allGames[_gameId].players[0]; 
        }

        emit MoveDone(_gameId, allGames[_gameId].game);
        if (terminated == true) {
            emit GameDone(_gameId, allGames[_gameId].state);
        }
    }

    function gameState(uint256 _gameId, int8 _mark) public returns(bool terminated) {
        int8 winner = checkWinner(_gameId, _mark);

        if (winner == -1) {
            allGames[_gameId].state = 0;
        } else if (winner == 1) {
            allGames[_gameId].state = 1;
        } else if (winner == 3) {
            bool filled = checkIfBoardIsFilled(_gameId);
            if (filled == true) {
                allGames[_gameId].state = 2;
            } else {
                return true;
            }
        }
        return false;
    
    } 

    // This is one of the most confusing and hacky things I have written in my life...
    function checkWinner(uint256 _gameId, int8 _mark) public view returns(int8 state) {

        int8[9] memory board = allGames[_gameId].game;
        int8[9] memory modBoard;
       

        for (uint i = 0; i < 9; i++) {
            if (board[i] == _mark) {
                modBoard[i] = _mark;
            }
            else  {
               modBoard[i] = 0; 
            }
        }

        uint8[3][8] memory patterns = [
            [0, 1, 2],
            [3, 4, 5],
            [6, 7, 8],
            [0, 3, 6],
            [1, 4, 7],
            [2, 5, 8],
            [0, 4, 8],
            [2, 4, 6]
        ];

        bool win;

        for (uint i = 0; i < 8; i++) {
            win = true;
            for (uint j = 0; j < 3; j++) {
                uint8 position = patterns[i][j];
                if (modBoard[position] == 0) {
                    win = false;
                }
            }
            if (win == true) {
                return _mark;
            }
        }
        return 3;
    }

    function checkIfBoardIsFilled(uint256 _gameId) public view returns(bool isTie) {
        bool filled = true;
        for (uint i = 0; i < 8; i++) {
            if (allGames[_gameId].game[i] == 0) {
                filled = false;
            }
        }
        return filled;
    } 

    function getGame(uint256 _gameId) public view returns(GameComponent memory game) {
        return allGames[_gameId];
    }

    function getMyChallenges() public view returns(uint256[] memory) {
        return gamesByOther[msg.sender];
    }

    function getMyGames() public view returns(uint256[] memory) {
        return gamesByMe[msg.sender];
    }

}