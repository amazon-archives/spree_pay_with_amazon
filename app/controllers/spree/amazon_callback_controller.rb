class Spree::AmazonCallbackController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def new
    response = JSON.parse(request.body.read)
    if JSON.parse(response["Message"])["NotificationType"] == "PaymentRefund"
      refund_id = Hash.from_xml(JSON.parse(response["Message"])[ "NotificationData"])["RefundNotification"]["RefundDetails"]["AmazonRefundId"]
      payment = Spree::LogEntry.where('details LIKE ?', "%#{refund_id}%").source
      l = payment.log_entries.build(details: response.to_yaml)
      l.save
    else
      render nothing: true
    end
  end
end
