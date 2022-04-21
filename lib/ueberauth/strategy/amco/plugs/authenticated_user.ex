defmodule Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser do
  alias Plug.Conn
  alias Ueberauth.Strategy.Amco.API
  alias Ueberauth.Strategy.Amco.Exceptions

  @moduledoc """
  This plug is in charge to verify and validate the access token
  provided in the request against the OpenID Connect Provider.
  It will try to get the access token from headers for json requests,
  otherwise from cookies.

  If the access token is valid, the current user will be assigned to the
  connection and the request will continue as normal. In the other hand,
  it will call the access_token_error function in the response handler.
  """

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
    handler = Keyword.get(opts, :error_handler)
    source = Keyword.get(opts, :access_token_source)

    with {:ok, token} <- get_access_token(conn, source),
         {:ok, _response} <- validate_access_token(token) do
      conn

    else
      {:error, error} ->
        handler.access_token_error(conn, %{error: error})
    end
  end

  defp get_access_token(%Conn{} = conn, :headers) do
    case Conn.get_req_header(conn, "authorization") do
      ["Bearer " <> access_token] -> {:ok, access_token}
      _ -> {:error, :access_token_required}
    end
  end

  defp get_access_token(%Conn{} = conn, :session) do
    case Conn.get_session(conn, :access_token) do
      nil -> {:error, :access_token_required}
      token -> {:ok, token}
    end
  end

  defp validate_access_token(access_token) do
    case API.authorize_access_token(access_token) do
      {:ok, response} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end
end
