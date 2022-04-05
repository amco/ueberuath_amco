defmodule Ueberauth.Strategy.Amco.API do
  alias Ueberauth.Strategy.Amco.API.AccessToken

  @doc """
  Authorizes the user using the access token provided in the request.
  It calls the OpenID Connect Provider and verifies that the access_token
  is valid and has not expired.

  ## Examples

      iex> authorize_access_token("bGWcAKadGrBwM...")
      {:ok, response}

      iex> authorize_access_token("InvalidAccessToken")
      {:error, :invalid}

  """
  def authorize_access_token(token) do
    AccessToken.authorize(token)
  end
end
