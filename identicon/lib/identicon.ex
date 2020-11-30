defmodule Identicon do

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

  def filter_odds(grid) do
    Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end
  end

  def reflect_columns([first, second, _tail] = grid_row) do
    grid_row ++ [second, first]
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end

end
