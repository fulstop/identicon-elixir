defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
  Generates an image from a provided string.
  """
  def create(input) do
    input
    |> generate_hash
    |> pick_color
    |> build_grid
  end

  @doc """
  Returns a list from a hashed string.
  """
  def generate_hash(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
  Selects the first three values from the hex list.
  This is a more verbose implementation to avoid using pattern
  matching in the arguments so that we can use it for comparison.
  """
  def pick_color(image) do
    %Identicon.Image{hex: hex_list} = image
    [r, g, b | _] = hex_list
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  Builds a list for the grid.
  """
  def build_grid(%Identicon.Image{hex: hex} = _) do
    hex
    |> Enum.chunk(3)
    |> Enum.map(&mirror_row(&1))
  end

  @doc """
  Mirrors the provided array.
  """
  def mirror_row(row) do
    # [200, 145, 190]
    [first, second, _] = row
    row ++ [second, first]
    # [200, 145, 190, 145, 200]
  end
end
