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
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

6.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

7.  Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initiate the request through:

    /auth/amco

Or with options:

    /auth/amco?scope=email%20profile

By default the requested scope is "openid email". Scope can be configured
either explicitly as a `scope` query value on the request path or in your
configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    amco: {Ueberauth.Strategy.Amco, [default_scope: "openid email phone"]}
  ]
```

You can also pass options such as the `strategy` parameter to suggest a
particular Authentication flow or `prompt` to specify whether the OIDC Provider
prompts the End-User for reauthentication (`prompt: "login"`) or create an
account (`prompt: "create"`).

```elixir
config :ueberauth, Ueberauth,
  providers: [
    amco: {Ueberauth.Strategy.Amco, [strategy: "phone_number", prompt: "create"]}
  ]
```

To guard against client-side request modification, it's important to still
check the domain in `info.urls[:website]` within the `Ueberauth.Auth` struct
if you want to limit sign-in to a specific domain.

## Copyright and License

Copyright (c) 2022 Amco

Released under the MIT License, which can be found in the repository in
[LICENSE](https://github.com/amco/ueberauth_amco/blob/master/LICENSE).
