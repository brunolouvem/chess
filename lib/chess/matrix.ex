defmodule Chess.Matrix do
  @moduledoc """
  Module responsible for chess coordinates
  """
  defstruct lines: [], columns: []

  @column_prefix "C"
  @line_prefix "L"

  def new(lines, columns) when is_list(lines) and is_list(columns) do
    %__MODULE__{}
    |> lines(lines, columns)
    |> columns(columns, lines)
  end

  def plain(matrix), do: Enum.map(matrix.lines, fn {_, v} -> v end)

  defp lines(matrix, lines, columns) do
    lines
    |> Enum.reduce(matrix, fn element, matrix ->
      key = "#{@line_prefix}#{element}" |> String.to_atom()
      value = Enum.map(columns, &"#{&1}#{element}")

      %{matrix | lines: Keyword.put_new(matrix.lines, key, value)}
    end)
  end

  defp columns(matrix, columns, lines) do
    columns
    |> Enum.reduce(matrix, fn element, matrix ->
      key = "#{@column_prefix}#{String.upcase(element)}" |> String.to_atom()
      value = Enum.map(lines, &"#{element}#{&1}")

      %{matrix | columns: Keyword.put_new(matrix.columns, key, value)}
    end)
  end
end
