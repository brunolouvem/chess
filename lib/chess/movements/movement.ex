defmodule Chess.Movements.Movement do
  alias Chess.Movements.Pawn
  alias Chess.Movements.Rook

  alias Chess.Piece

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

  def maximum_line_size(), do: @maximum_line_size

  def calculate_steps(:horizontal, current_column, color) do
    index = column_to_index(current_column) |> Kernel.+(1)
    initial_index = @columns |> List.first() |> column_to_index() |> Kernel.+(1)
    final_index = @columns |> List.last() |> column_to_index() |> Kernel.+(1)

    steps_to_ini = index - initial_index
    steps_to_ini = if steps_to_ini <= 0, do: 0, else: steps_to_ini

    case color do
      "white" ->
        [steps_to_ini, final_index - index]
      _ ->
        [final_index - index, steps_to_ini]
    end
  end

  def calculate_steps(:vertical, current_line, color) do
    # current_line = String.to_integer(current_line)
    steps_to_ini = current_line - 1
    steps_to_ini = if steps_to_ini <= 0, do: 0, else: steps_to_ini

    case color do
      "white" ->
        [steps_to_ini, @maximum_line_size - current_line]
      _ ->
        [@maximum_line_size - current_line, steps_to_ini]
    end
  end

  def possible_moves(board, %Piece{type: :pawn} = piece), do: Pawn.possibles(piece, board)
  def possible_moves(board, %Piece{type: :rook} = piece), do: Rook.possibles(piece, board)

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

  def diagonal_right_up([column, line], steps, "white") when column != "h" and is_integer(steps) do
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

  def diagonal_right_up([column, line], steps, "black") when column != "a" and is_integer(steps) do
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

  def diagonal_left_up([column, line], steps, "white") when column != "a" and is_integer(steps) do
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

  def diagonal_left_up([column, line], steps, "black") when column != "h" and is_integer(steps) do
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
