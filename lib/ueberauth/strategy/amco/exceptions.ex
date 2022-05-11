defmodule Ueberauth.Strategy.Amco.Exceptions.EmptyErrorHandler do
  defexception message: "Plug option 'error_handler' is required"
end

defmodule Ueberauth.Strategy.Amco.Exceptions.EmptyAccessTokenSource do
  defexception message: "Plug option 'access_token_source' is required"
end

defmodule Ueberauth.Strategy.Amco.Exceptions.MissingSiteConfiguration do
  defexception message: "Configuration option 'site' is missing"
end
