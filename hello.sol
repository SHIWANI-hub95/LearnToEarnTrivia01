// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarnTrivia {

    // Event to emit when a new trivia tournament is created
    event NewTournamentCreated(uint256 tournamentId, string tournamentName, uint256 prizeAmount);

    // Event to emit when a player participates in a tournament
    event PlayerParticipated(address player, uint256 tournamentId);

    // Event to emit when a player wins a tournament
    event PlayerWon(address player, uint256 tournamentId, uint256 prizeAmount);

    // Admin address (platform owner or administrator)
    address public admin;

    // Struct to represent a trivia tournament
    struct Tournament {
        uint256 tournamentId;
        string name;
        uint256 prizeAmount;
        uint256 totalParticipants;
        address winner;
        bool isCompleted;
    }

    // Mapping to store user participation in tournaments
    mapping(address => mapping(uint256 => bool)) public userParticipation;

    // Array to store all the tournaments
    Tournament[] public tournaments;

    // Modifier to restrict access to admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Constructor to set the admin (platform owner)
    constructor() {
        admin = msg.sender;
    }

    // Function to create a new trivia tournament
    function createTournament(string memory _name, uint256 _prizeAmount) public onlyAdmin {
        uint256 tournamentId = tournaments.length;
        tournaments.push(Tournament(tournamentId, _name, _prizeAmount, 0, address(0), false));
        emit NewTournamentCreated(tournamentId, _name, _prizeAmount);
    }

    // Function for users to participate in a tournament
    function participateInTournament(uint256 _tournamentId) public {
        require(_tournamentId < tournaments.length, "Invalid tournament ID");
        require(!userParticipation[msg.sender][_tournamentId], "User already participated");
        require(!tournaments[_tournamentId].isCompleted, "Tournament already completed");

        tournaments[_tournamentId].totalParticipants++;
        userParticipation[msg.sender][_tournamentId] = true;
        emit PlayerParticipated(msg.sender, _tournamentId);
    }

    // Function to declare the winner of a tournament (Only admin can call this)
    function declareWinner(uint256 _tournamentId, address _winner) public onlyAdmin {
        require(_tournamentId < tournaments.length, "Invalid tournament ID");
        require(!tournaments[_tournamentId].isCompleted, "Tournament already completed");

        tournaments[_tournamentId].winner = _winner;
        tournaments[_tournamentId].isCompleted = true;

        // Transfer prize to winner (assuming platform has enough funds)
        payable(_winner).transfer(tournaments[_tournamentId].prizeAmount);
        emit PlayerWon(_winner, _tournamentId, tournaments[_tournamentId].prizeAmount);
    }

    // Function to get tournament details
    function getTournamentDetails(uint256 _tournamentId) public view returns (string memory, uint256, uint256, bool) {
        require(_tournamentId < tournaments.length, "Invalid tournament ID");
        Tournament memory t = tournaments[_tournamentId];
        return (t.name, t.prizeAmount, t.totalParticipants, t.isCompleted);
    }

    // Function to fund the platform with ETH (to reward the winners)
    function fundPlatform() public payable onlyAdmin {}

    // Function to get the total number of tournaments
    function getTotalTournaments() public view returns (uint256) {
        return tournaments.length;
    }
}



