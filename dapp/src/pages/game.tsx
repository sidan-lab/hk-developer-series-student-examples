"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";

type Choice = "rock" | "paper" | "scissors" | null;

export default function RockPaperScissors() {
  const [player1Choice, setPlayer1Choice] = useState<Choice>(null);
  const [player2Choice, setPlayer2Choice] = useState<Choice>(null);
  const [player1Score, setPlayer1Score] = useState(0);
  const [player2Score, setPlayer2Score] = useState(0);
  const [currentBet, setCurrentBet] = useState(5);

  const choices: Choice[] = ["rock", "paper", "scissors"];

  const determineWinner = (p1: Choice, p2: Choice) => {
    if (p1 === p2) return "draw";
    if (
      (p1 === "rock" && p2 === "scissors") ||
      (p1 === "paper" && p2 === "rock") ||
      (p1 === "scissors" && p2 === "paper")
    ) {
      return "player1";
    }
    return "player2";
  };

  const playGame = () => {
    if (player1Choice && player2Choice) {
      const result = determineWinner(player1Choice, player2Choice);
      if (result === "player1") {
        setPlayer1Score((prev) => prev + currentBet);
        setPlayer2Score((prev) => prev - currentBet);
      } else if (result === "player2") {
        setPlayer1Score((prev) => prev - currentBet);
        setPlayer2Score((prev) => prev + currentBet);
      }
      setPlayer1Choice(null);
      setPlayer2Choice(null);
    }
  };

  return (
    <div className="flex h-screen">
      {/* Player 1 Side */}
      <div className="flex-1 bg-blue-100 p-4 flex flex-col">
        <div className="text-2xl font-bold mb-4">Player 1: {player1Score}</div>
        <div className="flex-1 flex flex-col justify-center items-center space-y-4">
          {choices.map((choice) => (
            <Button
              key={choice}
              onClick={() => setPlayer1Choice(choice)}
              variant={player1Choice === choice ? "default" : "outline"}
              className="w-32">
              {choice.charAt(0).toUpperCase() + choice.slice(1)}
            </Button>
          ))}
        </div>
      </div>

      {/* Middle Section */}
      <div className="w-48 bg-gray-200 p-4 flex flex-col justify-center items-center">
        <div className="text-xl font-bold mb-4">Current Bet</div>
        {[5, 10, 50].map((amount) => (
          <Button
            key={amount}
            onClick={() => setCurrentBet(amount)}
            variant={currentBet === amount ? "default" : "outline"}
            className="w-full mb-2">
            {amount}
          </Button>
        ))}
        <Button onClick={playGame} className="w-full mt-4">
          Play
        </Button>
      </div>

      {/* Player 2 Side */}
      <div className="flex-1 bg-red-100 p-4 flex flex-col">
        <div className="text-2xl font-bold mb-4">Player 2: {player2Score}</div>
        <div className="flex-1 flex flex-col justify-center items-center space-y-4">
          {choices.map((choice) => (
            <Button
              key={choice}
              onClick={() => setPlayer2Choice(choice)}
              variant={player2Choice === choice ? "default" : "outline"}
              className="w-32">
              {choice.charAt(0).toUpperCase() + choice.slice(1)}
            </Button>
          ))}
        </div>
      </div>
    </div>
  );
}
