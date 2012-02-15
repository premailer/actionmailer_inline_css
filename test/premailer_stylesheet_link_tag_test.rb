require 'abstract_unit'

ENV["RAILS_ASSET_ID"] = "123456"

class HelperMailer < ActionMailer::Base
  default :host => "http://www.example.com/"

  def use_stylesheet_link_tag
    mail_with_defaults do |format|
      format.html { render(:inline => %Q{
        <html>
          <head>
            <%= stylesheet_link_tag 'mailers/mailer' %>
          </head>
          <body>
            <div class="test">Test</div>
          </body>
        </html>
      }) }
    end
  end

  protected

  def mail_with_defaults(&block)
    mail(:to => "test@localhost", :from => "tester@example.com",
          :subject => "using helpers", &block)
  end
end

class PremailerStylesheetLinkTagTest < ActionMailer::TestCase
  def test_premailer_stylesheet_link_tag
    File.stubs(:exist?).returns(true)
    File.stubs(:exists?).returns(true)
    File.stubs(:read).returns("div.test { color: #119911; }")

    mail = HelperMailer.use_stylesheet_link_tag.deliver
    assert_match %Q{<div class="test" style="color: #119911;">}, mail.html_part.body.encoded
  end
end

