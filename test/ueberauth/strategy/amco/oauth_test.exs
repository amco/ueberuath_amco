
defmodule Ueberauth.Strategy.Amco.OAuthTest do
  use ExUnit.Case

  alias Ueberauth.Strategy.Amco.OAuth
  alias Ueberauth.Strategy.Amco.Exceptions.MissingSiteConfiguration

  describe "client/1" do
    test "raises error when site config is missing" do
      assert_raise MissingSiteConfiguration, fn ->
        OAuth.client([])
      end
    end

    test "does not raise error when site config is present" do
      site = "https://myidp.example.com"
      client = OAuth.client(site: site)
      assert client.site == site
    end
  end
end
