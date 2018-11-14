defprotocol Shortler.Cache.Ops do
  @fallback_to_any true
  def init(context)

  @fallback_to_any true
  def get(context, key)

  @fallback_to_any true
  def put(context, key, val)

  @fallback_to_any true
  def remove(context, key)

  @fallback_to_any true
  def expire(context)
end
