defmodule Chess.PGN do
  # Piece Letter <> (file for ambiguity) <> capture sign <> position <> check sign

  def movetext(piece_type, origin_file, position, special_move?, ambiguity?, capture?, check?) do
    case special_move? do
      :kingside_castling ->
        "O-O"

      :queenside_castling ->
        "O-O-O"

      _ ->
        piece_type
        |> parse_piece_letter()
        |> resolve_ambiguity(piece_type, ambiguity?, origin_file)
        |> resolve_capture(piece_type, origin_file, capture?, special_move?)
        |> Kernel.<>(position)
        |> resolve_en_passant(special_move?)
        |> resolve_check(check?)
    end
  end

  defp resolve_ambiguity(movetext, :pawn, _, _), do: movetext
  defp resolve_ambiguity(movetext, _, true, origin_file), do: movetext <> origin_file
  defp resolve_ambiguity(movetext, _, _, _), do: movetext

  defp resolve_capture(movetext, :pawn, origin_file, false, :en_passant),
    do: movetext <> origin_file <> "x"

  defp resolve_capture(movetext, :pawn, origin_file, true, _), do: movetext <> origin_file <> "x"
  defp resolve_capture(movetext, _, _, true, _), do: movetext <> "x"
  defp resolve_capture(movetext, _, _, _, _), do: movetext

  defp resolve_en_passant(movetext, :en_passant), do: movetext <> " e.p."
  defp resolve_en_passant(movetext, _), do: movetext

  defp resolve_check(movetext, true), do: movetext <> "+"
  defp resolve_check(movetext, _), do: movetext

  defp parse_piece_letter(:pawn), do: ""
  defp parse_piece_letter(:king), do: "K"
  defp parse_piece_letter(:queen), do: "Q"
  defp parse_piece_letter(:bishop), do: "B"
  defp parse_piece_letter(:rook), do: "R"
  defp parse_piece_letter(:knight), do: "N"
end
