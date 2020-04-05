defmodule Chess.Movements.Bishop do
  alias Chess.Movements.Movement
  alias Chess.Piece
  alias Chess.Board

  @behaviour Movement

  def possibles(%Piece{color: color, current_position: current_position} = piece, board) do
    opponent_color = Piece.opponent_color(color)
    opponent_positions = Board.positions_by_color(board, opponent_color)
    allies_positions = Board.positions_by_color(board, color) |> List.delete(current_position)

    diagonal = Movement.diagonal_from_position(board, piece)

    {diagonal_before, diagonal_after} =
      Movement.centralize_position_in_sequence(diagonal, current_position)

    anti_diagonal = Movement.anti_diagonal_from_position(board, piece)

    {anti_diagonal_before, anti_diagonal_after} =
      Movement.centralize_position_in_sequence(anti_diagonal, current_position)

    [
      diagonal_before,
      diagonal_after,
      anti_diagonal_before,
      anti_diagonal_after
    ]
    |> Enum.reduce([], fn move, acc ->
      move
      |> Movement.filter_line(opponent_positions, true)
      |> Movement.filter_line(allies_positions)
      |> case do
        [] -> []
        [^current_position] -> []
        positions -> List.insert_at(positions, 0, current_position)
      end
      |> Movement.create()
      |> case do
        %Movement{} = movement ->
          [movement | acc]

        _ ->
          acc
      end
    end)
    |> List.flatten()
  end
end
