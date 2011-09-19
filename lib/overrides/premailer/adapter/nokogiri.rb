require 'premailer/adapter/nokogiri'

Premailer::Adapter::Nokogiri.module_eval do
  # Patch load_html method to fix character encoding issues.
  # Assume that actionmailer_inline_css will always be loading html from a UTF-8 string.
  def load_html(html)
    # Force UTF-8 encoding
    if RUBY_VERSION =~ /1.9/
      doc = ::Nokogiri::HTML(html.encode('UTF-8')) {|c| c.recover }
    else
      doc = ::Nokogiri::HTML(html, nil, 'UTF-8') {|c| c.recover }
    end

    return doc
  end
end

