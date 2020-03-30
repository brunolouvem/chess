defmodule Chess.Piece do
  @piece_types [
    :bishop,
    :king,
    :knight,
    :pawn,
    :queen,
    :rook
  ]

  @piece_colors [
    "black",
    "white"
  ]

  defstruct current_position: nil, start_position: nil, color: nil, type: nil

  def opponent_color("white"), do: "black"
  def opponent_color("black"), do: "white"

  @spec position(piece :: %__MODULE__{}) :: String.t() | nil
  def position(%__MODULE__{} = piece) do
    Map.get(piece, :current_position)
  end

  def position(_), do: {:error, :invalid_piece}

  @spec update_position(piece :: %__MODULE__{}, position :: String.t()) :: %__MODULE__{}
  def update_position(%__MODULE__{} = piece, position) do
    %{piece | current_position: position}
  end

  def update_position(_, _), do: {:error, :invalid_piece}

  @spec create(type :: Atom.t(), color :: String.t(), position :: String.t()) :: %__MODULE__{}
  def create(type, color, position)
      when type in @piece_types and color in @piece_colors and is_binary(position) do
    %__MODULE__{
      current_position: position,
      start_position: position,
      color: color,
      type: type
    }
  end

  def create(_, _, _), do: {:error, :invalid_fields}
end
