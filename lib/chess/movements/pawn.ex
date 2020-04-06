defmodule Chess.Movements.Pawn do
  alias Chess.Board
  alias Chess.Piece
  alias Chess.Movements.Movement

  @behaviour Movement

  def possibles(
        %Piece{
          type: :pawn,
          current_position: current_position,
          start_position: start_position
        } = piece,
        board
      )
      when current_position == start_position,
      do: do_possibles(piece, board, 2)

  def possibles(
        %Piece{
          type: :pawn
        } = piece,
        board
      ),
      do: do_possibles(piece, board, 1)

  def do_possibles(
        %Piece{
          type: :pawn,
          current_position: current_position,
          color: color
        },
        %Board{positions: positions} = board,
        steps
      ) do
    case Movement.validate_position(current_position) do
      {:error, _} = error ->
        error

      position ->
        opponent_color = Piece.opponent_color(color)
        opponent_positions = Board.positions_by_color(board, opponent_color)
        allies_positions = Board.positions_by_color(board, color) |> List.delete(current_position)

        walk_positions = Movement.up(position, steps, color, positions) |> Enum.reverse()

        capture_positions = capture_possibilities(position, color, opponent_positions, positions)

        en_passant_possibilities =
          en_passant_possibilities(position, color, opponent_positions, positions)

        [
          walk_positions,
          capture_positions,
          en_passant_possibilities
        ]
        |> Enum.reduce([], fn
          move, acc ->
            move
            |> create_movement(opponent_positions, allies_positions, current_position)
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

  defp create_movement(
         [{coords, special}],
         opponent_positions,
         allies_positions,
         current_position
       ) do
    coords
    |> Movement.filter_line(opponent_positions, true)
    |> Movement.filter_line(allies_positions)
    |> case do
      [] -> []
      [^current_position] -> []
      positions -> {List.insert_at(positions, 0, current_position), special}
    end
    |> Movement.create()
  end

  defp create_movement(coords, opponent_positions, allies_positions, current_position) do
    coords
    |> Movement.filter_line(opponent_positions, true)
    |> Movement.filter_line(allies_positions)
    |> case do
      [] -> []
      [^current_position] -> []
      positions -> List.insert_at(positions, 0, current_position)
    end
    |> Movement.create()
  end

  def capture_possibilities(position, color, occupied_positions, all_positions) do
    [
      Movement.diagonal_left_up(position, 1, color, all_positions),
      Movement.diagonal_right_up(position, 1, color, all_positions)
    ]
    |> Enum.filter(&(&1 in occupied_positions))
    |> List.flatten()
  end

  def en_passant_possibilities([_, line] = position, color, opponent_positions, all_positions)
      when (color == "white" and line == 5) or (color == "black" and line == 4) do
    [
      Movement.left(position, 1, color, all_positions),
      Movement.right(position, 1, color, all_positions)
    ]
    |> List.flatten()
    |> Enum.filter(&(&1 in opponent_positions))
    |> Enum.map(fn position ->
      movement =
        position
        |> Movement.extract_position()
        |> Movement.up(1, color, all_positions)

      {movement, :en_passant}
    end)
    |> List.flatten()
  end

  def en_passant_possibilities(_, _, _, _), do: []
end
