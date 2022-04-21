# Überauth Amco

> Amco OpenID Connect strategy for Überauth.

## Installation

1.  Setup your application at Amco OIDC Provider.

2.  Add `:ueberauth_amco` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:ueberauth_amco, "~> 0.1"}
      ]
    end
    ```

3.  Add Amco to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        amco: {Ueberauth.Strategy.Amco, []}
      ]
    ```

4.  Update your provider configuration:

    Use that if you want to read client ID/secret from the environment
    variables in the compile time:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Amco.OAuth,
      client_id: System.get_env("AMCO_CLIENT_ID"),
      client_secret: System.get_env("AMCO_CLIENT_SECRET")
    ```

    Use that if you want to read client ID/secret from the environment
    variables in the run time:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Amco.OAuth,
      client_id: {System, :get_env, ["AMCO_CLIENT_ID"]},
      client_secret: {System, :get_env, ["AMCO_CLIENT_SECRET"]}
    ```

5.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyAppWeb.AuthController do
      use MyAppWeb, :controller

      plug Ueberauth
      ...
    end
    ```

6.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyAppWeb do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback

      # If your app is a JSON API, you'll want to exchange the
      # authorization code using a POST request.
      post "/:provider/callback", AuthController, :callback
    end
    ```

7.  Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Callbacks

### Web-based applications

For web-based applications you should add the auth response to the
session and redirect the user to the path you want. Your callbacks in
the auth controller should look like this:

```elixir
defmodule MyAppWeb.AuthController do
  use MyAppWeb, :controller

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    conn
    |> put_flash(:info, "Successfully authenticated.")
    |> put_session(:access_token, auth.credentials.token)
    |> put_session(:refresh_token, auth.credentials.refresh_token)
    |> configure_session(renew: true)
    |> redirect(to: "/")
  end
end
```

### JSON API applications

For JSON API applications you should return the access token, refresh
token and id token to the native application that is consuming the API.
Your callbacks in the auth controller should look like this:

```elixir
defmodule MyAppWeb.AuthController do
  use MyAppWeb, :controller

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      message: fails.message,
      message_key: fails.message_key
    })
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    conn
    |> json(%{
      access_token: auth.credentials.token,
      id_token: auth.credentials.other["id_token"],
      refresh_token: auth.credentials.refresh_token
    })
  end
end
```

## Protected Routes

### Web-based applications

Use the plug `Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser` in
your protected routes. This will get the access token from session
and validate it against the IDP (OIDC Identity Provider).

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :protected do
    plug Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser,
      error_handler: MyAppWeb.AuthenticationErrorHandler,
      access_token_source: :session
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :protected]

    # Add your protected routes here
  end
end
```

And define your callbacks module in your application. It may look
something like the following in a phoenix application:

```elixir
defmodule MyAppWeb.AuthenticationErrorHandler do
  @behaviour Ueberauth.Strategy.Amco.ErrorHandler

  import Phoenix.Controller

  @impl Ueberauth.Strategy.Amco.ErrorHandler
  def access_token_error(conn, %{error: error}) do
    conn
    |> put_flash(:error, gettext(error))
    |> redirect(to: "/login")
  end
end
```

### JSON API applications

If your app requires json response you'll need to add `access_token_source: :headers`
to the plug options. It will get the access token from the request
header `Authorization: Bearer <access_token>`.

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :protected do
    plug Ueberauth.Strategy.Amco.Plugs.AuthenticatedUser,
      error_handler: MyAppWeb.AuthenticationErrorHandler,
      access_token_source: :headers
  end
end
```

And then update your `ErrorHandler` to response with a json. It may
look something like this:

```elixir
defmodule MyAppWeb.AuthenticationErrorHandler do
  @behaviour Ueberauth.Strategy.Amco.ErrorHandler

  import Plug.Conn
  import Phoenix.Controller

  @impl Ueberauth.Strategy.Amco.ErrorHandler
  def access_token_error(conn, error) do
    conn
    |> put_status(:unauthorized)
    |> json(error)
    |> halt()
  end
end
```

## Calling

Depending on the configured url you can initiate the request through:

    /auth/amco

Or with options:

    /auth/amco?scope=email%20profile&strategy=phone_number

By default the requested scope is `openid profile email`. Scope can be configured
either explicitly as a `scope` query value on the request path or in your
configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    amco: {Ueberauth.Strategy.Amco, [default_scope: "openid email phone"]}
  ]
```

By default the strategy to be used is `default`. Strategy can be configured
either explicitly as a `strategy` query value on the request path or in your
configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    amco: {Ueberauth.Strategy.Amco, [default_strategy: "phone_number"]}
  ]
```

By default prompt is not present in the authorization url. Prompt can be
configured either explicitly as a `prompt` query value on the request
path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    amco: {Ueberauth.Strategy.Amco, [default_prompt: "login"]}
  ]
```

To guard against client-side request modification, it's important to still
check the domain in `info.urls[:website]` within the `Ueberauth.Auth` struct
if you want to limit sign-in to a specific domain.

## Copyright and License

Copyright (c) 2022 Amco

Released under the MIT License, which can be found in the repository in
[LICENSE](https://github.com/amco/ueberauth_amco/blob/master/LICENSE).
