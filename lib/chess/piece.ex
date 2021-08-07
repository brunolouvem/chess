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
    :black,
    :white
  ]

  defstruct current_position: nil, start_position: nil, color: nil, type: nil

  def opponent_color(:white), do: :black
  def opponent_color(:black), do: :white

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

  def show_unicode(%__MODULE__{color: :black, type: :king}), do: "\u2654"
  def show_unicode(%__MODULE__{color: :black, type: :queen}), do: "\u2655"
  def show_unicode(%__MODULE__{color: :black, type: :rook}), do: "\u2656"
  def show_unicode(%__MODULE__{color: :black, type: :bishop}), do: "\u2657"
  def show_unicode(%__MODULE__{color: :black, type: :knight}), do: "\u2658"
  def show_unicode(%__MODULE__{color: :black, type: :pawn}), do: "\u2659"
  def show_unicode(%__MODULE__{color: :white, type: :king}), do: "\u265A"
  def show_unicode(%__MODULE__{color: :white, type: :queen}), do: "\u265B"
  def show_unicode(%__MODULE__{color: :white, type: :rook}), do: "\u265C"
  def show_unicode(%__MODULE__{color: :white, type: :bishop}), do: "\u265D"
  def show_unicode(%__MODULE__{color: :white, type: :knight}), do: "\u265E"
  def show_unicode(%__MODULE__{color: :white, type: :pawn}), do: "\u265F"
  def show_unicode(nil), do: " "
end
