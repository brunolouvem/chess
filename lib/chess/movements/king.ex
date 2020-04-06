defmodule Chess.Movements.King do
  alias Chess.Movements.Movement
  alias Chess.Piece
  alias Chess.Board

  @behaviour Movement

  def possibles(%Piece{color: color, current_position: current_position} = piece, board) do
    opponent_color = Piece.opponent_color(color)
    opponent_positions = Board.positions_by_color(board, opponent_color)
    allies_positions = Board.positions_by_color(board, color) |> List.delete(current_position)

    [
      possible_kingside_castling(piece, board),
      possible_queenside_castling(piece, board) | Movement.around_positions(board, piece)
    ]
    |> Enum.reduce([], fn move, acc ->
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

  defp create_movement(coords, opponent_positions, allies_positions, current_position) do
    case coords do
      {coord, special} ->
        coord
        |> Movement.filter_line(opponent_positions, true)
        |> Movement.filter_line(allies_positions)
        |> case do
          [] -> []
          positions -> {List.insert_at(positions, 0, current_position), special}
        end
        |> Movement.create()

      coord ->
        coord
        |> Movement.filter_line(opponent_positions, true)
        |> Movement.filter_line(allies_positions)
        |> case do
          [] -> []
          positions -> List.insert_at(positions, 0, current_position)
        end
        |> Movement.create()
    end
  end

  defp possible_kingside_castling(
         %Piece{color: "white", current_position: "e1", start_position: "e1"},
         %Board{
           occupied_positions: occupied_positions,
           pieces: %{"h1" => %{color: "white", current_position: "h1", start_position: "h1"}}
         }
       ) do
    if ["f1", "g1"] not in occupied_positions do
      {["g1"], :castling}
    else
      []
    end
  end

  defp possible_kingside_castling(
         %Piece{color: "black", current_position: "e8", start_position: "e8"},
         %Board{
           occupied_positions: occupied_positions,
           pieces: %{"h8" => %{color: "black", current_position: "h8", start_position: "h8"}}
         }
       ) do
    if ["f8", "g8"] not in occupied_positions do
      {["g8"], :castling}
    else
      []
    end
  end

  defp possible_kingside_castling(_, _), do: []

  defp possible_queenside_castling(
         %Piece{color: "white", current_position: "e1", start_position: "e1"},
         %Board{
           occupied_positions: occupied_positions,
           pieces: %{"a1" => %{color: "white", current_position: "a1", start_position: "a1"}}
         }
       ) do
    if ["d1", "c1"] not in occupied_positions do
      {["c1"], :castling}
    else
      []
    end
  end

  defp possible_queenside_castling(
         %Piece{color: "black", current_position: "e8", start_position: "e8"},
         %Board{
           occupied_positions: occupied_positions,
           pieces: %{"a8" => %{color: "black", current_position: "a8", start_position: "a8"}}
         }
       ) do
    if ["d8", "c8"] not in occupied_positions do
      {["c8"], :castling}
    else
      []
    end
  end

  defp possible_queenside_castling(_, _), do: []
end
