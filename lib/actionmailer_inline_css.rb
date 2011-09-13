require 'premailer'
require 'nokogiri'
require 'action_mailer/inline_css_hook'
require 'action_mailer/inline_css_helper'

ActionMailer::Base.register_interceptor ActionMailer::InlineCssHook
ActionMailer::Base.send :helper, ActionMailer::InlineCssHelper

