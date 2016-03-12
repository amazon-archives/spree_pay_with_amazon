##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##
Spree::OrdersController.class_eval do
  force_ssl_with_configured_port only: [:show, :edit, :update], if: :use_ssl?
end
