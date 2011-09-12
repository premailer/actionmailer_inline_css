require 'premailer'
require 'nokogiri'
require 'action_mailer/inline_css_hook'
require 'action_mailer/inline_css_helper'

require 'rails'
class InlineCssRailtie < Rails::Railtie
  config.after_initialize do
    ActionMailer::Base.register_interceptor ActionMailer::InlineCssHook
    ActionMailer::Base.send :helper, ActionMailer::InlineCssHelper
  end
end

