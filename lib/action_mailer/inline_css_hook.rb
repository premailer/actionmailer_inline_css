#
# Always inline CSS for HTML emails
#
module ActionMailer
  class InlineCssHook
    def self.delivering_email(message)

      if html_part = (message.html_part || (message.content_type =~ /text\/html/ && message))
        host = ActionMailerInlineCss.base_url || message.header[:host].to_s

        # Generate an email with all CSS inlined (access CSS a FS path), and URIs
        premailer = ::Premailer.new(html_part.body.to_s, :with_html_string => true, :base_url => host)

        msg_charset = message.charset

        if message.text_part && message.text_part.body.to_s
          html_part.content_type "text/html; charset=#{msg_charset}"
          html_part.body premailer.to_inline_css
        else
          existing_attachments = message.attachments

          # Clear body to make a multipart email
          message.body = nil

          # IMPORTANT: Plain text part must be generated before CSS is inlined.
          # Not doing so results in CSS declarations (<style>) visible in the plain text part.
          message.text_part = Mail::Part.new do
            content_type "text/plain; charset=#{msg_charset}"
            body premailer.to_plain_text
          end

          message.html_part = Mail::Part.new do
            content_type "text/html; charset=#{msg_charset}"
            body premailer.to_inline_css
          end

          message.content_type 'multipart/mixed' if ! existing_attachments.empty?

          existing_attachments.each {|a| message.body << a }
        end

        message
      end
    end
  end
end
