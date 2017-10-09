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
    <div id="test">ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ</div>
    <div id="author">Gonçalves</div>
  </body>
</html>}

TEST_HTML_WITH_HOST = %Q{
<html>
  <head>
    <style>
      #test { color: #123456; }
    </style>
  </head>
  <body>
    <img src="/images/test.png" />
  </body>
</html>
}

class HelperMailer < ActionMailer::Base
  default :host => "http://www.example.com/"

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
      format.html(:charset => "utf8") { render(:inline => TEST_HTML_UTF8) }
    end
  end

  def inline_css_hook_with_base_url
    mail_with_defaults do |format|
      format.html { render(:inline => TEST_HTML_WITH_HOST) }
    end
  end

  def with_attachment
    mail_with_defaults do |format|
      attachments["hello"] = File.read('test')
      format.html { render(:inline => TEST_HTML) }
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
    assert_match '<div id="test" style="color: #123456;">Test</div>', mail.html_part.body.encoded
    # Test generated text part
    assert_match 'Test', mail.text_part.body.encoded
  end

  def test_inline_css_hook_with_text_and_html_parts
    mail = HelperMailer.use_inline_css_hook_with_text_and_html_parts.deliver
    assert_match '<div id="test" style="color: #123456;">Test</div>', mail.html_part.body.encoded
    # Test specified text part
    assert_match 'Different Text Part', mail.text_part.decoded
  end

  def test_inline_css_hook_with_utf_8_characters
    mail = nil
    mail = HelperMailer.use_inline_css_hook_with_utf_8.deliver

    assert_match 'ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ', mail.html_part.decoded
    assert_match 'Gonçalves',      mail.html_part.decoded
    assert_match 'ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ', mail.text_part.decoded
    assert_match '=E1=9A=A0=E1=9B=87=E1=9A=BB=', mail.html_part.encoded

    assert_equal mail.html_part.content_transfer_encoding, "quoted-printable"
    assert_equal mail.text_part.content_transfer_encoding, "base64"
  end

  def test_inline_css_hook_with_base_url
    mail = HelperMailer.inline_css_hook_with_base_url.deliver
    assert_match '<img src="http://www.example.com/images/test.png">',
      mail.html_part.body.encoded
  end

  def test_preservation_of_attachments
    File.stubs(:read).returns("world")
    mail = HelperMailer.with_attachment
    assert mail.attachments["hello"].is_a?(Mail::Part)
    original_hello_attachment_url = mail.attachments["hello"].url
    m = ActionMailer::InlineCssHook.delivering_email(mail.deliver)
    assert m.attachments["hello"].is_a?(Mail::Part)
    assert_equal original_hello_attachment_url, mail.attachments["hello"].url
  end

  def test_alternative_content_type
    mail = HelperMailer.use_inline_css_hook_with_text_and_html_parts.deliver
    assert_match( /multipart\/alternative/, mail.content_type )
  end

  def test_mixed_content_type
    File.stubs(:read).returns("world")
    mail = HelperMailer.with_attachment
    m = ActionMailer::InlineCssHook.delivering_email(mail.deliver)
    assert_equal( "multipart/mixed", m.content_type )
  end
end
