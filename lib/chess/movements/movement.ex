defmodule Chess.Movements.Movement do
  alias Chess.Board
  alias Chess.Matrix
  alias Chess.Movements.{Bishop, King, Knight, Pawn, Queen, Rook}
  alias Chess.Piece

  defstruct coords: [], start: nil, end: nil

  @callback possibles(%Board{}, %Piece{}) :: List.t()

  @position_regex ~r/([a-h])([1-8])/

  @columns for n <- ?a..?h, do: <<n::utf8>>

  @maximum_line_size 8

  def create([]), do: {:error, :not_valid_coords}

  def create(coords) when is_list(coords) do
    %__MODULE__{
      coords: coords,
      start: List.first(coords),
      end: List.last(coords)
    }
  end

  def create(_), do: {:error, :not_valid_coords}

  def maximum_line_size(), do: @maximum_line_size

  def get_movements(board, %Piece{type: type} = piece),
    do: movement_module(type).possibles(piece, board)

  defp movement_module(:bishop), do: Bishop
  defp movement_module(:pawn), do: Pawn
  defp movement_module(:rook), do: Rook
  defp movement_module(:knight), do: Knight
  defp movement_module(:king), do: King
  defp movement_module(:queen), do: Queen

  def movement_coord(:pawn, position), do: position
  def movement_coord(:king, position), do: "K#{position}"
  def movement_coord(:queen, position), do: "Q#{position}"
  def movement_coord(:bishop, position), do: "B#{position}"
  def movement_coord(:rook, position), do: "R#{position}"
  def movement_coord(:knight, position), do: "N#{position}"
  def movement_coord(_, _), do: {:error, :not_valid_piece}

  def diagonal_from_position(%{matrix: matrix}, %{current_position: position}) do
    case validate_position(position) do
      [column, line] ->
        column_index = column_to_index(column) + 1

        matrix.diagonals[Matrix.key(:diagonal, line - column_index)]

      error ->
        error
    end
  end

  def anti_diagonal_from_position(%{matrix: matrix}, %{current_position: position}) do
    case validate_position(position) do
      [column, line] ->
        column_index = column_to_index(column) + 1

        matrix.anti_diagonals[Matrix.key(:anti_diagonal, line + column_index)]

      error ->
        error
    end
  end

  def line_from_position(%{matrix: matrix}, %{current_position: position}) do
    case validate_position(position) do
      [_column, line] ->
        matrix.lines[Matrix.key(:line, line)]

      error ->
        error
    end
  end

  def column_from_position(%{matrix: matrix}, %{current_position: position}) do
    case validate_position(position) do
      [column, _line] ->
        matrix.columns[Matrix.key(:column, column)]

      error ->
        error
    end
  end

  def around_positions(%{positions: positions}, %{
        current_position: current_position,
        color: color
      }) do
    case validate_position(current_position) do
      [_C, _L] = position ->
        [
          up(position, 1, color, positions),
          diagonal_right_up(position, 1, color, positions),
          right(position, 1, color, positions),
          diagonal_right_down(position, 1, color, positions),
          down(position, 1, color, positions),
          diagonal_left_down(position, 1, color, positions),
          left(position, 1, color, positions),
          diagonal_left_up(position, 1, color, positions)
        ]

      error ->
        error
    end
  end

  defp build_position(column_index, line, positions) do
    case index_to_column(column_index) do
      nil ->
        nil

      column ->
        position = "#{column}#{line}"
        if position in positions, do: position, else: nil
    end
  end

  def l_positions_from_position(%{positions: positions}, %{current_position: position}) do
    case validate_position(position) do
      {:error, _} = error ->
        error

      [column, line] ->
        column_index = column_to_index(column)
        # b1 = 2,1

        up_left = build_position(column_index - 1, line + 2, positions)
        up_right = build_position(column_index + 1, line + 2, positions)

        down_left = build_position(column_index - 1, line - 2, positions)
        down_right = build_position(column_index + 1, line - 2, positions)

        left_up = build_position(column_index - 2, line + 1, positions)
        left_down = build_position(column_index - 2, line - 1, positions)

        right_up = build_position(column_index + 2, line + 1, positions)
        right_down = build_position(column_index + 2, line - 1, positions)

        [
          up_left,
          up_right,
          down_left,
          down_right,
          left_up,
          left_down,
          right_up,
          right_down
        ]
        |> Enum.filter(&(!is_nil(&1)))
    end
  end

  def up([column, line], steps, "white", all_positions) when line < 8 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      line = line |> Kernel.+(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def up([column, line], steps, "black", all_positions) when line > 1 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      line =
        line
        |> Kernel.-(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def up(_, _, _, _), do: []

  def down([column, line], steps, "white", all_positions) when line > 1 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      line =
        line
        |> Kernel.-(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def down([column, line], steps, "black", all_positions) when line < 8 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      line =
        line
        |> Kernel.+(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def down(_, _, _, _), do: []

  def left([column, line], steps, "white", all_positions) when column != "a" do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def left([column, line], steps, "black", all_positions) when column != "h" do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def left(_, _, _, _), do: []

  def right([column, line], steps, "white", all_positions) when column != "h" do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def right([column, line], steps, "black", all_positions) when column != "a" do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def right(_, _, _, _), do: []

  def diagonal_right_up([column, line], steps, "white", all_positions)
      when column != "h" and line < 8 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      line = line |> Kernel.+(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def diagonal_right_up([column, line], steps, "black", all_positions)
      when column != "a" and line > 1 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      line = line |> Kernel.-(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def diagonal_right_up(_, _, _, _), do: []

  def diagonal_left_up([column, line], steps, "white", all_positions)
      when column != "a" and line < 8 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      line = line |> Kernel.+(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def diagonal_left_up([column, line], steps, "black", all_positions)
      when column != "h" and line > 1 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      line = line |> Kernel.-(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def diagonal_left_up(_, _, _, _), do: []

  def diagonal_left_down([column, line], steps, "white", all_positions)
      when column != "a" and line > 1 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      line = line |> Kernel.-(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def diagonal_left_down([column, line], steps, "black", all_positions)
      when column != "h" and line < 8 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      line = line |> Kernel.+(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def diagonal_left_down(_, _, _, _), do: []

  def diagonal_right_down([column, line], steps, "white", all_positions)
      when column != "h" and line > 1 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.+(step)
        |> index_to_column()

      line = line |> Kernel.-(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def diagonal_right_down([column, line], steps, "black", all_positions)
      when column != "a" and line < 8 and is_integer(steps) do
    1..steps
    |> Enum.reduce_while([], fn step, acc ->
      column =
        column
        |> column_to_index()
        |> Kernel.-(step)
        |> index_to_column()

      line = line |> Kernel.+(step)

      if "#{column}#{line}" in all_positions,
        do: {:cont, ["#{column}#{line}" | acc]},
        else: {:halt, acc}
    end)
  end

  def diagonal_right_down(_, _, _, _), do: []

  def validate_position(raw_position) do
    @position_regex
    |> Regex.match?(raw_position)
    |> if do
      extract_position(raw_position)
    else
      {:error, :invalid_position}
    end
  end

  def extract_position(raw_position) when is_binary(raw_position) do
    [c, l] = Regex.run(@position_regex, raw_position) |> List.delete(raw_position)
    [c, l |> String.to_integer()]
  end

  def extract_position(_), do: nil

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

  def centralize_position_in_sequence(sequence, current_position) when is_list(sequence) do
    idx_on_seq = sequence |> Enum.find_index(&(&1 == current_position))

    if idx_on_seq == 0 do
      seq_before = Enum.slice(sequence, 0..idx_on_seq) |> Enum.reverse()
      seq_after = Enum.slice(sequence, (idx_on_seq + 1)..(length(sequence) - 1))
      {seq_before, seq_after}
    else
      seq_before = Enum.slice(sequence, 0..(idx_on_seq - 1)) |> Enum.reverse()
      seq_after = Enum.slice(sequence, (idx_on_seq + 1)..(length(sequence) - 1))
      {seq_before, seq_after}
    end
  end

  defp column_to_index(col) do
    @columns |> Enum.find_index(&(&1 == col))
  end

  defp index_to_column(index) when index >= 0 do
    @columns |> Enum.at(index)
  end

  defp index_to_column(_), do: nil
end
