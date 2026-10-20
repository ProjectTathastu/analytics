defmodule Plausible.GeoTest do
  use ExUnit.Case, async: true

  test "loads the configured geolocation database and resolves an IP address" do
    assert %{"country" => %{"iso_code" => "US"}} =
             Plausible.Geo.lookup("216.160.83.56")
  end
end
