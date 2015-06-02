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
[Register for your Amazon Payments account here](https://sellercentral.amazon.com/hz/me/sp/signup?solutionProviderOptions=lwa%3Bmws-acc%3B&marketplaceId=AGWSWK15IEJJ7&solutionProviderToken=AAAAAQAAAAEAAAAQw%2B2XzpFj2GWN0gTo0twkdAAAAHAcjkEL%2FdK5mKZbaJyrLpiWRmzHCLnC5eLDc8TlCy4aHUaagtgrQcxbsBRi5Y3xsRv1jXEP2QFuCAniHYcBxE%2FpbFnuBaEBPHBANejgd8xYL4fBX8Fz3I9%2Fl5bmIYBWyvSCEP8MPJQ6KKCNwPGcV%2FDN&solutionProviderId=A31NP5KFHXSFV1)

Refund Callback
--------------
You will need to configure Instant Notification Settings in order to accept the callback when a refund is completed. Configure your IPN settings by logging into your [Seller Central Account](https://sellercentral.amazon.com/gp/pyop/seller/account/settings/user-settings-view.html?).

The IPN URL will be in the Configuration section of your Spree Commerce instance.

User Guide
--------------
Please see the user guide [here](https://github.com/amzn/spree_pay_with_amazon/blob/master/LoginandPaywithAmazonforSpreeCommerce.pdf?raw=true) for more information
