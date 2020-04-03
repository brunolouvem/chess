defmodule Chess.Movements.King do
  alias Chess.Movements.Movement
  alias Chess.Piece
  alias Chess.Board

  @behaviour Movement

  def possibles(%Piece{color: color, current_position: current_position} = piece, board) do
    opponent_color = Piece.opponent_color(color)
    opponent_positions = Board.positions_by_color(board, opponent_color)
    allies_positions = Board.positions_by_color(board, color) |> List.delete(current_position)

    Movement.around_positions(piece, board)
    |> Enum.map(fn move ->
      move
      |> Movement.filter_line(opponent_positions, true)
      |> Movement.filter_line(allies_positions)
    end)
    |> List.flatten()
  end
end
