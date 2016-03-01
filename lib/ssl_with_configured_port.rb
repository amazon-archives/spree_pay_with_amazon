# In development the website probably runs on a non default ssl port and you would
# have to specify that port all the time when doing *force_ssl* in development.
# So to make this more easy you can configure the SSL port in your
# *config/environment/development.rb*. For example if it runs on port 3001 use
#
#   config.ssl_port = 3001
#
# and then include this module in your ApplicationController and use
# *force_ssl_with_configured_port* instead of *force_ssl*
#
#   class ApplicationController < ActionController::Base
#     include SSLWithConfiguredPort
#     force_ssl_with_configured_port
#
#     ...
#   end

module SSLWithConfiguredPort
  extend ActiveSupport::Concern

  module ClassMethods
    def force_ssl_with_configured_port(options = {})
      options[:port] = Rails.application.config.ssl_port if options[:port].blank? && Rails.application.config.try(:ssl_port).present?
      force_ssl options
    end
  end
end
