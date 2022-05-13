defmodule Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser.MockAdapter do
  @moduledoc """
  This adapter just returns the connection. The purpose of this module
  is to be used in test environment to avoid making request to the
  identity provider to authenticate users.
  """

  alias Plug.Conn

  def call(%Conn{} = conn, _opts), do: {:ok, conn}
end
