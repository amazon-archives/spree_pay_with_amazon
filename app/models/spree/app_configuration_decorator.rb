Spree::AppConfiguration.class_eval do
  preference :amazon_checkout_display_mode, :string, :default => 'modified_checkout'
  preference :amazon_client_id, :string
  preference :amazon_merchant_id, :string
  preference :amazon_aws_access_key_id, :string
  preference :amazon_aws_secret_access_key, :string
end