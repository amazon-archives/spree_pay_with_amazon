class AddIdentifierToPayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :identifier, :string
  end
end
