defmodule Chess.Matrix do
  @moduledoc """
  Module responsible for chess coordinates
  """
  defstruct lines: [], columns: [], diagonals: [], anti_diagonals: []

  @column_prefix "C"
  @line_prefix "L"
  @diagonal_prefix "D"
  @anti_diagonal_prefix "AD"

  def new(lines, columns) when is_list(lines) and is_list(columns) do
    %__MODULE__{}
    |> load_matrix(columns, lines)
  end

  defp load_matrix(matrix, columns, lines) do
    columns
    |> Enum.reduce(matrix, fn column, acc_matrix ->
      column_index = columns |> Enum.find_index(&(&1 == column)) |> Kernel.+(1)

      lines
      |> Enum.reduce(acc_matrix, fn line, acc ->
        position = "#{column}#{line}"

        diagonal_key = build_key(@diagonal_prefix, line - column_index)
        anti_diagonal_key = build_key(@anti_diagonal_prefix, line + column_index)
        line_key = build_key(@line_prefix, line)
        column_key = build_key(@column_prefix, column)

        %{
          acc
          | diagonals: create_or_update_keyword(acc.diagonals, diagonal_key, position),
            anti_diagonals:
              create_or_update_keyword(acc.anti_diagonals, anti_diagonal_key, position),
            lines: create_or_update_keyword(acc.lines, line_key, position),
            columns: create_or_update_keyword(acc.columns, column_key, position)
        }
      end)
    end)
  end

  def key(:line, value), do: build_key(@line_prefix, value)
  def key(:column, value), do: build_key(@column_prefix, value)
  def key(:diagonal, value), do: build_key(@diagonal_prefix, value)
  def key(:anti_diagonal, value), do: build_key(@anti_diagonal_prefix, value)

  defp build_key(prefix, value) when is_binary(value),
    do: String.to_atom("#{prefix}#{String.upcase(value)}")

  defp build_key(prefix, value) when is_integer(value) and value < 0,
    do: String.to_atom("#{prefix}M#{abs(value)}")

  defp build_key(prefix, value), do: String.to_atom("#{prefix}#{value}")

  defp create_or_update_keyword(bucket, key, new_values) do
    values = Keyword.get(bucket, key, []) ++ [new_values]
    Keyword.put(bucket, key, values)
  end
end
