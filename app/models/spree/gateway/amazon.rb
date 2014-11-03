module Spree
  class Gateway::Amazon < Gateway

    def supports?(source)
      true
    end

    def provider_class
      self.class
    end

    def authorize(amount, amazon_checkout, gateway_options={})
      true
      #load_amazon_mws(amazon_checkout)
      #@mws.authorize(payment.id, amount, Spree::Config.currency)
    end

    def capture(amount, amazon_checkout, gateway_options={})
      true
      #load_amazon_mws(amazon_checkout)
      #@mws.capture(gateway_options[:authorization_id], "C#{payment.id}", amount, Spree::Config.currency)
    end

    def purchase(amount, amazon_checkout, gateway_options={})
      true
      #load_amazon_mws(amazon_checkout)
      #authorize(amount, amazon_checkout, gateway_options={})
      #capture(amount, amazon_checkout, gateway_options={})
    end

    def credit(amount, amazon_checkout, gateway_options={})
      load_amazon_mws(amazon_checkout)
      @mws.refund(gateway_options[:capture_id], "R#{payment.id}", amount, Spree::Config.currency)
    end

    def source_required?
      false
    end

    private

    def load_amazon_mws(reference)
      @mws ||= AmazonMws.new(options[:order_reference])
    end
  end
end