defprotocol Shortler.Clicks.Writer do
  @fallback_to_any true
  def write(context, data)
end
