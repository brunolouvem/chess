defmodule Chess.ChessTest do
  use ExUnit.Case

  describe "new_name/0" do
    test "successfully create a new game" do
      assert %Chess.Game{board: %Chess.Board{}} = Chess.new_game()
    end
  end
end
