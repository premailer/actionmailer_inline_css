require 'premailer'
require 'nokogiri'
require 'action_mailer/inline_css_hook'
require 'overrides/premailer/premailer'

ActionMailer::Base.register_interceptor ActionMailer::InlineCssHook

