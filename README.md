spree_pay_with_amazon
===================

Add Pay with Amazon to your Spree Commerce solution.

Installation
------------

Add spree_amazon_payments to your Gemfile:

```
gem 'spree_amazon_payments', github: 'amzn/spree_pay_with_amazon'
```

Bundle your dependencies and run the installation generator:

```
bundle
bundle exec rails g spree_amazon_payments:install
```

Registration
--------------
https://payments.amazon.com/signup @TODO change this to the branded reg link when the account is updated

Refund Callback
--------------
You will need to configure Instant Notification Settings in order to accept the callback when a refund is completed. At https://sellercentral.amazon.com/gp/pyop/seller/account/settings/user-settings-view.html? you will set the Merchant URL to https://YOUR_STORE_URL/amazon_callback
