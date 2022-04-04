defmodule Ueberauth.Strategy.Amco.ResponseHandler do
  @type conn :: Plug.Conn
  @type response :: Map.t()

  @doc """
  This callbacks is called when the access token was successfully
  validated by the OpenID Connect Provider.
  """
  @callback access_token_success(conn, response) :: any()

  @doc """
  This callbacks is called when the access token couldn't be validated
  or the OpenID Connect Provider returned that it was invalid or expired.
  """
  @callback access_token_error(conn, response) :: any()

  @optional_callbacks access_token_success: 2
end
