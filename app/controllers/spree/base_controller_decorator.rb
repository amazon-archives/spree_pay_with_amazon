require 'ssl_with_configured_port'

Spree::BaseController.class_eval do
  # Instead of *force_ssl* we use *force_ssl_with_configured_port* that will read
  # the SSL port from the config. We added a *if* so that this will only run
  # if the *use_ssl?* method below returns true.
  include SSLWithConfiguredPort
end
