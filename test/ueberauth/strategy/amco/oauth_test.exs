
defmodule Ueberauth.Strategy.Amco.OAuthTest do
  use ExUnit.Case

  alias Ueberauth.Strategy.Amco.OAuth
  alias Ueberauth.Strategy.Amco.Exceptions.MissingSiteConfiguration

  describe "client/1" do
    test "raises error when missing site configuration" do
      assert_raise MissingSiteConfiguration, fn ->
        OAuth.client([])
      end
    end

    test "does not raise error when site config is present" do
      assert OAuth.client(site: "https://myidp.example.com")
    end
  end
end
