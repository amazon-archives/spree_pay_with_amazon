Spree::OrdersController.class_eval do
  ssl_required :show, :edit, :update
end
