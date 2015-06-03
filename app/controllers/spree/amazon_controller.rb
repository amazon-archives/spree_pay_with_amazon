##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##
class Spree::AmazonController < Spree::StoreController

  helper 'spree/orders'
  before_filter :check_for_current_order
  before_filter :load_amazon_mws, except: [:address, :payment, :complete]

  respond_to :json

  def address
    current_order.state = 'cart'
    current_order.save!
  end

  def payment
    payment = current_order.payments.valid.first{|p| p.source_type == "Spree::AmazonTransaction"} || current_order.payments.create
    payment.number = params[:order_reference]
    payment.payment_method = Spree::PaymentMethod.find_by(:type => "Spree::Gateway::Amazon")
    payment.source ||= Spree::AmazonTransaction.create(:order_reference => params[:order_reference], :order_id => current_order.id)

    payment.save!

    render json: {}.to_json
  end

  def delivery
    data = @mws.fetch_order_data
    current_order.state = 'cart'

    if data.destination && data.destination["PhysicalDestination"]
      current_order.email = "pending@amazon.com"
      address = data.destination["PhysicalDestination"]
      spree_address = Spree::Address.new(
                              "firstname" => "Amazon",
                              "lastname" => "User",
                              "address1" => "TBD",
                              "phone" => "TBD",
                              "city" => address["City"],
                              "zipcode" => address["PostalCode"],
                              "state_name" => address["StateOrRegion"],
                              "country" => Spree::Country.where("iso = ? OR iso_name = ?", address["CountryCode"],address["CountryCode"]).first)
      spree_address.save!
      current_order.ship_address_id = spree_address.id
      current_order.bill_address_id = spree_address.id
      current_order.save!
      current_order.next! # to Address
      current_order.next! # to Delivery

      current_order.reload
    else
      redirect_to address_amazon_order_path, :notice => "Unable to load Address data from Amazon"
    end
    render :layout => false
  end

  def confirm

    if current_order.update_from_params(params, permitted_checkout_attributes, request.headers.env)

      @mws.set_order_data(current_order.total, current_order.currency)

      result = @mws.confirm_order

      data = @mws.fetch_order_data

      if data.destination && data.destination["PhysicalDestination"]
        current_order.email = data.email
        current_order.save!
        address = data.destination["PhysicalDestination"]
        first_name = address["Name"].split(" ")[0] rescue "Amazon"
        last_name = address["Name"].split(" ")[1..10].join(" ")
        spree_address = current_order.ship_address
        spree_address.update({
                                "firstname" => first_name,
                                "lastname" => last_name,
                                "address1" => address["AddressLine1"],
                                "phone" => address["Phone"] || "n/a",
                                "city" => address["City"],
                                "zipcode" => address["PostalCode"],
                                "state_name" => address["StateOrRegion"],
                                "country" => Spree::Country.find_by_iso(address["CountryCode"])})
        spree_address.save!
      else
        raise "There is a problem with your order"
      end
      current_order.create_tax_charge!
      current_order.reload
      payment = current_order.payments.valid.first{|p| p.source_type == "Spree::AmazonTransaction"}
      payment.amount = current_order.total
      payment.save!
      @order = current_order

      # Remove the following line to enable the confirmation step.
      redirect_to amazon_order_complete_path(@order)
    else
      render :edit
    end

  end

  def complete
    @order = Spree::Order.find_by(:number => params[:amazon_order_id])
    authorize!(:edit, @order, cookies.signed[:guest_token])

    redirect_to root_path if @order.nil?
    while(@order.next) do

    end

    if @order.completed?
      @current_order = nil
      flash.notice = Spree.t(:order_processed_successfully)
    end

    if @order.complete?
      redirect_to spree.order_path(@order)
    else
      @order.state = 'cart'
      @order.amazon_transactions.destroy_all
      redirect_to cart_path, :notice => "Unable to process order"
      return true
    end
  end

  def load_amazon_mws
    render :nothing => true, :status => 200 if current_order.amazon_order_reference_id.nil?
    @mws ||= AmazonMws.new(current_order.amazon_order_reference_id, Spree::Gateway::Amazon.first.preferred_test_mode)
  end

  private


  def check_for_current_order
    redirect_to root_path, :notice => "No Order Found" if current_order.nil?
    return true
  end
end
