defmodule Packages do
  def list do
    File.read!("packages.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.trim(x) |> String.replace(~r/[^\w+]/, "") end)
    |> Enum.uniq()
  end
end
