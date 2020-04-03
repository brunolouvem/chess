defmodule Chess.Movements.Movement do
  alias Chess.Board
  alias Chess.Movements.{Bishop, King, Pawn, Queen, Rook}
  alias Chess.Piece

  defstruct coords: [], start: nil, end: nil

  @callback possibles(%Board{}, %Piece{}) :: List.t()

  @position_regex ~r/([a-h])([1-8])/

  @columns for n <- ?a..?h, do: <<n::utf8>>

  @maximum_line_size 8
  @maximum_column_size 8

  def create(coords) when is_list(coords) do
    %__MODULE__{
      coords: coords,
      start: List.first(coords),
      end: List.last(coords)
    }
  end

  def create(_), do: {:error, :not_valid_coords}

  def maximum_line_size(), do: @maximum_line_size

  def possible_moves(board, %Piece{type: :bishop} = piece), do: Bishop.possibles(piece, board)
  def possible_moves(board, %Piece{type: :pawn} = piece), do: Pawn.possibles(piece, board)
  def possible_moves(board, %Piece{type: :rook} = piece), do: Rook.possibles(piece, board)
  def possible_moves(board, %Piece{type: :king} = piece), do: King.possibles(piece, board)
  def possible_moves(board, %Piece{type: :queen} = piece), do: Queen.possibles(piece, board)

  def movement_coord(:pawn, position), do: position
  def movement_coord(:king, position), do: "K#{position}"
  def movement_coord(:queen, position), do: "Q#{position}"
  def movement_coord(:bishop, position), do: "B#{position}"
  def movement_coord(:rook, position), do: "R#{position}"
  def movement_coord(:knight, position), do: "N#{position}"
  def movement_coord(_, _), do: {:error, :not_valid_piece}

  def diagonal(%{current_position: current_position}, %{positions: positions}) do
    case validate_position(current_position) do
      [column, line] ->
        # setting constants of algorithm
        # using color constant
        color = "white"
        column_index = column_to_index(column) + 1
        first_column = @columns |> List.first()
        first_line = 1
        main_diagonal_steps = 7
        main_diagonal_rf = 0

        cond do
          (rank_minus_file = line - column_index) < main_diagonal_rf ->
            start_col = abs(rank_minus_file) |> index_to_column()
            steps = @maximum_column_size + rank_minus_file

            ["#{start_col}#{first_line}"] ++
              (diagonal_right_up([start_col, first_line], steps, color, positions)
               |> Enum.reverse())

          (rank_minus_file = line - column_index) > main_diagonal_rf ->
            start_line = 1 + abs(rank_minus_file)
            steps = @maximum_line_size - rank_minus_file

            ["#{first_column}#{start_line}"] ++
              (diagonal_right_up([first_column, start_line], steps, color, positions)
               |> Enum.reverse())

          line - column_index == main_diagonal_rf ->
            ["#{first_column}#{first_line}"] ++
              (diagonal_right_up(
                 [first_column, first_line],
                 main_diagonal_steps,
                 color,
                 positions
               )
               |> Enum.reverse())
        end

      error ->
        error
    end
  end

  def anti_diagonal(%{current_position: current_position}, %{positions: positions}) do
    case validate_position(current_position) do
      [column, line] ->
        # setting constants of algorithm
        # using color constant
        color = "white"
        column_index = column_to_index(column) + 1
        first_column = @columns |> List.first()
        last_line = 8
        main_diagonal_steps = 7
        main_diagonal_rf = 9

        cond do
          (rank_minus_file = line + column_index) > main_diagonal_rf ->
            start_col = (abs(rank_minus_file) - @maximum_column_size - 1) |> index_to_column()
            steps = abs(1 - rank_minus_file)

            ["#{start_col}#{last_line}"] ++
              (diagonal_right_down([start_col, last_line], steps, color, positions)
               |> Enum.reverse())

          (rank_minus_file = line + column_index) < main_diagonal_rf ->
            start_line = rank_minus_file - 1
            steps = rank_minus_file + 1

            ["#{first_column}#{start_line}"] ++
              (diagonal_right_down([first_column, start_line], steps, color, positions)
               |> Enum.reverse())

          line + column_index == main_diagonal_rf ->
            ["#{first_column}#{last_line}"] ++
              (diagonal_right_down(
                 [first_column, last_line],
                 main_diagonal_steps,
                 color,
                 positions
               )
               |> Enum.reverse())
        end

      error ->
        error
    end
  end

  def line_from_position(%{matrix: matrix}, %{current_position: position}) do
    case validate_position(position) do
      [_column, line] ->
        matrix.lines[String.to_atom("L#{line}")]

      error ->
        error
    end
  end

  def column_from_position(%{matrix: matrix}, %{current_position: position}) do
    case validate_position(position) do
      [column, _line] ->
        matrix.columns[String.to_atom("C#{String.upcase(column)}")]

      error ->
        error
    end
  end

  def around_positions(%{current_position: current_position, color: color}, %{
        positions: positions
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

  def centralize_position_in_sequence(sequence, current_position) do
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

  defp index_to_column(index) do
    @columns |> Enum.at(index)
  end
end
