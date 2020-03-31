defmodule Chess.Movements.Rook do
  alias Chess.Board
  alias Chess.Piece
  alias Chess.Movements.Movement

  def possibles(%Piece{
        type: :rook,
        current_position: current_position,
        color: color
      }, board) do
    case Movement.validate_position(current_position) do
      {:error, _} = error -> error
      [column, line] = position ->
        opponent_color = Piece.opponent_color(color)
        opponent_positions = Board.positions_by_color(board, opponent_color)
        allies_positions = Board.positions_by_color(board, color) |> List.delete(current_position)


        [h_initial, h_final] = Movement.calculate_steps(:horizontal, column, color)
        [v_initial, v_final] = Movement.calculate_steps(:vertical, line, color)

        [
          build_rook_line(:up, position, v_final, color, opponent_positions, allies_positions),
          build_rook_line(:down, position, v_initial, color, opponent_positions, allies_positions),
          build_rook_line(:left, position, h_initial, color, opponent_positions, allies_positions),
          build_rook_line(:right, position, h_final, color, opponent_positions, allies_positions)
        ]
        |> List.flatten()
    end
  end

  defp build_rook_line(direction, position, steps, color, opponent_positions, allies_positions) do
    Movement
    |> apply(direction, [position, steps, color])
    |> Movement.filter_line(opponent_positions, true)
    |> Movement.filter_line(allies_positions)
  end
end
