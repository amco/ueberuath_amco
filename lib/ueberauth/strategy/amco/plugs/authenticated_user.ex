defmodule Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser do
  import Plug.Conn

  alias Plug.Conn
  alias Ueberauth.Strategy.Amco.API

  @moduledoc """
  This plug is in charge to verify and validate the access token
  provided in the request against the OpenID Connect Provider.
  It will try to get the access token from headers for json requests,
  otherwise from cookies.

  If the access token is valid, the current user will be assigned to the
  connection and the request will continue as normal. In the other hand,
  it will halt the request with an unauthorized code for json requests,
  otherwise it will render the 401.html error view.
  """

  def init(opts), do: opts

  def call(%Conn{} = conn, opts) do
    format = Keyword.get(opts, :format, :html)
    handler = Keyword.get(opts, :response_handler)

    with {:ok, access_token} <- get_access_token(conn, format),
         {:ok, response} <- validate_access_token(access_token) do
      handler.access_token_success(conn, response)
      conn
    else
      {:error, error} ->
        response = %{error: error, format: format}
        handler.access_token_error(conn, response)
    end
  end

  defp get_access_token(%Conn{} = conn, :json) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> access_token] -> {:ok, access_token}
      _ -> {:error, :access_token_required}
    end
  end

  defp get_access_token(%Conn{} = conn, :html) do
    case get_session(conn, :current_user) do
      nil -> {:error, :access_token_required}
      user -> {:ok, user.credentials.token}
    end
  end

  defp validate_access_token(access_token) do
    case API.authorize_access_token(access_token) do
      {:ok, response} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end
end
