#
# Always inline CSS for HTML emails
#
module ActionMailer
  class InlineCssHook

    # After registering ActionMailer::InlineCssHook as an interceptor, this
    # gets called prior to sending emails.
    def self.delivering_email(*args)
      new(*args).delivering_email
    end

    # @param message [Mail::Message]
    #
    # @return [ActionMailer::InlineCssHook]
    def initialize(message)
      @message     = message
      @attachments = @message.attachments
      @charset     = @message.charset
      @host        = ActionMailerInlineCss.base_url || @message.header[:host].to_s
    end

    # @return [Mail::Message]
    def delivering_email
      if html_part = (@message.html_part || (@message.content_type =~ /text\/html/ && @message))
        premailer = ::Premailer.new(html_part.body.to_s, with_html_string: true, base_url: @host)

        # Use the existing text part if it exists, otherwise build one.
        if @message.text_part && @message.text_part.body.to_s
          html_part.content_type "text/html; charset=#{@charset}"
          html_part.body premailer.to_inline_css
          @message.add_part nest_header_parts(@message.text_part, html_part)
        else
          @message.body = nil
          @message.add_part nest_header_parts(build_text_part(premailer), build_html_part(premailer))
        end

        add_attachments unless @attachments.empty?
        @message
      end
    end

    private

    # Change the content type to `multipart/mixed` while preserving aditional
    # parameters such as `boundary`, `charset`, etc.
    #
    # @return [void]
    def add_attachments
      content_type    = @message.content_type.split(";")
      content_type[0] = "multipart/mixed"
      @message.content_type content_type.join(";")

      @attachments.each { |a| @message.body << a }
    end

    # @param premailer [Premailer]
    #
    # @return [Mail::Part]
    def build_html_part(premailer)
      Mail::Part.new do
        content_type "text/html; charset=#{@charset}"
        body premailer.to_inline_css
      end
    end

    # @note Plain text part must be generated before the CSS is inlined. Not
    #   doing so results in CSS declarations being visible in the plain text
    #   part.
    #
    # @param premailer [Premailer]
    #
    # @return [Mail::Part]
    def build_text_part(premailer)
      Mail::Part.new do
        content_type "text/plain; charset=#{@charset}"
        body premailer.to_plain_text
      end
    end

    # Take two mail parts that belong at different levels in the MIME header
    # part hierachy and nest them appropriately. For reference, this is the
    # hierarchy:
    #
    #   multipart/mixed
    #     multipart/related
    #       multipart/alternative
    #         text/plain
    #         text/html
    #       image/jpeg (example) (inline attachments)
    #     aplication/pdf (example) (normal attachments)
    #
    # @param text_part [Mail::Part]
    # @param html_part [Mail::Part]
    #
    # @return [Mail::Part]
    def nest_header_parts(text_part, html_part)
      # Nest parts with content types `text/plain` and `text/html` inside of a
      # part with content type `multipart/alternative`.
      alternative_part = Mail::Part.new { content_type "multipart/alternative" }
      alternative_part.add_part text_part
      alternative_part.add_part html_part

      # Nest part with content type `multipart/alternative` inside of a part
      # with content type `multipart/related`.
      related_part = Mail::Part.new { content_type "multipart/related" }
      related_part.add_part alternative_part

      related_part
    end
  end
end