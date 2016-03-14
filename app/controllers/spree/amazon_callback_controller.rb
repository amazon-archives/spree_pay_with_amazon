##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##
class Spree::AmazonCallbackController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def new
    response = JSON.parse(request.body.read)
    if JSON.parse(response["Message"])["NotificationType"] == "PaymentRefund"
      refund_id = Hash.from_xml(JSON.parse(response["Message"])[ "NotificationData"])["RefundNotification"]["RefundDetails"]["AmazonRefundId"]
      payment = Spree::LogEntry.where('details LIKE ?', "%#{refund_id}%").last.try(:source)
      if payment
        l = payment.log_entries.build(details: response.to_yaml)
        l.save
      end
    end
    render nothing: true
  end
end
