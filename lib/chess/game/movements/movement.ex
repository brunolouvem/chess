defmodule Chess.Game.Movements.Movement do
  import Chess.Game.Movements.Pawn

  alias Chess.Game.Pieces.Piece

  @position_regex ~r/([a-h])([1-8])/

  @columns for n <- ?a..?h, do:  << n :: utf8 >>

  def movement_coord(:pawn, position), do: position
  def movement_coord(:king, position), do: "K#{position}"
  def movement_coord(:queen, position), do: "Q#{position}"
  def movement_coord(:bishop, position), do: "B#{position}"
  def movement_coord(:rook, position), do: "R#{position}"
  def movement_coord(:knight, position), do: "N#{position}"
  def movement_coord(_, _), do: {:error, :not_valid_piece}

  def possible_moves(board, piece) do
    piece
    |> possibles(board)
  end

  def up([column, line], steps, "white") when line != "8" and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->
      line =
        line
        |> String.to_integer()
        |> Kernel.+(step)

      "#{column}#{line}"
    end)
  end

  def up([column, line], steps, "black") when line != "1" and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->
      line =
        line
        |> String.to_integer()
        |> Kernel.-(step)

      "#{column}#{line}"
    end)
  end

  def up(_, _, _), do: []

  def diagonal_right_up([column, line], steps, "white") when column != "h" and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      line = line |> String.to_integer() |> Kernel.+(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_right_up([column, line], steps, "black") when column != "a" and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      line = line |> String.to_integer() |> Kernel.-(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_right_up(_, _, _), do: []

  def diagonal_left_up([column, line], steps, "white") when column != "a" and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      line = line |> String.to_integer() |> Kernel.+(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_left_up([column, line], steps, "black") when column != "h" and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      line = line |> String.to_integer() |> Kernel.-(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_left_up(_, _, _), do: []

  def validate_position(raw_position) do
    @position_regex
    |> Regex.match?(raw_position)
    |> if do
      Regex.run(@position_regex, raw_position) |> List.delete(raw_position)
    else
      {:error, :invalid_position}
    end
  end

  defp column_to_index(col) do
    @columns |> Enum.find_index(&(&1 == col))
  end

  defp index_to_column(index) do
    @columns |> Enum.at(index)
  end
end
