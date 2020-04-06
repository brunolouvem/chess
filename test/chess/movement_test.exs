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

    test "when coords is valid and passed special_move field" do
      coords = ["e1", "g1"]

      assert %Movement{
               coords: ^coords,
               start: "e1",
               end: "g1",
               special_move: :castling
             } = Movement.create({coords, :castling})
    end

    test "when coords is not valid" do
      assert {:error, :not_valid_coords} = Movement.create("e4")
    end
  end

  describe "get_movements/1 :king" do
    test "succesfully king move without another pieces" do
      board = build(:board)
      king = build(:piece, type: :king, start_position: "e1", current_position: "e1")

      black_king =
        build(:piece, type: :king, color: "black", start_position: "e8", current_position: "e8")

      board = Board.add_piece(board, king)

      assert [
               %Movement{coords: ["e1", "d2"], end: "d2", start: "e1"},
               %Movement{coords: ["e1", "d1"], end: "d1", start: "e1"},
               %Movement{coords: ["e1", "f1"], end: "f1", start: "e1"},
               %Movement{coords: ["e1", "f2"], end: "f2", start: "e1"},
               %Movement{coords: ["e1", "e2"], end: "e2", start: "e1"}
             ] = Movement.get_movements(board, king)

      assert [
               %Movement{coords: ["e8", "f7"], end: "f7", start: "e8"},
               %Movement{coords: ["e8", "f8"], end: "f8", start: "e8"},
               %Movement{coords: ["e8", "d8"], end: "d8", start: "e8"},
               %Movement{coords: ["e8", "d7"], end: "d7", start: "e8"},
               %Movement{coords: ["e8", "e7"], end: "e7", start: "e8"}
             ] = Movement.get_movements(board, black_king)
    end

    test "succesfully get possible moves with another pieces" do
      board = build(:board)
      king = build(:piece, type: :king, start_position: "e1", current_position: "e1")
      allie_pawn = build(:piece, type: :pawn, start_position: "d1", current_position: "d1")
      opponent_king = build(:piece, type: :king, color: "black", current_position: "e2")

      board =
        board
        |> Board.add_piece(king)
        |> Board.add_piece(allie_pawn)
        |> Board.add_piece(opponent_king)

      assert [
               %Movement{coords: ["e1", "d2"], end: "d2", start: "e1"},
               %Movement{coords: ["e1", "f1"], end: "f1", start: "e1"},
               %Movement{coords: ["e1", "f2"], end: "f2", start: "e1"},
               %Movement{coords: ["e1", "e2"], end: "e2", start: "e1"}
             ] = Movement.get_movements(board, king)
    end

    test "succesfully get possible move kingside castling" do
      board = build(:board)

      king = build(:piece, type: :king, start_position: "e1", current_position: "e1")
      allie_rook = build(:piece, type: :pawn, start_position: "h1", current_position: "h1")

      black_king =
        build(:piece, type: :king, color: "black", start_position: "e8", current_position: "e8")

      black_allie_rook =
        build(:piece, type: :rook, color: "black", start_position: "h8", current_position: "h8")

      board =
        board
        |> Board.add_piece(king)
        |> Board.add_piece(allie_rook)
        |> Board.add_piece(black_king)
        |> Board.add_piece(black_allie_rook)

      assert [
               %Movement{coords: ["e1", "d2"], end: "d2", start: "e1"},
               %Movement{coords: ["e1", "d1"], end: "d1", start: "e1"},
               %Movement{coords: ["e1", "f1"], end: "f1", start: "e1"},
               %Movement{coords: ["e1", "f2"], end: "f2", start: "e1"},
               %Movement{coords: ["e1", "e2"], end: "e2", start: "e1"},
               %Movement{coords: ["e1", "g1"], end: "g1", start: "e1", special_move: :castling}
             ] = Movement.get_movements(board, king)

      assert [
               %Movement{coords: ["e8", "f7"], end: "f7", start: "e8"},
               %Movement{coords: ["e8", "f8"], end: "f8", start: "e8"},
               %Movement{coords: ["e8", "d8"], end: "d8", start: "e8"},
               %Movement{coords: ["e8", "d7"], end: "d7", start: "e8"},
               %Movement{coords: ["e8", "e7"], end: "e7", start: "e8"},
               %Movement{coords: ["e8", "g8"], end: "g8", start: "e8", special_move: :castling}
             ] = Movement.get_movements(board, black_king)
    end

    test "succesfully get possible move queenside castling" do
      board = build(:board)

      king = build(:piece, type: :king, start_position: "e1", current_position: "e1")
      allie_rook = build(:piece, type: :pawn, start_position: "a1", current_position: "a1")

      black_king =
        build(:piece, type: :king, color: "black", start_position: "e8", current_position: "e8")

      black_allie_rook =
        build(:piece, type: :rook, color: "black", start_position: "a8", current_position: "a8")

      board =
        board
        |> Board.add_piece(king)
        |> Board.add_piece(allie_rook)
        |> Board.add_piece(black_king)
        |> Board.add_piece(black_allie_rook)

      assert [
               %Movement{coords: ["e1", "d2"], end: "d2", start: "e1"},
               %Movement{coords: ["e1", "d1"], end: "d1", start: "e1"},
               %Movement{coords: ["e1", "f1"], end: "f1", start: "e1"},
               %Movement{coords: ["e1", "f2"], end: "f2", start: "e1"},
               %Movement{coords: ["e1", "e2"], end: "e2", start: "e1"},
               %Movement{coords: ["e1", "c1"], end: "c1", start: "e1", special_move: :castling}
             ] = Movement.get_movements(board, king)

      assert [
               %Movement{coords: ["e8", "f7"], end: "f7", start: "e8"},
               %Movement{coords: ["e8", "f8"], end: "f8", start: "e8"},
               %Movement{coords: ["e8", "d8"], end: "d8", start: "e8"},
               %Movement{coords: ["e8", "d7"], end: "d7", start: "e8"},
               %Movement{coords: ["e8", "e7"], end: "e7", start: "e8"},
               %Movement{coords: ["e8", "c8"], end: "c8", start: "e8", special_move: :castling}
             ] = Movement.get_movements(board, black_king)
    end
  end

  describe "get_movements/1 :queen" do
    test "succesfully queen move without another pieces" do
      board = build(:board)
      queen = build(:piece, type: :queen, start_position: "d1", current_position: "d1")

      board = Board.add_piece(board, queen)

      assert [
               %Movement{
                 coords: ["d1", "c2", "b3", "a4"],
                 end: "a4",
                 start: "d1"
               },
               %Movement{
                 coords: ["d1", "e2", "f3", "g4", "h5"],
                 end: "h5",
                 start: "d1"
               },
               %Movement{
                 coords: ["d1", "e1", "f1", "g1", "h1"],
                 end: "h1",
                 start: "d1"
               },
               %Movement{
                 coords: ["d1", "c1", "b1", "a1"],
                 end: "a1",
                 start: "d1"
               },
               %Movement{
                 coords: ["d1", "d2", "d3", "d4", "d5", "d6", "d7", "d8"],
                 end: "d8",
                 start: "d1"
               }
             ] = Movement.get_movements(board, queen)
    end

    test "succesfully get possible moves with another pieces" do
      board = build(:board)
      queen = build(:piece, type: :queen, start_position: "d1", current_position: "d1")
      allie_pawn = build(:piece, type: :king, start_position: "c1", current_position: "c1")
      opponent_queen = build(:piece, type: :queen, color: "black", current_position: "d4")

      board =
        board
        |> Board.add_piece(queen)
        |> Board.add_piece(allie_pawn)
        |> Board.add_piece(opponent_queen)

      assert [
               %Movement{
                 coords: ["d1", "c2", "b3", "a4"],
                 end: "a4",
                 start: "d1"
               },
               %Movement{
                 coords: ["d1", "e2", "f3", "g4", "h5"],
                 end: "h5",
                 start: "d1"
               },
               %Movement{
                 coords: ["d1", "e1", "f1", "g1", "h1"],
                 end: "h1",
                 start: "d1"
               },
               %Movement{
                 coords: ["d1", "d2", "d3", "d4"],
                 end: "d4",
                 start: "d1"
               }
             ] = Movement.get_movements(board, queen)
    end
  end

  describe "get_movements/1 :bishop" do
    test "succesfully get possible moves without another pieces" do
      board = build(:board)
      bishop = build(:piece, type: :bishop, start_position: "c1", current_position: "c1")

      board = Board.add_piece(board, bishop)

      assert [
               %Movement{
                 coords: ["c1", "b2", "a3"],
                 end: "a3",
                 start: "c1"
               },
               %Movement{
                 coords: ["c1", "d2", "e3", "f4", "g5", "h6"],
                 end: "h6",
                 start: "c1"
               }
             ] = Movement.get_movements(board, bishop)
    end

    test "succesfully get possible moves with another pieces" do
      board = build(:board)
      bishop = build(:piece, type: :bishop, start_position: "c1", current_position: "c1")
      allie_pawn = build(:piece, type: :pawn, start_position: "a3", current_position: "a3")
      opponent_queen = build(:piece, type: :queen, color: "black", current_position: "h6")

      board =
        board
        |> Board.add_piece(bishop)
        |> Board.add_piece(allie_pawn)
        |> Board.add_piece(opponent_queen)

      assert [
               %Movement{
                 coords: ["c1", "b2"],
                 end: "b2",
                 start: "c1"
               },
               %Movement{
                 coords: ["c1", "d2", "e3", "f4", "g5", "h6"],
                 end: "h6",
                 start: "c1"
               }
             ] = Movement.get_movements(board, bishop)
    end
  end

  describe "get_movements/1 :knight" do
    test "succesfully get possible moves without another pieces" do
      board = build(:board)
      knight = build(:piece, type: :knight, start_position: "b1", current_position: "b1")

      black_knight =
        build(:piece, type: :knight, color: "black", start_position: "b8", current_position: "b8")

      board =
        board
        |> Board.add_piece(knight)
        |> Board.add_piece(black_knight)

      assert [
               %Movement{coords: ["b1", "d2"], end: "d2", start: "b1"},
               %Movement{coords: ["b1", "c3"], end: "c3", start: "b1"},
               %Movement{coords: ["b1", "a3"], end: "a3", start: "b1"}
             ] = Movement.get_movements(board, knight)

      assert [
               %Movement{coords: ["b8", "d7"], end: "d7", start: "b8"},
               %Movement{coords: ["b8", "c6"], end: "c6", start: "b8"},
               %Movement{coords: ["b8", "a6"], end: "a6", start: "b8"}
             ] = Movement.get_movements(board, black_knight)
    end

    test "succesfully get possible moves with another pieces" do
      board = build(:board)
      knight = build(:piece, type: :knight, start_position: "b1", current_position: "b1")
      allie_pawn = build(:piece, type: :pawn, start_position: "a3", current_position: "a3")

      black_knight =
        build(:piece, type: :knight, color: "black", start_position: "c3", current_position: "c3")

      board =
        board
        |> Board.add_piece(knight)
        |> Board.add_piece(allie_pawn)
        |> Board.add_piece(black_knight)

      assert [
               %Movement{coords: ["b1", "d2"], end: "d2", start: "b1"},
               %Movement{coords: ["b1", "c3"], end: "c3", start: "b1"}
             ] = Movement.get_movements(board, knight)

      assert [
               %Movement{coords: ["c3", "e2"], end: "e2", start: "c3"},
               %Movement{coords: ["c3", "e4"], end: "e4", start: "c3"},
               %Movement{coords: ["c3", "a2"], end: "a2", start: "c3"},
               %Movement{coords: ["c3", "a4"], end: "a4", start: "c3"},
               %Movement{coords: ["c3", "d1"], end: "d1", start: "c3"},
               %Movement{coords: ["c3", "b1"], end: "b1", start: "c3"},
               %Movement{coords: ["c3", "d5"], end: "d5", start: "c3"},
               %Movement{coords: ["c3", "b5"], end: "b5", start: "c3"}
             ] = Movement.get_movements(board, black_knight)
    end
  end

  describe "get_movements/1 :rook" do
    test "succesfully get possible moves without another pieces" do
      board = build(:board)
      rook = build(:piece, type: :rook, start_position: "a1", current_position: "a1")

      board = Board.add_piece(board, rook)

      assert [
               %Movement{
                 coords: ["a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1"],
                 end: "h1",
                 start: "a1"
               },
               %Movement{
                 coords: ["a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8"],
                 end: "a8",
                 start: "a1"
               }
             ] = Movement.get_movements(board, rook)
    end

    test "succesfully get possible moves with another pieces" do
      board = build(:board)
      rook = build(:piece, type: :rook, start_position: "a1", current_position: "a1")
      allie_rook = build(:piece, type: :rook, start_position: "h1", current_position: "h1")
      opponent_queen = build(:piece, type: :queen, color: "black", current_position: "a8")

      board =
        board
        |> Board.add_piece(rook)
        |> Board.add_piece(allie_rook)
        |> Board.add_piece(opponent_queen)

      assert [
               %Movement{
                 coords: ["a1", "b1", "c1", "d1", "e1", "f1", "g1"],
                 end: "g1",
                 start: "a1"
               },
               %Movement{
                 coords: ["a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8"],
                 end: "a8",
                 start: "a1"
               }
             ] = Movement.get_movements(board, rook)
    end
  end

  describe "get_movements/1 :paws" do
    test "succesfully get possible moves" do
      board = build(:board)
      piece = build(:piece, start_position: "e2", current_position: "e2")

      board = Board.add_piece(board, piece)

      assert [%Movement{coords: ["e2", "e3", "e4"], end: "e4", start: "e2"}] =
               Movement.get_movements(board, piece)

      black_piece = build(:piece, color: "black", current_position: "e5")

      board = Board.add_piece(board, black_piece)

      assert [%Movement{coords: ["e5", "e4"], end: "e4", start: "e5"}] =
               Movement.get_movements(board, black_piece)
    end

    test "succesfully get possible moves with en passant white" do
      board = build(:board)
      piece = build(:piece, start_position: "e2", current_position: "e5")
      black_piece = build(:piece, color: "black", current_position: "d5")

      board =
        board
        |> Board.add_piece(piece)
        |> Board.add_piece(black_piece)

      assert [
               %Movement{coords: ["e5", "d6"], end: "d6", start: "e5", special_move: :en_passant},
               %Movement{coords: ["e5", "e6"], end: "e6", start: "e5"}
             ] = Movement.get_movements(board, piece)
    end

    test "succesfully get possible moves with en passant black" do
      board = build(:board)
      piece = build(:piece, start_position: "e2", current_position: "e4")
      black_piece = build(:piece, color: "black", current_position: "d4")

      board =
        board
        |> Board.add_piece(piece)
        |> Board.add_piece(black_piece)

      assert [
               %Movement{coords: ["d4", "e3"], end: "e3", start: "d4", special_move: :en_passant},
               %Movement{coords: ["d4", "d3"], end: "d3", start: "d4"}
             ] = Movement.get_movements(board, black_piece)
    end

    test "not possible move more" do
      board = build(:board)
      piece = build(:piece, current_position: "a8")
      assert [] = Movement.get_movements(board, piece)

      board = Board.add_piece(board, piece)

      another_piece = build(:piece, current_position: "a7")
      assert [] = Movement.get_movements(board, another_piece)
    end

    test "position not valid" do
      board = build(:board)
      piece = build(:piece, current_position: "x9")
      another_piece = build(:piece, start_position: "x9", current_position: "x9")

      assert {:error, :invalid_position} = Movement.get_movements(board, piece)
      assert {:error, :invalid_position} = Movement.get_movements(board, another_piece)
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

  describe "movement column, line from position" do
    test "when position is valid and inside matrix" do
      board = build(:board)

      piece = build(:piece)

      assert ["a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8"] =
               Movement.column_from_position(board, piece)

      assert ["a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2"] =
               Movement.line_from_position(board, piece)
    end

    test "when position is not valid and not inside matrix" do
      board = build(:board)

      piece = build(:piece, start_position: "x9", current_position: "x9")

      assert {:error, :invalid_position} = Movement.column_from_position(board, piece)
      assert {:error, :invalid_position} = Movement.line_from_position(board, piece)

      assert {:error, :invalid_position} = Movement.around_positions(board, piece)
    end
  end

  describe "movement diagonals, l, and around  from position" do
    test "when position is valid and inside matrix" do
      board = build(:board)

      piece = build(:piece, type: :bishop, start_position: "e4", current_position: "e4")

      black_piece =
        build(:piece, type: :bishop, color: "black", start_position: "e4", current_position: "e4")

      knight = build(:piece, type: :knight, start_position: "b1", current_position: "b1")

      black_knight =
        build(:piece, type: :knight, color: "black", start_position: "b8", current_position: "b8")

      assert ["b1", "c2", "d3", "e4", "f5", "g6", "h7"] =
               Movement.diagonal_from_position(board, piece)

      assert ["a8", "b7", "c6", "d5", "e4", "f3", "g2", "h1"] =
               Movement.anti_diagonal_from_position(board, piece)

      assert [["e5"], ["f5"], ["f4"], ["f3"], ["e3"], ["d3"], ["d4"], ["d5"]] =
               Movement.around_positions(board, piece)

      assert [["e3"], ["d3"], ["d4"], ["d5"], ["e5"], ["f5"], ["f4"], ["f3"]] =
               Movement.around_positions(board, black_piece)

      assert ["a3", "c3", "d2"] = Movement.l_positions_from_position(board, knight)
      assert ["a6", "c6", "d7"] = Movement.l_positions_from_position(board, black_knight)
    end

    test "when position is not valid and not inside matrix" do
      board = build(:board)

      piece = build(:piece, start_position: "x9", current_position: "x9")

      knight = build(:piece, type: :knight, start_position: "x1", current_position: "x1")

      black_knight =
        build(:piece, type: :knight, color: "black", start_position: "x8", current_position: "x8")

      assert {:error, :invalid_position} = Movement.diagonal_from_position(board, piece)
      assert {:error, :invalid_position} = Movement.anti_diagonal_from_position(board, piece)

      assert {:error, :invalid_position} = Movement.l_positions_from_position(board, knight)
      assert {:error, :invalid_position} = Movement.l_positions_from_position(board, black_knight)
    end
  end
end
