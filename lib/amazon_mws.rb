##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##
class AmazonMwsOrderResponse
  def initialize(response)
    @response = response.fetch("GetOrderReferenceDetailsResponse", {})
  end

  def destination
    @response.fetch("GetOrderReferenceDetailsResult", {}).fetch("OrderReferenceDetails", {}).fetch("Destination", {})
  end

  def constraints
    @response.fetch("GetOrderReferenceDetailsResult", {}).fetch("OrderReferenceDetails", {}).fetch("Constraints", {}).fetch("Constraint", {})
  end

  def state
    @response.fetch("GetOrderReferenceDetailsResult", {}).fetch("OrderReferenceDetails", {}).fetch("OrderReferenceStatus", {}).fetch("State", {})
  end

  def total
    total_block = @response.fetch("GetOrderReferenceDetailsResult", {}).fetch("OrderReferenceDetails", {}).fetch("OrderTotal", {})
    Spree::Money.new(total_block.fetch("Amount", 0), :with_currency => total_block.fetch("CurrencyCode", "USD"))
  end

  def email
    @response.fetch("GetOrderReferenceDetailsResult", {}).fetch("OrderReferenceDetails", {}).fetch("Buyer", {}).fetch("Email", {})
  end
end

class AmazonMws
  require 'httparty'

  def initialize(number, test_mode)
    @number = number
    @test_mode = test_mode
  end


  def fetch_order_data
    AmazonMwsOrderResponse.new(process({
      "Action"=>"GetOrderReferenceDetails",
      "AmazonOrderReferenceId" => @number
    }))
  end

  def set_order_data(total, currency)
    process({
      "Action"=>"SetOrderReferenceDetails",
      "AmazonOrderReferenceId" => @number,
      "OrderReferenceAttributes.OrderTotal.Amount" => total,
      "OrderReferenceAttributes.OrderTotal.CurrencyCode" => currency
    })
  end

  def confirm_order
    process({
      "Action"=>"ConfirmOrderReference",
      "AmazonOrderReferenceId" => @number
    })
  end

  def authorize(ref_number, total, currency)
    process({
      "Action"=>"Authorize",
      "AmazonOrderReferenceId" => @number,
      "AuthorizationReferenceId" => ref_number,
      "AuthorizationAmount.Amount" => total,
      "AuthorizationAmount.CurrencyCode" => currency,
      "CaptureNow" => Spree::Config[:auto_capture],
      "TransactionTimeout" => 0
    })
  end

  def get_authorization_details(ref_number)
    process({
      "Action" => "GetAuthorizationDetails",
      "AmazonAuthorizationId" => ref_number
      })
  end

  def capture(auth_number, ref_number, total, currency)
    process({
      "Action"=>"Capture",
      "AmazonAuthorizationId" => auth_number,
      "CaptureReferenceId" => ref_number,
      "CaptureAmount.Amount" => total,
      "CaptureAmount.CurrencyCode" => currency
    })
  end

  def get_capture_details(ref_number)
    process({
      "Action" => "GetCaptureDetails",
      "AmazonCaptureId" => ref_number
      })
  end

  def refund(capture_id, ref_number, total, currency)
    process({
      "Action"=>"Refund",
      "AmazonCaptureId" => capture_id,
      "RefundReferenceId" => ref_number,
      "RefundAmount.Amount" => total,
      "RefundAmount.CurrencyCode" => currency
    })
  end

  def get_refund_details(ref_number)
    process({
      "Action" => "GetRefundDetails",
      "AmazonRefundId" => ref_number
      })
  end

  def close(ref_number)
    process({
      "Action" => "CloseAuthorization",
      "AmazonAuthorizationId" => ref_number
      })
  end

  private

  def default_hash
    {
      "AWSAccessKeyId"=>Spree::Config[:amazon_aws_access_key_id],
      "SellerId"=>Spree::Config[:amazon_merchant_id],
      "PlatformId"=>"A31NP5KFHXSFV1",
      "SignatureMethod"=>"HmacSHA256",
      "SignatureVersion"=>"2",
      "Timestamp"=>Time.now.utc.iso8601,
      "Version"=>"2013-01-01"
    }
  end

  def process(hash)
    hash = default_hash.reverse_merge(hash)
    sandbox_str = if @test_mode
                    'OffAmazonPayments_Sandbox'
                  else
                    'OffAmazonPayments'
                  end
    query_string = hash.sort.map { |k, v| "#{k}=#{ custom_escape(v) }" }.join("&")
    message = ["POST", "mws.amazonservices.com", "/#{sandbox_str}/2013-01-01", query_string].join("\n")
    query_string += "&Signature=" + custom_escape(Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, Spree::Config[:amazon_aws_secret_access_key], message)).strip)
    HTTParty.post("https://mws.amazonservices.com/#{sandbox_str}/2013-01-01", :body => query_string)
  end

  def custom_escape(val)
    val.to_s.gsub(/([^\w.~-]+)/) do
      "%" + $1.unpack("H2" * $1.bytesize).join("%").upcase
    end
  end
end
