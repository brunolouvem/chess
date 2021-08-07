defmodule Chess.Game do
  defstruct board: nil, pgn: [], color_turn: :white, turn: 1

  alias Chess.Board
  alias Chess.Movements.Movement
  alias Chess.Piece

  def new() do
    %__MODULE__{
      board: Board.create() |> initialize_pieces()
    }
  end

  def print(%{board: board}), do: Board.print(board)

  def next_turn?(%{color_turn: color_turn}), do: next_color_turn(color_turn)

  def moves?(%__MODULE__{board: %Board{pieces: pieces} = board}, start_position)
      when is_binary(start_position) do
    piece = Map.get(pieces, start_position)
    Movement.get_movements(board, piece)
  end

  def moves?(_, _), do: {:error, :invalid_attributes}

  def move(
        %__MODULE__{
          board: %Board{pieces: pieces} = board,
          color_turn: color,
          pgn: pgn,
          turn: turn
        } = game,
        start_position,
        end_position
      ) do
    with %Piece{} = piece <- Map.get(pieces, start_position),
         {true, _} <- {piece.color == color, :own},
         movements when is_list(movements) and length(movements) > 0 <-
           Movement.get_movements(board, piece),
         {%Movement{} = movement, _} <-
           {Movement.possible?(movements, end_position, piece.type), :possibilities} do
      {board, _} = Board.move_piece(board, movement)

      {turn_counter, pgn} = generate_pgn_and_counter(board, turn, pgn, color)

      %{game | board: board, color_turn: next_color_turn(color), turn: turn_counter, pgn: pgn}
    else
      nil -> {:error, :start_position_not_found}
      {false, :own} -> {:error, :this_piece_is_not_yours}
      {false, :possibilities} -> {:error, :this_movement_is_not_possible}
      _ -> game
    end
  end

  defp generate_pgn_and_counter(%Board{last_movement: last_movement}, turn, pgn, :white) do
    pgn = List.insert_at(pgn, -1, [last_movement])

    {turn, pgn}
  end

  defp generate_pgn_and_counter(%Board{last_movement: last_movement}, turn, pgn, :black) do
    [head_pgn] = pgn |> List.last()

    pgn = pgn |> List.delete_at(-1) |> List.insert_at(-1, [head_pgn, last_movement])

    {turn + 1, pgn}
  end

  def get_pgn(%__MODULE__{pgn: pgn}) do
    build_pgn_string(pgn, 1)
  end

  def build_pgn_string([], _), do: ""

  def build_pgn_string([head | []], counter) do
    "#{pgn_string(head, counter)}"
  end

  def build_pgn_string([head | rest], counter) do
    "#{pgn_string(head, counter)} #{build_pgn_string(rest, counter + 1)}"
  end

  defp pgn_string([white_move], counter) do
    "#{counter}. #{white_move}"
  end

  defp pgn_string([white_move, black_move], counter) do
    "#{counter}. #{white_move} #{black_move}"
  end

  defp next_color_turn(:white), do: :black
  defp next_color_turn(:black), do: :white

  defp initialize_pieces(board) do
    board
    |> initialize_white()
    |> initialize_black()
  end

  defp initialize_white(%Board{} = board) do
    board
    |> white_definitions()
    |> Enum.reduce(board, fn definition, board_acc ->
      run_definition(definition, :white, board_acc)
    end)
  end

  defp initialize_black(%Board{} = board) do
    board
    |> black_definitions()
    |> Enum.reduce(board, fn definition, board_acc ->
      run_definition(definition, :black, board_acc)
    end)
  end

  defp run_definition({type, positions}, color, board) when is_list(positions) do
    positions
    |> Enum.reduce(board, fn position, board_acc ->
      run_definition({type, position}, color, board_acc)
    end)
  end

  defp run_definition({type, position}, color, board) do
    piece = Piece.create(type, color, position)
    Board.add_piece(board, piece)
  end

  defp white_definitions(%Board{matrix: matrix}) do
    [
      {:king, "e1"},
      {:queen, "d1"},
      {:bishop, ["c1", "f1"]},
      {:knight, ["b1", "g1"]},
      {:rook, ["a1", "h1"]},
      {:pawn, matrix.lines[:L2]}
    ]
  end

  defp black_definitions(%Board{matrix: matrix}) do
    [
      {:king, "e8"},
      {:queen, "d8"},
      {:bishop, ["c8", "f8"]},
      {:knight, ["b8", "g8"]},
      {:rook, ["a8", "h8"]},
      {:pawn, matrix.lines[:L7]}
    ]
  end
end
