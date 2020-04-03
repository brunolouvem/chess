defmodule Chess.Movements.Queen do
  alias Chess.Movements.Movement
  alias Chess.Piece
  alias Chess.Board

  @behaviour Movement

  def possibles(%Piece{color: color, current_position: current_position} = piece, board) do
    opponent_color = Piece.opponent_color(color)
    opponent_positions = Board.positions_by_color(board, opponent_color)
    allies_positions = Board.positions_by_color(board, color) |> List.delete(current_position)

    diagonal = Movement.diagonal(piece, board)

    {diagonal_before, diagonal_after} =
      Movement.centralize_position_in_sequence(diagonal, current_position)

    anti_diagonal = Movement.anti_diagonal(piece, board)

    {anti_diagonal_before, anti_diagonal_after} =
      Movement.centralize_position_in_sequence(anti_diagonal, current_position)

    line =
      board
      |> Movement.line_from_position(piece)

    {line_before, line_after} = Movement.centralize_position_in_sequence(line, current_position)

    column =
      board
      |> Movement.column_from_position(piece)

    {column_before, column_after} =
      Movement.centralize_position_in_sequence(column, current_position)

    [
      column_before,
      column_after,
      line_before,
      line_after,
      diagonal_before,
      diagonal_after,
      anti_diagonal_before,
      anti_diagonal_after
    ]
    |> Enum.map(fn move ->
      move
      |> List.delete(current_position)
      |> Movement.filter_line(opponent_positions, true)
      |> Movement.filter_line(allies_positions)
    end)
    |> List.flatten()
  end
end
