defmodule Mix.Tasks.DownloadCountryDatabaseTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.DownloadCountryDatabase

  test "returns the downloaded database body for a successful response" do
    response = %HTTPoison.Response{status_code: 200, body: "database contents"}

    assert DownloadCountryDatabase.response_body!(response) == "database contents"
  end

  test "fails setup when the geolocation database source returns an error" do
    response = %HTTPoison.Response{status_code: 503, body: "unavailable"}

    assert_raise Mix.Error, ~r/HTTP status 503/, fn ->
      DownloadCountryDatabase.response_body!(response)
    end
  end
end
