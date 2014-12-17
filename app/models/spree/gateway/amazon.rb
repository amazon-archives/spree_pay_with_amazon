##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##
module Spree
  class Gateway::Amazon < Gateway

    has_one :provider

    def supports?(source)
      true
    end

    def method_type
      "amazon"
    end

    def provider_class
      AmazonTransaction
    end

    def payment_source_class
      AmazonTransaction
    end

    def source_required?
      true
    end

    def authorize(amount, amazon_checkout, gateway_options={})
      if amount < 0
        return ActiveMerchant::Billing::Response.new(true, "Success", {})
      end
      order = Spree::Order.find_by(:number => gateway_options[:order_id].split("-")[0])
      load_amazon_mws(order.amazon_order_reference_id)
      response = @mws.authorize(gateway_options[:order_id], amount / 100.0, Spree::Config.currency)
      if response["ErrorResponse"]
        return ActiveMerchant::Billing::Response.new(false, response["ErrorResponse"]["Error"]["Message"], response)
      end
      t = order.amazon_transaction
      t.authorization_id = response["AuthorizeResponse"]["AuthorizeResult"]["AuthorizationDetails"]["AmazonAuthorizationId"]
      t.save
      return ActiveMerchant::Billing::Response.new(response["AuthorizeResponse"]["AuthorizeResult"]["AuthorizationDetails"]["AuthorizationStatus"]["State"] == "Open", "Success", response)
    end

    def capture(amount, amazon_checkout, gateway_options={})
      if amount < 0
        return credit(amount.abs, nil, nil, gateway_options)
      end
      order = Spree::Order.find_by(:number => gateway_options[:order_id].split("-")[0])
      load_amazon_mws(order.amazon_order_reference_id)

      authorization_id = order.amazon_transaction.authorization_id
      response = @mws.capture(authorization_id, "C#{Time.now.to_i}", amount / 100.00, Spree::Config.currency)
      t = order.amazon_transaction
      t.capture_id = response.fetch("CaptureResponse", {}).fetch("CaptureResult", {}).fetch("CaptureDetails", {}).fetch("AmazonCaptureId", nil)
      t.save!
      return ActiveMerchant::Billing::Response.new(response.fetch("CaptureResponse", {}).fetch("CaptureResult", {}).fetch("CaptureDetails", {}).fetch("CaptureStatus", {})["State"] == "Completed", "OK", response)
    end

    def purchase(amount, amazon_checkout, gateway_options={})
      authorize(amount, amazon_checkout, gateway_options)
      capture(amount, amazon_checkout, gateway_options)
    end

    def credit(amount, _credit_card, gateway_options={})
      order = Spree::Order.find_by(:number => gateway_options[:order_id].split("-")[0])
      load_amazon_mws(order.amazon_order_reference_id)
      capture_id = order.amazon_transaction.capture_id
      response = @mws.refund(capture_id, gateway_options[:order_id], amount / 100.00, Spree::Config.currency)
      return ActiveMerchant::Billing::Response.new(true, "Success", response)
    end

    def void(response_code, gateway_options)
      order = Spree::Order.find_by(:number => gateway_options[:order_id].split("-")[0])
      load_amazon_mws(order.amazon_order_reference_id)
      capture_id = order.amazon_transaction.capture_id
      response = @mws.refund(capture_id, gateway_options[:order_id], order.total, Spree::Config.currency)
      return ActiveMerchant::Billing::Response.new(true, "Success", response)
    end

    def close(amount, amazon_checkout, gateway_options={})
      order = Spree::Order.find_by(:number => gateway_options[:order_id].split("-")[0])
      load_amazon_mws(order.amazon_order_reference_id)

      authorization_id = order.amazon_transaction.authorization_id
      response = @mws.close(authorization_id)
      return ActiveMerchant::Billing::Response.new(true, "Success", response)
    end

    private

    def load_amazon_mws(reference)
      @mws ||= AmazonMws.new(reference, self.preferred_test_mode)
    end
  end
end