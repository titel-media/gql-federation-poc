defmodule ProductServiceTest do
  use ExUnit.Case
  doctest ProductService

  test "greets the world" do
    assert ProductService.hello() == :world
  end
end
