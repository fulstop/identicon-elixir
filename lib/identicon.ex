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
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
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
  Selects the first three values from the hex list to determine an rgb value.
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
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row(&1))
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Mirrors the provided list.
  """
  def mirror_row(row) do
    # [200, 145, 190]
    [first, second, _] = row
    row ++ [second, first]
    # [200, 145, 190, 145, 200]
  end

  @doc """
  Filters out odd codes for the grid.
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      grid
      |> Enum.filter(fn({code, _}) -> rem(code, 2) == 0 end)

    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map grid, fn({_, index}) ->
        horz = rem(index, 5) * 50
        vert = div(index, 5) * 50

        top_left  = {horz, vert}
        btm_right = {horz + 50, vert + 50}

        {top_left, btm_right}
      end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end
end
