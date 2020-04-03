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
    case Movement.validate_position(current_position) do
      {:error, _} = error ->
        error

      _ ->
        opponent_color = Piece.opponent_color(color)
        opponent_positions = Board.positions_by_color(board, opponent_color)
        allies_positions = Board.positions_by_color(board, color) |> List.delete(current_position)

        line =
          board
          |> Movement.line_from_position(piece)
          |> List.delete(current_position)
          |> Movement.filter_line(opponent_positions, true)
          |> Movement.filter_line(allies_positions)

        column =
          board
          |> Movement.column_from_position(piece)
          |> List.delete(current_position)
          |> Movement.filter_line(opponent_positions, true)
          |> Movement.filter_line(allies_positions)

        line ++ column
    end
  end
end
