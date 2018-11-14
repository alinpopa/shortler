defprotocol Shortler.Template.Parse do
  @fallback_to_any true
  def parse(context, str, params)
end
