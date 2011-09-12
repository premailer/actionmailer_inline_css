module ActionMailer
  module InlineCssHelper
    # Embed CSS loaded from a file in a 'style' tag.
    # CSS file can be given with or without .css extension,
    # and will be searched for in "#{Rails.root}/public/stylesheets/mailers" by default.
    def embedded_style_tag(file = mailer.mailer_name)
      ['.css', ''].each do |ext|
        [Rails.root.join("public", "stylesheets", "mailers"), Rails.root].each do |parent_path|
          guessed_path = parent_path.join(file+ext).to_s
          if File.exist?(guessed_path)
            return content_tag(:style, File.read(guessed_path), {:type => "text/css"}, false)
          end
        end
      end
      nil
    end

  end
end

