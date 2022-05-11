defmodule Ueberauth.Strategy.Amco.Exceptions.EmptyErrorHandler do
  defexception message: "error_handler option is required"
end

defmodule Ueberauth.Strategy.Amco.Exceptions.EmptyAccessTokenSource do
  defexception message: "access_token_source option is required"
end

defmodule Ueberauth.Strategy.Amco.Exceptions.MissingSiteConfiguration do
  defexception message: "site configuration option is missed"
end
