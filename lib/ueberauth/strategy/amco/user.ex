defmodule Ueberauth.Strategy.Amco.User do
  @type t :: %__MODULE__{
          id: binary | nil,
          email: binary | nil,
          last_name: binary | nil,
          first_name: binary | nil,
          phone_number: binary | nil
        }

  defstruct id: nil,
            email: nil,
            last_name: nil,
            first_name: nil,
            phone_number: nil
end
