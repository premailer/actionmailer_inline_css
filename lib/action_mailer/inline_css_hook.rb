#
# Always inline CSS for HTML emails
#
module ActionMailer
  class InlineCssHook
    def self.delivering_email(message)
      if html_part = (message.html_part || (message.content_type =~ /text\/html/ && message))
        # Generate an email with all CSS inlined (access CSS a FS path)
        premailer = ::Premailer.new(html_part.body.to_s,
                                    :with_html_string => true)

        # Prepend host to remaning URIs.
        # Two-phase conversion to avoid request deadlock from dev. server (Issue #4)
        premailer = ::Premailer.new(premailer.to_inline_css,
                                      :with_html_string => true,
                                      :base_url => message.header[:host].to_s)
        existing_text_part = message.text_part && message.text_part.body.to_s
        existing_attachments = message.attachments
        msg_charset = message.charset

        # Reset the body
        message.body = nil
        message.body.instance_variable_set("@parts", Mail::PartsList.new)

        # Add an HTML part with CSS inlined.
        message.html_part do
          content_type "text/html; charset=#{charset}"
          body premailer.to_inline_css
        end

        # Add a text part with either the pre-existing text part, or one generated with premailer.
        message.text_part do
          content_type "text/plain; charset=#{charset}"
          body existing_text_part || premailer.to_plain_text
        end

        # Re-add any attachments
        existing_attachments.each {|a| message.body << a }

        message
      end
    end
  end
end
