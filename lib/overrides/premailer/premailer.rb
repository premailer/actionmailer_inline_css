require 'premailer'

Premailer.class_eval do
  protected
  # When using the 'stylesheet_link_tag' helper in Rails, css URIs are given with
  # a leading slash and a cache buster (e.g. ?12412422).
  # This override handles these cases, while falling back to the default implementation.
  def load_css_from_local_file_with_rails_path!(path)
    # Remove query string and the path
    clean_path = path.sub(/\?.*$/, '').sub(%r(^https?://[^/]*), '')
    rails_path = Rails.root.join('public', clean_path)
    if File.exist?(rails_path)
      load_css_from_string(File.read(rails_path))
    elsif (asset = Rails.application.assets.find_asset(clean_path.sub("#{Rails.configuration.assets.prefix}/", '')))
      load_css_from_string(asset.body)
    else
      load_css_from_local_file_without_rails_path!(path)
    end
  end
  alias_method_chain :load_css_from_local_file!, :rails_path

end

