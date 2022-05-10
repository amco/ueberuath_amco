defmodule Ueberauth.Strategy.Amco do
  @moduledoc """
  Provides an Ueberauth strategy for authenticating with Amco.

  ### Setup

  Request to Amco IT an application in Amco for you to use.

  Include the provider in your configuration for Ueberauth;

      config :ueberauth, Ueberauth,
        providers: [
          amco: { Ueberauth.Strategy.Amco, [] }
        ]

  Then include the configuration for Amco:

      config :ueberauth, Ueberauth.Strategy.Amco.OAuth,
        client_id: System.get_env("AMCO_CLIENT_ID"),
        client_secret: System.get_env("AMCO_CLIENT_SECRET")

  If you haven't already, setup routes for your request and callback handler

      scope "/auth" do
        pipe_through [:browser, :auth]

        get "/:provider", AuthController, :request
        get "/:provider/callback", AuthController, :callback
      end

  Create an endpoint for the request and callback where you will handle the
  `Ueberauth.Auth` struct:

      defmodule MyApp.AuthController do
        use MyApp.Web, :controller

        plug Ueberauth

        def callback_phase(%{ assigns: %{ ueberauth_failure: fails } } = conn, _params) do
          # do things with the failure
        end

        def callback_phase(%{ assigns: %{ ueberauth_auth: auth } } = conn, params) do
          # do things with the auth
        end
      end

  You can edit the behaviour of the Strategy by including some options when you
  register your provider.

  To set the `prompt`:

      config :ueberauth, Ueberauth,
        providers: [
          amco: { Ueberauth.Strategy.Amco, [prompt: "login"] }
        ]

  To set the default 'scopes' (permissions):

      config :ueberauth, Ueberauth,
        providers: [
          amco: { Ueberauth.Strategy.Amco, [default_scope: "openid email phone"] }
        ]

  Default is empty ("openid profile email").
  """

  use Ueberauth.Strategy,
    default_strategy: "default",
    default_scope: "openid profile email",
    uid_field: "sub"

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Strategy.Amco
  alias Ueberauth.Auth.Credentials

  @doc """
  Handles the initial redirect to the amco authentication page.

  To customize the scope (permissions) that are requested by amco include
  them as part of your url:

      "/auth/amco?scope=openid,profile,email,phone"

  """
  def handle_request!(conn) do
    opts = oauth_client_options_from_conn(conn)

    params =
      []
      |> with_scopes(conn)
      |> with_state_param(conn)
      |> with_prompt_param(conn)
      |> with_redirect_uri(conn)
      |> with_strategy_param(conn)

    redirect!(conn, Amco.OAuth.authorize_url!(params, opts))
  end

  @doc """
  Handles the callback from Amco.

  When there is a failure from Amco the failure is included in the
  `ueberauth_failure` struct. Otherwise the information returned from Amco is
  returned in the `Ueberauth.Auth` struct.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    opts = oauth_client_options_from_conn(conn)

    params =
      [code: code]
      |> with_redirect_uri(conn)
      |> with_code_verifier_param(conn)

    case Amco.OAuth.get_access_token(params, opts) do
      {:error, %{body: %{"error" => error, "error_description" => description}}} ->
        set_errors!(conn, [error(error, description)])

      {:ok, %{token: %{access_token: nil} = token}} ->
        %{"error" => error, "error_description" => description} = token.other_params
        set_errors!(conn, [error(error, description)])

      {:ok, %{token: token}} ->
        fetch_user(conn, token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc """
  Cleans up the private area of the connection used for passing the raw Amco
  response around during the callback.
  """
  def handle_cleanup!(conn) do
    conn
    |> put_private(:amco_user, nil)
    |> put_private(:amco_token, nil)
  end

  @doc """
  Fetches the `:uid` field from the Amco response.

  This defaults to the option `:uid_field` which in-turn defaults to `:id`
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string()

    conn.private.amco_user[uid_field]
  end

  @doc """
  Includes the credentials from the Amco response.
  """
  def credentials(conn) do
    token = conn.private.amco_token

    %Credentials{
      token: token.access_token,
      other: token.other_params,
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      token_type: token.token_type,
      refresh_token: token.refresh_token,
      scopes: token.other_params["scope"]
    }
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth`
  struct.
  """
  def info(conn) do
    user = conn.private.amco_user

    %Info{
      email: user["email"],
      phone: user["phone_number"],
      last_name: user["family_name"],
      first_name: user["given_name"]
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from the Amco
  callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.amco_token,
        user: conn.private.amco_user
      }
    }
  end

  defp fetch_user(conn, token) do
    conn = put_private(conn, :amco_token, token)
    put_private(conn, :amco_user, %{})
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, default_option(key))
  end

  defp default_option(key) do
    Keyword.get(default_options(), key)
  end

  defp with_redirect_uri(opts, conn) do
    Keyword.put(opts, :redirect_uri, callback_url(conn))
  end

  defp with_scopes(opts, conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)
    opts |> Keyword.put(:scope, scopes)
  end

  defp with_strategy_param(opts, conn) do
    strategy = conn.params["strategy"] || option(conn, :default_strategy)
    opts |> Keyword.put(:strategy, strategy)
  end

  defp with_prompt_param(opts, conn) do
    case conn.params["prompt"] || option(conn, :default_prompt) do
      nil -> opts
      prompt -> opts |> Keyword.put(:prompt, prompt)
    end
  end

  defp with_code_verifier_param(opts, conn) do
    case conn.params["code_verifier"] do
      nil -> opts
      code_verifier -> opts |> Keyword.put(:code_verifier, code_verifier)
    end
  end

  defp oauth_client_options_from_conn(conn) do
    base_options = [redirect_uri: callback_url(conn)]
    request_options = conn.private[:ueberauth_request_options].options

    case {request_options[:client_id], request_options[:client_secret]} do
      {nil, _} -> base_options
      {_, nil} -> base_options
      {id, secret} -> [client_id: id, client_secret: secret] ++ base_options
    end
  end
end
