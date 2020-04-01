defmodule Chess.Movements.Movement do
  alias Chess.Board
  alias Chess.Movements.King
  alias Chess.Movements.Pawn
  alias Chess.Movements.Rook
  alias Chess.Piece

  @callback possibles(%Board{}, %Piece{}) :: List.t()

  @position_regex ~r/([a-h])([1-8])/

  @columns for n <- ?a..?h, do:  << n :: utf8 >>

  @maximum_line_size 8

  def movement_coord(:pawn, position), do: position
  def movement_coord(:king, position), do: "K#{position}"
  def movement_coord(:queen, position), do: "Q#{position}"
  def movement_coord(:bishop, position), do: "B#{position}"
  def movement_coord(:rook, position), do: "R#{position}"
  def movement_coord(:knight, position), do: "N#{position}"
  def movement_coord(_, _), do: {:error, :not_valid_piece}

  def line_from_position(%{matrix: matrix}, position) do
     case validate_position(position) do
      [_column, line] ->
        matrix.lines[String.to_atom("L#{line}")]
      error -> error
     end
  end

  def column_from_position(%{matrix: matrix}, position) do
     case validate_position(position) do
      [column, _line] ->
        matrix.columns[String.to_atom("C#{String.upcase(column)}")]
      error -> error
     end
  end

  def around_positions(%{current_position: current_position, color: color}) do
    case validate_position(current_position) do
      [_C, _L] = position ->
        [
          up(position, 1, color),
          diagonal_right_up(position, 1, color),
          right(position, 1, color),
          diagonal_right_down(position, 1, color),
          down(position, 1, color),
          diagonal_left_down(position, 1, color),
          left(position, 1, color),
          diagonal_left_up(position, 1, color)
        ]
      error -> error
     end
  end

  def maximum_line_size(), do: @maximum_line_size

  def possible_moves(board, %Piece{type: :pawn} = piece), do: Pawn.possibles(piece, board)
  def possible_moves(board, %Piece{type: :rook} = piece), do: Rook.possibles(piece, board)
  def possible_moves(board, %Piece{type: :king} = piece), do: King.possibles(piece, board)

  def up([column, line], steps, "white") when line < 8 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->
      line =
        line
                |> Kernel.+(step)

      "#{column}#{line}"
    end)
  end

  def up([column, line], steps, "black") when line > 1 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->
      line =
        line
                |> Kernel.-(step)

      "#{column}#{line}"
    end)
  end

  def up(_, _, _), do: []

  def down([column, line], steps, "white") when line > 1 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->
      line =
        line
                |> Kernel.-(step)

      "#{column}#{line}"
    end)
  end

  def down([column, line], steps, "black") when line < 8 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->
      line =
        line
                |> Kernel.+(step)

      "#{column}#{line}"
    end)
  end

  def down(_, _, _), do: []

  def left([column, line], steps, "white") when column != "a" do
    1..steps
    |> Enum.map(fn step ->
      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      "#{column}#{line}"
    end)
  end

  def left([column, line], steps, "black") when column != "h" do
    1..steps
    |> Enum.map(fn step ->
      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      "#{column}#{line}"
    end)
  end

  def left(_, _, _), do: []

  def right([column, line], steps, "white") when column != "h" do
    1..steps
    |> Enum.map(fn step ->
      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      "#{column}#{line}"
    end)
  end

  def right([column, line], steps, "black") when column != "a" do
    1..steps
    |> Enum.map(fn step ->
      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      "#{column}#{line}"
    end)
  end

  def right(_, _, _), do: []

  def diagonal_right_up([column, line], steps, "white") when column != "h" and line < 8 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      line = line |> Kernel.+(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_right_up([column, line], steps, "black") when column != "a" and line > 1 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      line = line |> Kernel.-(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_right_up(_, _, _), do: []

  def diagonal_left_up([column, line], steps, "white") when column != "a" and line < 8 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      line = line |> Kernel.+(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_left_up([column, line], steps, "black") when column != "h" and line > 1 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      line = line |> Kernel.-(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_left_up(_, _, _), do: []

  def diagonal_left_down([column, line], steps, "white") when column != "a" and line > 1 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      line = line |> Kernel.-(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_left_down([column, line], steps, "black") when column != "h" and line < 8 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      line = line |> Kernel.+(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_left_down(_, _, _), do: []

  def diagonal_right_down([column, line], steps, "white") when column != "h" and line > 1 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      line = line |> Kernel.-(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_right_down([column, line], steps, "black") when column != "a" and line < 8 and is_integer(steps) do
    1..steps
    |> Enum.map(fn step ->

      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      line = line |> Kernel.+(step)

      "#{column}#{line}"
    end)
  end

  def diagonal_right_down(_, _, _), do: []

  def validate_position(raw_position) do
    @position_regex
    |> Regex.match?(raw_position)
    |> if do
      [c, l] = Regex.run(@position_regex, raw_position) |> List.delete(raw_position)
      [c, l |> String.to_integer()]
    else
      {:error, :invalid_position}
    end
  end

  def filter_line(line, break_points, include_break \\ false) do
    if include_break do
      line
      |> Enum.reduce_while([], fn pos, acc ->
        if pos in break_points, do: {:halt, [pos | acc]}, else: {:cont, [pos | acc]}
      end)
    else
      line
      |> Enum.reduce_while([], fn pos, acc ->
        if pos in break_points, do: {:halt, acc}, else: {:cont, [pos | acc]}
      end)
    end
    |> Enum.reverse()
  end

  defp column_to_index(col) do
    @columns |> Enum.find_index(&(&1 == col))
  end

  defp index_to_column(index) do
    @columns |> Enum.at(index)
  end
end
