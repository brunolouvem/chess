defmodule Chess.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Chess.Repo

  alias Chess.Game.Pieces.Piece
  alias Chess.Game.Board

  def piece_factory do
    Piece.create(:pawn, "white", "a2")
  end

  def board_factory do
    Board.create()
  end
end
