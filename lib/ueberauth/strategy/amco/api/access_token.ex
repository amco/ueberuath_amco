defmodule Ueberauth.Strategy.Amco.API.AccessToken do
  alias OAuth2.Response
  alias Ueberauth.Strategy.Amco.OAuth

  def authorize(token) do
    OAuth.authorize_access_token(token)
    |> process_response()
  end

  defp process_response({:ok, %Response{status_code: 200} = response}) do
    case response.body do
      %{"active" => true} = data -> {:ok, data}
      %{"active" => false} -> {:error, :expired}
    end
  end

  defp process_response(_), do: {:error, :invalid}
end
