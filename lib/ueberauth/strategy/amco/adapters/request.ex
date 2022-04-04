defmodule Gamora.Adapters.Request do
  defdelegate post(url, data, headers), to: HTTPoison
end
