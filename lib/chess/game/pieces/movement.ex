defmodule Chess.Game.Pieces.Movement do
  alias Chess.Game.Pieces.Piece

  @position_regex ~r/([a-h])([1-8])/

  # @columns ["a", "b", "c", "d", "e", "f", "g", "h"]

  def movement_coord(:pawn, position), do: position
  def movement_coord(:king, position), do: "K#{position}"
  def movement_coord(:queen, position), do: "Q#{position}"
  def movement_coord(:bishop, position), do: "B#{position}"
  def movement_coord(:rook, position), do: "R#{position}"
  def movement_coord(:knight, position), do: "N#{position}"
  def movement_coord(_, _), do: {:error, :not_valid_piece}

  def possible_moves(piece) do
    piece
    |> possibles()
  end

  defp possibles(%Piece{
         type: :pawn,
         current_position: current_position,
         start_position: start_position,
         color: color
       })
       when current_position == start_position do
    case validate_position(current_position) do
      {:error, _} = error -> error
      position -> up(position, 2, color)
    end
  end

  defp possibles(%Piece{
         type: :pawn,
         current_position: current_position,
         color: color
       }) do
    case validate_position(current_position) do
      {:error, _} = error -> error
      position -> up(position, 1, color)
    end
  end

  defp up([column, line], steps, "white") when line != "8" and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->
      line =
        line
        |> String.to_integer()
        |> Kernel.+(step)

      "#{column}#{line}"
    end)
  end

  defp up([column, line], steps, "black") when line != "1" and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->
      line =
        line
        |> String.to_integer()
        |> Kernel.-(step)

      "#{column}#{line}"
    end)
  end

  defp up(_, _, _), do: []

  defp validate_position(raw_position) do
    @position_regex
    |> Regex.match?(raw_position)
    |> if do
      Regex.run(@position_regex, raw_position) |> List.delete(raw_position)
    else
      {:error, :invalid_position}
    end
  end
end
