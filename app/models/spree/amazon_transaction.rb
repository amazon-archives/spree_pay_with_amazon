module Spree
  class AmazonTransaction < ActiveRecord::Base
    has_many :payments, :as => :source

    def name
      "Pay with Amazon"
    end

    def cc_type
      "n/a"
    end

    def display_number
      "n/a"
    end

    def month
      "n"
    end

    def year
      "a"
    end

    def reusable_sources(_order)
      []
    end

    def self.with_payment_profile
      []
    end

    def can_capture?(payment)
      (payment.pending? || payment.checkout?) && payment.amount > 0
    end

    def can_credit?(payment)
      (payment.pending? || payment.checkout?) && payment.amount < 0
    end

    def can_void?(payment)
      false
    end

    def can_close?(payment)
      !payment.closed?
    end

    def actions
      %w{capture credit close}
    end

  end
end