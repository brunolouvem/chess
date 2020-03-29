defmodule Chess.Game.PieceTest do
  use Chess.DataCase

  alias Chess.Game.Pieces.Piece

  describe "create/3" do
    test "succesfully creation" do
      assert %Piece{current_position: "b1", start_position: "b1", color: "black", type: :pawn} =
               Piece.create(:pawn, "black", "b1")
    end

    test "when position is not string" do
      assert {:error, :invalid_fields} = Piece.create(:pawn, "black", 1)
    end

    test "when piece type is not valid" do
      assert {:error, :invalid_fields} = Piece.create(:rat, "black", "b1")
    end

    test "when color is not valid" do
      assert {:error, :invalid_fields} = Piece.create(:pawn, "pink", "b1")
    end
  end

  describe "position/1" do
    test "succesfully position get" do
      position = "b1"
      piece = Piece.create(:pawn, "black", position)

      assert position = Piece.position(piece)
    end

    test "when not passed a valid piece" do
      assert {:error, :invalid_piece} = Piece.position(:pawn)
    end
  end

  describe "update_position/2" do
    test "succesfully position updated" do
      position = "b1"
      piece = Piece.create(:pawn, "black", position)

      assert position = Piece.position(piece)

      new_position = "c1"
      desired_updated_piece = %{piece | current_position: new_position}

      piece_updated = Piece.update_position(piece, new_position)

      assert desired_updated_piece == piece_updated

      assert new_position = Piece.position(piece_updated)
    end

    test "when not passed a valid piece" do
      assert {:error, :invalid_piece} = Piece.update_position(:pawn, "a1")
    end
  end
end
