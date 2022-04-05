defmodule Ueberauth.Strategy.Amco.OAuth do
  @moduledoc """
  OAuth2 for Amco.
  Add `:client_id` and `:client_secret` to your configuration:
      config :ueberauth, Ueberauth.Strategy.Amco.OAuth,
        client_id: System.get_env("AMCO_APP_ID"),
        client_secret: System.get_env("AMCO_APP_SECRET")
  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://oidc.amco.com",
    token_url: "https://oidc.amco.com/oauth/token",
    authorize_url: "https://oidc.amco.com/openid/authorize"
  ]

  @introspect_path "/oauth/introspect"

  @doc """
  Construct a client for requests to Amco.
  This will be setup automatically for you in `Ueberauth.Strategy.Amco`.
  These options are only useful for usage outside the normal callback phase
  of Ueberauth.
  """
  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, __MODULE__, [])

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    json_library = Ueberauth.json_library()

    opts
    |> OAuth2.Client.new()
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  def authorize_access_token(token, opts \\ []) do
    client = client(opts)

    data = %{
      token: token,
      client_id: client.client_id,
      client_secret: client.client_secret
    }

    OAuth2.Client.post(client, @introspect_path, data, [
      {"Content-Type", "application/json"}
    ])
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth.
  No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client()
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_access_token(params \\ [], opts \\ []) do
    opts
    |> client()
    |> OAuth2.Client.get_token(params)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param("client_secret", client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
