defmodule Plausible.MixSetupTest do
  use ExUnit.Case, async: true

  test "setup downloads the geolocation database required for application startup" do
    setup_tasks = Mix.Project.config()[:aliases][:setup]

    assert "download_country_database" in setup_tasks
  end
end
