defmodule Identicon do

  @moduledoc """
    Creates an identicon for a given text string
  """

  # Take in string - DONE
  # Calculater an MD5 from Erlang - DONE
  # Grab first 3 elements as color - DONE
  # Create grid (list of lists) - DONE
  # Mirror grid - DONE
  # Flatten - DONE
  # Filter to evens in Grid - DONE
  # Create corner calculations - DONE
  # Draw images with erlang :egd - DONE
  # Save to file - DONE

  @doc """
    Main runner for the project

    Examples

      iex> Identicon.runner("Andy")
      :ok

  """
  def runner(input) do
    input
    |> hash_input
    |> pick_color
    |> create_grid
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def create_grid(%Identicon.Image{hex: hex} = image) do
    # want the chunk behavior of dropping extra elements
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&reflect_columns/1)
      |> List.flatten
      |> Enum.with_index
      |> filter_odds

    %Identicon.Image{image | grid: grid}
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end


  @doc """
    Basic filter to check if code integer is divisible by two (even) inside the tuple grid structure
    {code, index}

    Examples

      iex> filtered_list = Identicon.filter_odds([{1, 1}, {245, 2}, {244, 15}])
      [{244, 15}]
      iex> filtered_list
      [{244, 15}]
      iex> length filtered_list
      1

  """
  @spec filter_odds({integer, any}) :: [{integer, any}]
  def filter_odds(grid) do
    Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end
  end

  @doc """
    We assume a 5x5 grid. Each row is a list of three numbers (the first three columns).
    The first and second need to be reflected a, b, c -> a, b, c, b, c

    Examples

      iex> Identicon.reflect_columns([:a, :b, :c])
      [:a, :b, :c, :b, :a]

      iex> Identicon.reflect_columns(["Jeff", "Dan", 1234])
      ["Jeff", "Dan", 1234, "Dan", "Jeff"]

  """
  def reflect_columns([first, second, _tail] = grid_row) do
    grid_row ++ [second, first]
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end


  @doc """
    Uses the crypto and binary Erlang libraries to hash text string

    Examples

      iex> Identicon.hash_input("asdf")
      %Identicon.Image{
        color: nil,
        grid: nil,
        hex: [145, 46, 200, 3, 178, 206, 73, 228, 165, 65, 6, 141, 73, 90, 181, 112],
        pixel_map: nil
      }

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end

end
