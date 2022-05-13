defmodule Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser do
  @moduledoc """
  This plug uses different adapters to validate the access token
  provider in the request. IdpAdapter will do that against the
  Identity Provider server. In test env you may want to use the
  MockAdapter to avoid making request to the IdP server while the
  tests are running.
  """

  alias Plug.Conn
  alias Ueberauth.Strategy.Amco.User
  alias Ueberauth.Strategy.Amco.Exceptions
  alias Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser
  alias Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser.IdpAdapter

  def init(opts) do
    unless Keyword.get(opts, :error_handler) do
      raise Exceptions.EmptyErrorHandler
    end

    unless Keyword.get(opts, :access_token_source) do
      raise Exceptions.EmptyAccessTokenSource
    end

    opts
  end

  def call(%Conn{} = conn, opts) do
    case adapter().call(conn, opts) do
      {:ok, %User{} = user} ->
        Conn.assign(conn, :current_user, user)

      {:ok, %Conn{} = conn} ->
        conn

      {:error, error} ->
        handler = Keyword.get(opts, :error_handler)
        handler.access_token_error(conn, error)
    end
  end

  defp adapter() do
    Application.get_env(:ueberauth, AuthenticatedUser, [])
    |> Keyword.get(:adapter, IdpAdapter)
  end
end
