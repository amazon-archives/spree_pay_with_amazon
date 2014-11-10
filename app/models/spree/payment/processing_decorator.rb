Spree::Payment::Processing.class_eval do
  def close!
    gateway_action(source, :close, :close)
  end
end