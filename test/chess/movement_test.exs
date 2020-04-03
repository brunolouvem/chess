defmodule Chess.Game.MovementTest do
  use ExUnit.Case

  import Chess.Factory

  alias Chess.Board
  alias Chess.Movements.Movement

  describe "create/1" do
    test "when coords is valid" do
      coords = ["e3", "e4", "e5"]
      assert %Movement{
          coords: ^coords,
          start: "e3",
          end: "e5"
        } = Movement.create(coords)
    end
    test "when coords is not valid" do
      assert {:error, :not_valid_coords} = Movement.create("e4")
    end
  end

  describe "possible_moves/1" do
    test "succesfully get possible moves" do
      board = build(:board)
      piece = build(:piece, start_position: "e2", current_position: "e2")

      board = Board.add_piece(board, piece)

      assert ["e4", "e3"] = Movement.possible_moves(board, piece)

      black_piece = build(:piece, color: "black", current_position: "e5")

      board = Board.add_piece(board, black_piece)

      assert ["e4"] = Movement.possible_moves(board, black_piece)
    end

    test "not possible move more" do
      board = build(:board)
      piece = build(:piece, current_position: "a8")
      assert [] = Movement.possible_moves(board, piece)

      board = Board.add_piece(board, piece)

      another_piece = build(:piece, current_position: "a7")
      assert [] = Movement.possible_moves(board, another_piece)
    end

    test "position not valid" do
      board = build(:board)
      piece = build(:piece, current_position: "x9")
      another_piece = build(:piece, start_position: "x9", current_position: "x9")

      assert {:error, :invalid_position} = Movement.possible_moves(board, piece)
      assert {:error, :invalid_position} = Movement.possible_moves(board, another_piece)
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
