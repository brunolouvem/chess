defmodule Chess.Game.MovementTest do
  use Chess.DataCase

  import Chess.Factory

  alias Chess.Game.Pieces.Movement

  describe "possible_moves/1" do
    test "succesfully get possible moves" do
      piece = build(:piece)
      assert ["a3", "a4"] = Movement.possible_moves(piece)

      black_piece = build(:piece, color: "black", current_position: "a5")
      assert ["a4"] = Movement.possible_moves(black_piece)
    end

    test "not possible move more" do
      piece = build(:piece, current_position: "a8")
      assert [] = Movement.possible_moves(piece)
    end

    test "position not valid" do
      piece = build(:piece, current_position: "x9")
      another_piece = build(:piece, start_position: "x9", current_position: "x9")

      assert {:error, :invalid_position} = Movement.possible_moves(piece)
      assert {:error, :invalid_position} = Movement.possible_moves(another_piece)
    end
  end

  describe "movement_coord/2" do
    test "when piece is invalid" do
      assert {:error, :not_valid_piece} = Movement.movement_coord(:xablau, "a5")
    end

    [
      {:bishop, "B"},
      {:king, "K"},
      {:knight, "N"},
      {:pawn, ""},
      {:queen, "Q"},
      {:rook, "R"}
    ]
    |> Enum.each(fn {piece, piece_letter} ->
      test "valid pieces #{piece}" do
        assert "#{unquote(piece_letter)}a5" == Movement.movement_coord(unquote(piece), "a5")
      end
    end)
  end
end
