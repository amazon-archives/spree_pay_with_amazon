##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##
class Spree::Admin::AmazonController < Spree::Admin::BaseController
  respond_to :html

  def edit
    @amazon_callback_url = "#{root_url}amazon_callback"
  end

  def update
    Spree::Config[:amazon_client_id]=params[:amazon_client_id]
    Spree::Config[:amazon_merchant_id] = params[:amazon_merchant_id]
    Spree::Config[:amazon_aws_access_key_id] = params[:amazon_aws_access_key_id]
    Spree::Config[:amazon_aws_secret_access_key] = params[:amazon_aws_secret_access_key]
    flash[:success] = Spree.t(:successfully_updated, :resource => Spree.t(:amazon_settings))
    redirect_to edit_admin_amazon_path
  end
end