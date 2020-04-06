defmodule Chess.GameTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Game
  alias Chess.Movements.Movement

  describe "new/0" do
    test "successfully create a new Game struct" do
      assert %Game{board: %Board{}} = Game.new()
    end
  end

  describe "moves?/2" do
    test "successfully get a piece moves" do
      game = Game.new()

      assert [
        %Movement{
          coords: ["h2", "h3", "h4"],
          end: "h4",
          special_move: false,
          start: "h2"
        }
      ] = Game.moves?(game, "h2")
    end

    test "error when position is invalid" do
      game = Game.new()

      assert {:error, :invalid_attributes} = Game.moves?(game, {"h", 2})
      assert {:error, :invalid_attributes} = Game.moves?(game, nil)
      assert {:error, :invalid_attributes} = Game.moves?(game, "x9")
    end
  end
end
