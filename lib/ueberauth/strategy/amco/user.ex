defmodule Ueberauth.Strategy.Amco.User do
  @type t :: %__MODULE__{
          sub: binary | nil,
          email: binary | nil,
          given_name: binary | nil,
          family_name: binary | nil,
          phone_number: binary | nil
        }

  defstruct sub: nil,
            email: nil,
            given_name: nil,
            family_name: nil,
            phone_number: nil
end
