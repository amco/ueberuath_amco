defmodule Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser.MockAdapter do
  @moduledoc """
  """

  alias Plug.Conn

  def call(%Conn{} = conn, _opts), do: {:ok, conn}
end
