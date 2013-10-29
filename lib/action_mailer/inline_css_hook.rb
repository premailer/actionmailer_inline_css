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

          # Important: Plain text part must be generated before the CSS is
          # inlined. Not doing so results in CSS declarations being visible
          # in the plain text part.
          text_alternative = Mail::Part.new do
            content_type "text/plain; charset=#{msg_charset}"
            body premailer.to_plain_text
          end

          html_alternative = Mail::Part.new do
            content_type "text/html; charset=#{msg_charset}"
            body premailer.to_inline_css
          end

          html_container        = Mail::Part.new { content_type "multipart/related" }
          alternative_container = Mail::Part.new { content_type "multipart/alternative" }

          alternative_container.add_part text_alternative
          alternative_container.add_part html_alternative

          message.add_part alternative_container

          # Change the content type to `multipart/mixed` while preserving
          # additional parameters such as `boundary`, `charset`, etc. if there
          # are any email attachments.
          unless existing_attachments.empty?
            content_type    = message.content_type.split(";")
            content_type[0] = "multipart/mixed"
            message.content_type content_type.join(";")
          end

          existing_attachments.each {|a| message.body << a }
        end

        message
      end
    end
  end
end
