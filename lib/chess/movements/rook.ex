defmodule Chess.Movements.Rook do
  alias Chess.Board
  alias Chess.Piece
  alias Chess.Movements.Movement

  @behaviour Movement

  def possibles(
        %Piece{
          type: :rook,
          current_position: current_position,
          color: color
        } = piece,
        board
      ) do
      opponent_color = Piece.opponent_color(color)
      opponent_positions = Board.positions_by_color(board, opponent_color)
      allies_positions = Board.positions_by_color(board, color) |> List.delete(current_position)

      line = Movement.line_from_position(board, piece)

      {line_before, line_after} = Movement.centralize_position_in_sequence(line, current_position)

      column = Movement.column_from_position(board, piece)

      {column_before, column_after} =
        Movement.centralize_position_in_sequence(column, current_position)

      [
        column_before,
        column_after,
        line_before,
        line_after
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
          _ -> acc
        end
      end)
      |> List.flatten()
  end
end
