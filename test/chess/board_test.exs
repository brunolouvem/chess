defmodule Chess.BoardTest do
  use ExUnit.Case

  import Chess.Factory

  alias Chess.Board
  alias Chess.Piece

  describe "create/0" do
    test "succesfully creation board" do
      assert %Board{} = Board.create()
    end
  end

  describe "add_piece/2" do
    test "succesfully add piece on board" do
      board = build(:board)
      %{current_position: position} = piece = build(:piece)
      piece_map = %{position => piece}

      assert %Board{pieces: ^piece_map, occupied_positions: [^position]} =
               Board.add_piece(board, piece)
    end

    test "error when not a valid board" do
      piece = build(:piece)
      assert {:error, :not_valid_board} = Board.add_piece(:board, piece)
    end

    test "error when not a valid piece" do
      board = build(:board)
      assert {:error, :not_valid_piece} = Board.add_piece(board, :piece)
    end
  end

  describe "delete_piece/2" do
    test "succesfully delete piece on board" do
      board = build(:board)
      %{current_position: position} = piece = build(:piece)
      piece_map = %{position => piece}
      assert %Board{pieces: ^piece_map} = Board.add_piece(board, piece)

      assert %Board{pieces: %{}, occupied_positions: []} = Board.delete_piece(board, piece)
    end

    test "error when not a valid board" do
      piece = build(:piece)
      assert {:error, :not_valid_board} = Board.delete_piece(:board, piece)
    end

    test "error when not a valid piece" do
      board = build(:board)
      %{current_position: position} = piece = build(:piece)
      piece_map = %{position => piece}
      assert %Board{pieces: ^piece_map} = Board.add_piece(board, piece)

      assert {:error, :not_valid_piece} = Board.add_piece(board, :piece)
    end
  end

  describe "move_piece/3" do
    test "succesfully move piece on board" do
      board = build(:board)
      %{current_position: position} = piece = build(:piece)
      piece_map = %{position => piece}

      assert %Board{pieces: ^piece_map, occupied_positions: [^position]} =
               Board.add_piece(board, piece)

      assert {%Board{pieces: %{"a4" => moved_piece}, occupied_positions: ["a4"]}, moved_piece} =
               Board.move_piece(board, piece, "a4")
    end

    test "success move piece capturing another piece" do
      board = build(:board)
      piece = build(:piece)
      black_piece = build(:piece, color: "black", current_position: "a4", start_position: "a4")

      assert %Board{occupied_positions: ["a2"]} = board = Board.add_piece(board, piece)

      assert %Board{occupied_positions: ["a4", "a2"]} =
               board = Board.add_piece(board, black_piece)

      updated_piece = Piece.update_position(piece, "a4")

      assert {%Board{pieces: %{"a4" => ^updated_piece}, occupied_positions: ["a4"]}, moved_piece} =
               Board.move_piece(board, piece, "a4")
    end
  end
end
