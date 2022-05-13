defmodule Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser do
  @moduledoc """
  This plug is in charge to verify and validate the access token
  provided in the request against the OpenID Connect Provider.
  It will try to get the access token from headers for json requests,
  otherwise from cookies.

  If the access token is valid, the current user will be assigned to the
  connection and the request will continue as normal. In the other hand,
  it will call the access_token_error function in the response handler.
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
