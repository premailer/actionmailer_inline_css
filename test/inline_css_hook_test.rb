require 'abstract_unit'

class HelperMailer < ActionMailer::Base
  helper ActionMailer::InlineCssHelper

  def use_inline_css_hook
    mail_with_defaults do |format|
      format.html { render(:inline => %Q{
<html>
  <head>
    <style>
      #test { color: #123456; }
    </style>
  </head>
  <body>
    <div id="test">Test</div>
  </body>
</html>
}) }
      format.text { render(:inline => "Text Part") }
    end
  end

  protected

  def mail_with_defaults(&block)
    mail(:to => "test@localhost", :from => "tester@example.com",
          :subject => "using helpers", &block)
  end
end

class InlineCssHookTest < ActionMailer::TestCase
  def test_inline_css_hook
    mail = HelperMailer.use_inline_css_hook.deliver
    assert_match '<div id="test" style="color: #123456;">Test</div>', mail.html_part.body.encoded
  end
end

