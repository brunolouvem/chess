defmodule Chess.Game do
  defstruct board: nil, pgn: nil

  alias Chess.Board
  alias Chess.Movements.Movement
  alias Chess.Piece

  def new() do
    %__MODULE__{
      board: Board.create() |> initialize_pieces()
    }
  end

  def moves?(%__MODULE__{board: %Board{pieces: pieces} = board}, start_position) when is_binary(start_position) do
    piece = Map.get(pieces, start_position)
    Movement.get_movements(board, piece)
  end

  def moves?(_, _), do: {:error, :invalid_attributes}

  defp initialize_pieces(board) do
    board
    |> initialize_white()
    |> initialize_black()
  end

  defp initialize_white(%Board{} = board) do
    board
    |> white_definitions()
    |> Enum.reduce(board, fn definition, board_acc ->
      run_definition(definition, "white", board_acc)
    end)
  end

  defp initialize_black(%Board{} = board) do
    board
    |> black_definitions()
    |> Enum.reduce(board, fn definition, board_acc ->
      run_definition(definition, "black", board_acc)
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
      {:pawn, matrix.lines[:L2]},
    ]
  end

  defp black_definitions(%Board{matrix: matrix}) do
    [
      {:king, "e8"},
      {:queen, "d8"},
      {:bishop, ["c8", "f8"]},
      {:knight, ["b8", "g8"]},
      {:rook, ["a8", "h8"]},
      {:pawn, matrix.lines[:L7]},
    ]
  end
end
