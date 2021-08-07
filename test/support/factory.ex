defmodule Chess.Factory do
  @moduledoc false

  use ExMachina

  alias Chess.Piece
  alias Chess.Board

  def piece_factory do
    Piece.create(:pawn, :white, "a2")
  end

  def board_factory do
    Board.create()
  end
end
