defmodule Chess.Board do
  alias Chess.{Matrix, PGN}

  defstruct positions: [],
            occupied_positions: [],
            pieces: %{},
            last_movement: nil,
            matrix: %Matrix{},
            attack_table: [
              black: [],
              white: []
            ],
            color_in_check: nil

  @columns ["a", "b", "c", "d", "e", "f", "g", "h"]
  @lines 1..8

  alias Chess.Piece
  alias Chess.Movements.Movement

  def create() do
    %__MODULE__{
      positions: generate_positions_matrix(),
      matrix: Matrix.new(Enum.map(@lines, & &1), @columns)
    }
  end

  defp generate_positions_matrix() do
    @columns
    |> Enum.reduce([], fn column, acc ->
      line = @lines |> Enum.map(fn line -> "#{column}#{line}" end) |> Enum.reverse()
      [line | acc]
    end)
    |> List.flatten()
    |> Enum.reverse()
  end

  def add_piece(
        %__MODULE__{positions: positions, occupied_positions: occupied_positions, pieces: pieces} =
          board,
        %Piece{current_position: position} = piece
      ) do
    with {true, _} <- {position_exists?(positions, position), :existence},
         {true, _} <- {position_available?(occupied_positions, position), :availability} do
      pieces = Map.put(pieces, position, piece)
      %{board | occupied_positions: [position | occupied_positions], pieces: pieces}
    else
      {false, :existence} -> {:error, :not_exist_position_of_piece}
      _ -> {:error, :not_available_position_of_piece}
    end
  end

  def add_piece(%__MODULE__{}, _), do: {:error, :not_valid_piece}
  def add_piece(_, %Piece{}), do: {:error, :not_valid_board}

  def move_piece(
        %__MODULE__{pieces: pieces, positions: positions} = board,
        %Movement{end: end_position, start: start_position, special_move: special_move} = movement
      ) do
    IO.inspect(movement)

    case {Map.get(pieces, start_position), Map.get(pieces, end_position), special_move} do
      {%Piece{} = piece, %Piece{} = captured_piece, _} ->
        board = delete_piece(board, captured_piece)

        update_board_positions(board, piece, end_position, :capture)

      {%Piece{} = piece, _, :en_passant} ->
        captured_position =
          Movement.en_passant_capture_position(end_position, piece.color, positions)

        captured_piece = Map.get(pieces, captured_position)

        board = delete_piece(board, captured_piece)

        update_board_positions(board, piece, end_position, :en_passant)

      {%Piece{} = piece, _, false} ->
        update_board_positions(board, piece, end_position)

      {%Piece{} = piece, _, castling} ->
        rook_movement = Movement.castling_rook_movement(castling, piece.color)

        {board, _} = move_piece(board, rook_movement)

        update_board_positions(board, piece, end_position, castling)
    end
  end

  defp ambiguity?(
         %__MODULE__{pieces: pieces} = board,
         %Piece{type: type, color: color, current_position: position},
         new_position
       ) do
    with %Piece{current_position: current_position} = another_piece
         when current_position != position <- find_piece_from_type_and_color(pieces, color, type),
         movements when is_list(movements) and length(movements) > 0 <-
           Movement.get_movements(board, another_piece),
         %Movement{} <- Movement.possible?(movements, new_position, another_piece.type) do
      true
    else
      _ ->
        false
    end
  end

  defp generate_movetext(
         %__MODULE__{} = board,
         %Piece{type: type, current_position: current_position} = piece,
         new_position,
         special
       ) do
    [origin_file, _] = Movement.extract_position(current_position)

    ambiguity? = ambiguity?(board, piece, new_position)
    {special, capture?} = if special == :capture, do: {nil, true}, else: {special, false}

    check? = not is_nil(board.color_in_check)

    PGN.movetext(type, origin_file, new_position, special, ambiguity?, capture?, check?)
  end

  defp update_check_status([], board, _), do: board

  defp update_check_status(movements, board, opponent_color) do
    movements
    |> Enum.reduce(board, fn movement, acc ->
      opponent_attack_table = Keyword.get(acc.attack_table, opponent_color) ++ [movement.start]

      attack_table = Keyword.put(acc.attack_table, opponent_color, opponent_attack_table)

      %{acc | attack_table: attack_table, color_in_check: opponent_color}
    end)
  end

  defp check?(%__MODULE__{} = board, %Piece{} = piece) do
    opponent_color = piece.color |> Piece.opponent_color()
    {_, opponent_king} = find_piece_from_type_and_color(board.pieces, opponent_color, :king)
    board
    |> check_last_move_attack(piece, opponent_king)
    |> check_discovered_attack(piece, opponent_king)
  end

  defp check_last_move_attack(%__MODULE__{} = board, %Piece{} = piece, %Piece{} = opponent_king) do
    board
    |> Movement.get_movements(piece)
    |> Enum.filter(& &1.end == opponent_king.current_position)
    |> update_check_status(board, opponent_king.color)
  end

  def check_discovered_attack(%__MODULE__{pieces: pieces} = board, %Piece{} = piece, %Piece{current_position: current_position} = opponent_king)  do

    opponent_positions = positions_by_color(board, piece.color)
    allies_positions = board |> positions_by_color(opponent_king.color) |> List.delete(current_position)
    attack_table = board.attack_table[opponent_king.color]

    [
      Movement.column_from_position(board, opponent_king),
      Movement.line_from_position(board, opponent_king),
      Movement.diagonal_from_position(board, opponent_king),
      Movement.anti_diagonal_from_position(board, opponent_king)
    ]
    |> Enum.reduce([], fn line, acc ->
      {line_before, line_after} =
        line
        |> Movement.centralize_position_in_sequence(current_position)

      acc ++ [line_before , line_after] |> Enum.filter(& length(&1) > 0)
    end)
    |> Enum.reduce([], fn line, acc ->
      move =
        line
        |> Movement.filter_line(allies_positions)
        |> case do
          [^current_position] -> []
          ^line -> line
          _ -> []
        end
        |> Movement.filter_line(opponent_positions, true)
        |> Movement.create()

      acc ++ [move]
    end)
    |> Enum.filter(fn line -> not is_tuple(line) end)
    |> Enum.filter(fn line -> line.end not in attack_table end)
    |> Enum.filter(fn line -> line.end in opponent_positions end)
    |> Enum.filter(fn line ->
      (pieces
      |> Map.get(line.end)
      |> Map.get(:type)) in [:bishop, :queen, :rook]
    end)
    |> update_check_status(board, opponent_king.color)
  end

  defp update_board_positions(
         %{occupied_positions: occupied_positions, pieces: pieces} = board,
         %{current_position: position} = piece,
         new_position,
         special \\ nil
       ) do
    occupied_positions = occupied_positions |> List.delete(position)

    updated_piece = Piece.update_position(piece, new_position)

    pieces = pieces |> Map.drop([position]) |> Map.put(new_position, updated_piece)

    board = check?(board, updated_piece)

    movetext = generate_movetext(board, piece, new_position, special)

    {%{
       board
       | occupied_positions: [new_position | occupied_positions],
         pieces: pieces,
         last_movement: movetext
     }, piece}
  end

  def delete_piece(
        %__MODULE__{occupied_positions: occupied_positions, pieces: pieces} = board,
        %Piece{current_position: position}
      ) do
    pieces = Map.drop(pieces, [position])
    occupied_positions = List.delete(occupied_positions, position)
    %{board | occupied_positions: occupied_positions, pieces: pieces}
  end

  def delete_piece(%__MODULE__{}, _), do: {:error, :not_valid_piece}
  def delete_piece(_, %Piece{}), do: {:error, :not_valid_board}

  def positions_by_color(%__MODULE__{pieces: pieces}, color) do
    pieces
    |> Enum.filter(fn {_k, p} -> p.color == color end)
    |> Enum.map(fn {k, _v} -> k end)
  end

  defp find_piece_from_type_and_color(pieces, color, type) do
    pieces
    |> Enum.find(fn {_, p} -> p.type == type and p.color == color end)
  end

  defp position_exists?(positions, position) do
    Enum.member?(positions, position)
  end

  defp position_available?(occupied_positions, position) do
    !Enum.member?(occupied_positions, position)
  end

  def print(%__MODULE__{pieces: pieces, matrix: matrix} = _position) do
    matrix.lines
    |> Enum.map(&print_line(&1, pieces))
    |> Enum.join("\n")
    |> IO.puts()
  end

  def print_line({_, line}, pieces) do
    Enum.map(line, fn p ->
      pieces
      |> Map.get(p)
      |> Piece.show_unicode()
      |> Kernel.<>(" ")
    end)
  end
end
