spree_pay_with_amazon
===================

Add Pay with Amazon to your Spree Commerce solution.

Installation
------------

Add spree_amazon_payments to your Gemfile:

```
gem 'spree_social', github: 'spree-contrib/spree_social', branch: '3-0-stable'
gem 'spree_amazon_payments', github: 'amzn/spree_pay_with_amazon'
```

Bundle your dependencies and run the installation generator:

```
bundle
bundle exec rails g spree_amazon_payments:install
bundle exec rails g spree_social:install
```

Registration
--------------
[Register for your Amazon Payments account here](https://payments.amazon.com/register?registration_source=SPPD&spId=A31NP5KFHXSFV1)

Refund Callback
--------------
You will need to configure Instant Notification Settings in order to accept the callback when a refund is completed. Configure your IPN settings by logging into your [Seller Central Account](https://sellercentral.amazon.com/gp/pyop/seller/account/settings/user-settings-view.html?).

The IPN URL will be in the Configuration section of your Spree Commerce instance.

User Guide
--------------
Please see the user guide [here](https://github.com/amzn/spree_pay_with_amazon/blob/master/LoginandPaywithAmazonforSpreeCommerce.pdf?raw=true) for more information
