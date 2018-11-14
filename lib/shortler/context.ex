defmodule Shortler.Context do
  defstruct []
end

defimpl Shortler.Store.GetUrl, for: Shortler.Context do
  def get_url(_context, short) do
    Shortler.Store.Manager.get_url(short)
  end
end

defimpl Shortler.Store.SaveUrl, for: Shortler.Context do
  def save_url(_context, data) do
    Shortler.Store.Manager.save_url(data)
  end
end

defimpl Shortler.Store.UpdateExpire, for: Shortler.Context do
  def update(_context, short, expire) do
    Shortler.Store.Manager.update_expire(short, expire)
  end
end

defimpl Shortler.Template.Parse, for: Shortler.Context do
  def parse(_context, str, params) do
    Shortler.Template.Parser.parse(str, params)
  end
end

defimpl Shortler.Store.Clean, for: Shortler.Context do
  def clean_expired(_context) do
    Shortler.Store.Manager.clean_expired()
  end
end

defimpl Shortler.Clicks.Writer, for: Shortler.Context do
  def write(_context, data) do
    to_write = %{
      points: [
        %{measurement: "requests", fields: data}
      ]
    }

    Shortler.Clicks.Connection.write(to_write)
  end
end

defimpl Shortler.Store.GetUrl, for: Any do
  def get_url(_context, short) do
    Shortler.Store.GetUrl.get_url(%Shortler.Context{}, short)
  end
end

defimpl Shortler.Store.SaveUrl, for: Any do
  def save_url(_context, data) do
    Shortler.Store.SaveUrl.save_url(%Shortler.Context{}, data)
  end
end

defimpl Shortler.Store.UpdateExpire, for: Any do
  def update(_context, short, expire) do
    Shortler.Store.UpdateExpire.update(%Shortler.Context{}, short, expire)
  end
end

defimpl Shortler.Template.Parse, for: Any do
  def parse(_context, str, params) do
    Shortler.Template.Parse.parse(%Shortler.Context{}, str, params)
  end
end

defimpl Shortler.Store.Clean, for: Any do
  def clean_expired(_context) do
    Shortler.Store.Clean.clean_expired(%Shortler.Context{})
  end
end

defimpl Shortler.Clicks.Writer, for: Any do
  def write(_context, data) do
    Shortler.Clicks.Writer.write(%Shortler.Context{}, data)
  end
end
