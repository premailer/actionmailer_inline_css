# encoding: utf-8

require 'abstract_unit'

TEST_HTML = %Q{
<html>
  <head>
    <style>
      #test { color: #123456; }
    </style>
  </head>
  <body>
    <div id="test">Test</div>
  </body>
</html>}

TEST_HTML_UTF8 = %Q{
<html>
  <head>
    <style>
      #test { color: #123456; }
    </style>
  </head>
  <body>
    <div id="test">ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ</div>
  </body>
</html>}

class HelperMailer < ActionMailer::Base
  def use_inline_css_hook_with_only_html_part
    mail_with_defaults do |format|
      format.html { render(:inline => TEST_HTML) }
    end
  end

  def use_inline_css_hook_with_text_and_html_parts
    mail_with_defaults do |format|
      format.html { render(:inline => TEST_HTML) }
      format.text { render(:inline => "Different Text Part") }
    end
  end

  def use_inline_css_hook_with_utf_8
    mail_with_defaults do |format|
      format.html { render(:inline => TEST_HTML_UTF8) }
    end
  end

  protected

  def mail_with_defaults(&block)
    mail(:to => "test@localhost", :from => "tester@example.com",
          :subject => "using helpers", &block)
  end
end


class InlineCssHookTest < ActionMailer::TestCase
  def test_inline_css_hook_with_only_html_part
    mail = HelperMailer.use_inline_css_hook_with_only_html_part.deliver
    assert_match '<div id="test" style="color: #123456;">Test</div>', mail.html_part.decoded
    # Test generated text part
    assert_match 'Test', mail.text_part.decoded
  end

  def test_inline_css_hook_with_text_and_html_parts
    mail = HelperMailer.use_inline_css_hook_with_text_and_html_parts.deliver
    assert_match '<div id="test" style="color: #123456;">Test</div>', mail.html_part.decoded
    # Test specified text part
    assert_match 'Different Text Part', mail.text_part.decoded
  end

  def test_inline_css_hook_with_utf_8_characters
    mail = HelperMailer.use_inline_css_hook_with_utf_8.deliver

    html, text = mail.html_part.body.decoded, mail.text_part.body.decoded
    if RUBY_VERSION =~ /1.9/
      # In Ruby 1.9, Mail does not set encoding to UTF-8 when decoding the Base64 string.
      # This is an internal issue, and not a problem for email clients.
      html, text = html.force_encoding('UTF-8'), text.force_encoding('UTF-8')
    end

    [html, text].each do |part|
      assert_match 'ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ', part
    end
  end
end

