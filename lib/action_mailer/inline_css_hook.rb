require 'base64'
#
# Always inline CSS for HTML emails
#
module ActionMailer
  class InlineCssHook
    def self.delivering_email(message)
      if html_part = (message.html_part || (message.content_type =~ /text\/html/ && message))
        premailer = Premailer.new(html_part.body.to_s, :with_html_string => true)
        existing_text_part = message.text_part && message.text_part.body.to_s

        # Reset the body
        message.body = nil

        # Add a text part with either the pre-existing text part, or one generated with premailer.
        message.text_part do
          body existing_text_part || premailer.to_plain_text
        end

        # Add an HTML part with CSS inlined.
        message.html_part do
          content_type "text/html; charset=utf-8"
          content_transfer_encoding "base64"
          body Base64.encode64(premailer.to_inline_css)
        end
      end
    end
  end
end

