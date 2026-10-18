defmodule Plausible.MixSetupTest do
  use ExUnit.Case, async: true

  test "setup downloads the geolocation database required for application startup" do
    setup_tasks = Mix.Project.config()[:aliases][:setup]

    assert "download_country_database" in setup_tasks

    assert Enum.find_index(setup_tasks, &(&1 == "download_country_database")) <
             Enum.find_index(setup_tasks, &(&1 == "ecto.setup"))
  end
end
