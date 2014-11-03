class Spree::AmazonController < Spree::StoreController
  ssl_required
  helper 'spree/orders'
  before_filter :load_amazon_mws, except: [:address, :payment]

  respond_to :json

  def address

  end

  def payment
    payment = current_order.payments.first{|p| p.state == "checkout" && p.identifier == params[:order_reference]} || current_order.payments.create
    payment.identifier = params[:order_reference]
    payment.payment_method_id = Spree::PaymentMethod.find_by(:type => "Spree::Gateway::Amazon").id
    payment.save!

    render json: {}.to_json
  end

  def delivery
    data = @mws.fetch_order_data
    if data.destination && data.destination["PhysicalDestination"]
      current_order.email = "pending@amazon.com"
      address = data.destination["PhysicalDestination"]
      first_name = address["Name"].split(" ")[0] rescue ""
      last_name = address["Name"].split(" ")[-1] rescue ""
      spree_address = Spree::Address.new(
                              "firstname" => "Amazon",
                              "lastname" => "User",
                              "address1" => "TBD",
                              "phone" => "TBD",
                              "city" => address["City"],
                              "zipcode" => address["PostalCode"],
                              "state_name" => address["StateOrRegion"],
                              "country" => Spree::Country.find_by_iso(address["CountryCode"]))
      spree_address.save!
      current_order.ship_address_id = spree_address.id
      current_order.bill_address_id = spree_address.id
      current_order.save!
      current_order.create_proposed_shipments
      packages = current_order.shipments.map { |s| s.to_package }
      @differentiator = Spree::Stock::Differentiator.new(current_order, packages)
      current_order.shipments.map { |s| s.refresh_rates }
      current_order.shipments.reload
      current_order.reload
    else
      redirect_to address_amazon_order_path, :notice => "Unable to load Address data from Amazon"
    end

  end

  def confirm

    if current_order.update_from_params(params, permitted_checkout_attributes, request.headers.env)

      @mws.set_order_data(current_order.total, current_order.currency)

      @mws.confirm_order
      payment = current_order.payments.with_state('checkout').first{|p| p.identifier == params[:order_reference]}
      payment.amount = current_order.total
      payment.save

      data = @mws.fetch_order_data

      if data.destination && data.destination["PhysicalDestination"]
        current_order.email = data.email
        current_order.save!
        address = data.destination["PhysicalDestination"]
        first_name = address["Name"].split(" ")[0] rescue "Amazon"
        last_name = address["Name"].split(" ")[-1] rescue "User"
        spree_address = current_order.ship_address
        spree_address.update({
                                "firstname" => first_name,
                                "lastname" => last_name,
                                "address1" => address["AddressLine1"],
                                "phone" => address["Phone"],
                                "city" => address["City"],
                                "zipcode" => address["PostalCode"],
                                "state_name" => address["StateOrRegion"],
                                "country" => Spree::Country.find_by_iso(address["CountryCode"])})
        spree_address.save!
      end
      current_order.reload
      @order = current_order
    else
      render :edit
    end

  end

  def complete
    @order = current_order
    while(current_order.next) do

    end

    if current_order.completed?
      @current_order = nil
      flash.notice = Spree.t(:order_processed_successfully)
    end
  end

  def load_amazon_mws
    raise NoOrderFound if current_order.payments.last.try(:identifier).nil?
    @mws ||= AmazonMws.new(current_order.payments.last.try(:identifier))
  end

  private

  def set_address(data, spree_address)

  end
end