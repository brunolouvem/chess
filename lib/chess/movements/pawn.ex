defmodule Chess.Movements.Pawn do
  alias Chess.Board
  alias Chess.Piece
  alias Chess.Movements.Movement

  @behaviour Movement

  def possibles(%Piece{
        type: :pawn,
        current_position: current_position,
        start_position: start_position,
        color: color
      }, %Board{occupied_positions: occupied_positions, positions: positions})
      when current_position == start_position do
    case Movement.validate_position(current_position) do
      {:error, _} = error -> error
      position ->
        walk_positions =
          Movement.up(position, 2, color, positions)
          |> Enum.filter(fn p ->
            p not in occupied_positions
          end)

        capture_possibilities(position, color, occupied_positions, positions) ++ walk_positions
    end
  end

  def possibles(%Piece{
        type: :pawn,
        current_position: current_position,
        color: color
      }, %Board{occupied_positions: occupied_positions, positions: positions}) do
    case Movement.validate_position(current_position) do
      {:error, _} = error -> error
      position ->
        walk_positions =
          Movement.up(position, 1, color, positions)
          |> Enum.filter(&(&1 not in occupied_positions))

        capture_possibilities(position, color, occupied_positions, positions) ++ walk_positions
    end
  end

  def capture_possibilities(position, color, occupied_positions, all_positions) do
    [
      Movement.diagonal_left_up(position, 1, color, all_positions),
      Movement.diagonal_right_up(position, 1, color, all_positions)
    ]
    |> List.flatten()
    |> Enum.filter(&(&1 in occupied_positions))
  end
end
