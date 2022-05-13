defmodule Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser.IdpAdapterTest do
  use ExUnit.Case

  import Mock

  alias Plug.Conn
  alias Ueberauth.Strategy.Amco.API
  alias Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser.IdpAdapter

  setup do
    {:ok, %{conn: %Conn{}}}
  end

  @userinfo %{
    "sub" => 1,
    "email" => "darth@email.com",
    "given_name" => "Darth",
    "family_name" => "Vader",
    "phone_number" => "+523344556677"
  }

  describe "call/2" do
    test "when source is session and access token is not present", %{conn: conn} do
      with_mock Conn, get_session: fn _, _ -> nil end do
        assert IdpAdapter.call(conn, [access_token_source: :session]) ==
          {:error, :access_token_required}
      end
    end

    test "when source is headers and access token is not present", %{conn: conn} do
      assert IdpAdapter.call(conn, [access_token_source: :headers]) ==
        {:error, :access_token_required}
    end

    test "when access token is in the session and it is valid", %{conn: conn} do
      with_mocks [
        {API, [], userinfo: fn _ -> {:ok, @userinfo} end},
        {Conn, [], get_session: fn _, _ -> "XXXX" end}
      ] do
        {:ok, user} = IdpAdapter.call(conn, [access_token_source: :session])
        assert user.id == @userinfo["sub"]
        assert user.email == @userinfo["email"]
        assert user.first_name == @userinfo["given_name"]
        assert user.last_name == @userinfo["family_name"]
        assert user.phone_number == @userinfo["phone_number"]
      end
    end

    test "when access token is in the headers and it is valid", %{conn: conn} do
      with_mock API, userinfo: fn _ -> {:ok, @userinfo} end do
        conn = conn |> Conn.put_req_header("authorization", "Bearer XXX")
        {:ok, user} = IdpAdapter.call(conn, [access_token_source: :headers])
        assert user.id == @userinfo["sub"]
        assert user.email == @userinfo["email"]
        assert user.first_name == @userinfo["given_name"]
        assert user.last_name == @userinfo["family_name"]
        assert user.phone_number == @userinfo["phone_number"]
      end
    end
  end
end
