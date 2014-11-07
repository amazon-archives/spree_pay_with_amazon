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

    def source_required?
      true
    end

    def authorize(amount, amazon_checkout, gateway_options={})
      if gateway_options[:order_id].split("-")[1,3].length < 10
        return ActiveMerchant::Billing::Response.new(true, "Success - No New Auth Needed", {})
      end
      load_amazon_mws(gateway_options[:order_id].split("-")[1,3].join("-"))
      response = @mws.authorize(gateway_options[:order_id], amount / 100.0, Spree::Config.currency)
      puts response.inspect
      return ActiveMerchant::Billing::Response.new(response["AuthorizeResponse"]["AuthorizeResult"]["AuthorizationDetails"]["AuthorizationStatus"]["State"] == "Open", "Success", response)
    end

    def capture(amount, amazon_checkout, gateway_options={})
      load_amazon_mws(gateway_options[:order_id].split("-")[1,3].join("-"))
      order = Spree::Order.find_by(:number => gateway_options[:order_id].split("-")[0])
      authorization_id = order.payments.first{|p| p.source_type == "Spree::AmazonTransaction" && p.state == "completed"}.log_entries.first{|l| l.parsed_details.params.fetch("AuthorizeResponse",{}).fetch("AuthorizeResult", {}).fetch("AuthorizationDetails", {}).fetch("AmazonAuthorizationId")}.parsed_details.params["AuthorizeResponse"]["AuthorizeResult"]["AuthorizationDetails"]["AmazonAuthorizationId"]
      response = @mws.capture(authorization_id, "C#{Time.now.to_i}", amount / 100.00, Spree::Config.currency)
      puts response.inspect
      return ActiveMerchant::Billing::Response.new(response["CaptureResponse"]["CaptureResult"]["CaptureDetails"]["CaptureStatus"]["State"] == "Completed", "Success", response)
    end

    def purchase(amount, amazon_checkout, gateway_options={})
      load_amazon_mws(gateway_options[:order_id].split("-")[1,3].join("-"))
      authorize(amount, amazon_checkout, gateway_options={})
      capture(amount, amazon_checkout, gateway_options={})
    end

    def credit(amount, _credit_card, response_code, gateway_options)
      load_amazon_mws(gateway_options[:order_id].split("-")[1,3].join("-"))
      order = Spree::Order.find_by(:number => gateway_options[:order_id].split("-")[0])
      capture_id = order.payments.last.log_entries.last.parsed_details.params["CaptureResponse"]["CaptureResult"]["CaptureDetails"]["AmazonCaptureId"]
      response = @mws.refund(capture_id, gateway_options[:order_id], amount / 100.00, Spree::Config.currency)
      return ActiveMerchant::Billing::Response.new(true, "Success", response)
    end

    def void(response_code, gateway_options)
      load_amazon_mws(gateway_options[:order_id].split("-")[1,3].join("-"))
      order = Spree::Order.find_by(:number => gateway_options[:order_id].split("-")[0])
      capture_id = order.payments.last.log_entries.last.parsed_details.params["CaptureResponse"]["CaptureResult"]["CaptureDetails"]["AmazonCaptureId"]
      response = @mws.refund(capture_id, gateway_options[:order_id], order.total, Spree::Config.currency)
      return ActiveMerchant::Billing::Response.new(true, "Success", response)
    end

    private

    def load_amazon_mws(reference)
      @mws ||= AmazonMws.new(reference)
    end
  end
end