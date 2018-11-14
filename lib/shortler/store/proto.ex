defprotocol Shortler.Store.GetUrl do
  @fallback_to_any true
  def get_url(context, short)
end

defprotocol Shortler.Store.SaveUrl do
  @fallback_to_any true
  def save_url(context, data)
end

defprotocol Shortler.Store.UpdateExpire do
  @fallback_to_any true
  def update(context, short, expire)
end

defprotocol Shortler.Store.Clean do
  @fallback_to_any true
  def clean_expired(context)
end
