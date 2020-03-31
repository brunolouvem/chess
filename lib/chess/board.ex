defmodule Chess.Board do
  defstruct positions: [], occupied_positions: [], pieces: %{}, last_movement: nil

  @columns ["a", "b", "c", "d", "e", "f", "g", "h"]
  @lines 1..8

  alias Chess.Piece
  alias Chess.Movements.Movement

  def create() do
    %__MODULE__{
      positions: generate_positions_matrix()
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
        %__MODULE__{occupied_positions: occupied_positions, pieces: pieces} = board,
        %Piece{current_position: position, type: piece_type} = piece,
        new_position
      ) do
    case Map.get(pieces, new_position) do
      %Piece{} = captured_piece ->
        board = delete_piece(board, captured_piece)

        move_piece(board, piece, new_position)

      _ ->
        occupied_positions = occupied_positions |> List.delete(position)
        piece = Piece.update_position(piece, new_position)
        pieces = pieces |> Map.drop([position]) |> Map.put(new_position, piece)

        movement_coord = Movement.movement_coord(piece_type, new_position)

        {%{
           board
           | occupied_positions: [new_position | occupied_positions],
             pieces: pieces,
             last_movement: movement_coord
         }, piece}
    end
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
    |> Enum.filter(fn {_k, p} -> p.color == color  end)
    |> Enum.map(fn  {k, _v} -> k end)
  end

  defp position_exists?(positions, position) do
    Enum.member?(positions, position)
  end

  defp position_available?(occupied_positions, position) do
    !Enum.member?(occupied_positions, position)
  end
end
