require 'abstract_unit'
require 'mocha'
require 'action_mailer/inline_css_helper'

class HelperMailer < ActionMailer::Base
  helper ActionMailer::InlineCssHelper

  def use_embedded_style_tag
    mail_with_defaults do |format|
      format.html { render(:inline => "<%= embedded_style_tag %>") }
    end
  end

  protected

  def mail_with_defaults(&block)
    mail(:to => "test@localhost", :from => "tester@example.com",
          :subject => "using helpers", &block)
  end
end

# Simple Rails mock for paths
class Rails
  class << self
    def root; self; end
    def join(*args); self; end
    def to_s; "path"; end
  end
end

class InlineCssHelperTest < ActionMailer::TestCase
  def test_embedded_style_tag
    css = "body { display: none; }"
    File.stubs(:exist?).returns(true)
    File.stubs(:read).returns(css)
    mail = HelperMailer.use_embedded_style_tag
    assert_match "<style type=\"text/css\">#{css}</style>", mail.body.encoded
  end
end

