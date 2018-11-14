defmodule Shortler.TestSetup do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Shortler.Store.Repo)
  end
end

defmodule Shortler.Test.Context do
  defstruct fun: nil
end

defimpl Shortler.Store.UpdateExpire, for: Shortler.Test.Context do
  def update(%Shortler.Test.Context{fun: nil}, short, expire),
    do: {:ok, short, expire}

  def update(%Shortler.Test.Context{fun: fun}, short, expire),
    do: fun.(short, expire)
end

defimpl Shortler.Template.Parse, for: Shortler.Test.Context do
  def parse(%Shortler.Test.Context{fun: nil}, str, _params),
    do: str

  def parse(%Shortler.Test.Context{fun: fun}, str, params),
    do: fun.(str, params)
end

defimpl Shortler.Store.Clean, for: Shortler.Test.Context do
  def clean_expired(%Shortler.Test.Context{fun: nil}),
    do: :ok

  def clean_expired(%Shortler.Test.Context{fun: fun}),
    do: fun.()
end

defimpl Shortler.Clicks.Writer, for: Shortler.Test.Context do
  def write(%Shortler.Test.Context{fun: nil}, data),
    do: data

  def write(%Shortler.Test.Context{fun: fun}, data),
    do: fun.(data)
end

defimpl Shortler.Cache.Ops, for: Shortler.Test.Context do
  def init(context = %Shortler.Test.Context{fun: nil}), do: context
  def init(%Shortler.Test.Context{fun: fun}), do: fun.()

  def get(%Shortler.Test.Context{fun: nil}, _key), do: nil
  def get(%Shortler.Test.Context{fun: fun}, key), do: fun.(key)

  def put(%Shortler.Test.Context{fun: nil}, _key, _value), do: {:ok, nil}
  def put(%Shortler.Test.Context{fun: fun}, key, value), do: fun.(key, value)

  def remove(%Shortler.Test.Context{fun: nil}, _key), do: {:ok, nil}
  def remove(%Shortler.Test.Context{fun: fun}, key), do: fun.(key)

  def expire(%Shortler.Test.Context{fun: nil}), do: :ok
  def expire(%Shortler.Test.Context{fun: fun}), do: fun.()
end
