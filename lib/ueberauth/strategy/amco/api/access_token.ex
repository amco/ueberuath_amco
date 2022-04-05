defmodule Ueberauth.Strategy.Amco.API.AccessToken do
  alias OAuth2.Response
  alias Ueberauth.Strategy.Amco.OAuth

  def authorize(token) do
    OAuth.authorize_access_token(token)
    |> process_response()
  end

  defp process_response({:ok, %Response{status_code: 200} = response}) do
    case response.body do
      %{"active" => true} -> {:ok, response.body}
      %{"active" => false} -> {:error, :access_token_expired}
    end
  end

  defp process_response(_), do: {:error, :access_token_invalid}
end
