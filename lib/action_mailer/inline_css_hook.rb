#
# Always inline CSS for HTML emails
#
module ActionMailer
  class InlineCssHook
    def self.delivering_email(message)
      if html_part = (message.html_part || (message.content_type =~ /text\/html/ && message))
        host = ActionMailerInlineCss.base_url || message.header[:host].to_s

        # Generate an email with all CSS inlined (access CSS a FS path)
        premailer = ::Premailer.new(html_part.body.to_s, :with_html_string => true)
        # Prepend host to remaning URIs.
        # Two-phase conversion to avoid request deadlock from dev. server (Issue #4)
        premailer = ::Premailer.new(premailer.to_inline_css, :with_html_string => true, :base_url => host)

        existing_text_part = message.text_part && message.text_part.body.to_s
        msg_charset = message.charset

        html_part.body = premailer.to_inline_css

        unless existing_text_part
          message.text_part do
            content_type "text/plain; charset=#{msg_charset}"
            body existing_text_part || premailer.to_plain_text
          end
        end

        message
      end
    end
  end
end
