Spree::Order.class_eval do
  has_many :amazon_transactions

  def amazon_transaction
    amazon_transactions.last
  end

  def amazon_order_reference_id
    amazon_transaction.order_reference
  end
end