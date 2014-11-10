SpreeAmazonPayments
===================

Introduction goes here.

Installation
------------

Add spree_amazon_payments to your Gemfile:

```
gem 'spree_amazon_payments'
```

Bundle your dependencies and run the installation generator:

```
bundle
bundle exec rails g spree_amazon_payments:install
```

Configuration
--------------
https://developer.amazonservices.com/gp/mws/faq.html#mwsCredentials

Refund Callback
--------------
You will need to configure Instant Notification Settings in order to accept the callback when a refund is completed. At https://sellercentral.amazon.com/gp/pyop/seller/account/settings/user-settings-view.html? you will set the Merchant URL to https://YOUR_STORE_URL/amazon_callback
