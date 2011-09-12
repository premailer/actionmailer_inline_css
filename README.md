# ActionMailer Inline CSS

Seamlessly integrate [Alex Dunae's premailer](http://premailer.dialect.ca/) gem with ActionMailer.


## Problem?

The [Guide to CSS support in email](http://www.campaignmonitor.com/css/) from
[campaignmonitor.com](http://www.campaignmonitor.com) shows that Gmail doesn't
support `<style>` tags.

Thus, the only correct way to send HTML emails is when CSS is inlined on each element.


### [Email Client Popularity](http://www.campaignmonitor.com/stats/email-clients/):

| Outlook | 27.62% |
|------:|:------------|
| iOS Devices | 16.01% |
| Hotmail | 12.14% |
| Apple Mail | 11.13% |
| Yahoo! Mail | 9.54% |
| Gmail | 7.02% |

Gmail may only make up 7% of all email clients, but it's a percentage you can't ignore!


## Solution

Inlining CSS is a pain to do by hand, and that's where the
[premailer](http://premailer.dialect.ca/) gem comes in.

From http://premailer.dialect.ca/:

* CSS styles are converted to inline style attributes.
  Checks style and link[rel=stylesheet] tags and preserves existing inline attributes.
* Relative paths are converted to absolute paths.
  Checks links in href, src and CSS url('')


The <tt>actionmailer_inline_css</tt> gem is a tiny integration between ActionMailer and premailer.

Inspiration comes from [@fphilipe](https://github.com/fphilipe)'s
[premailer-rails3](https://github.com/fphilipe/premailer-rails3) gem, but I wasn't
completely happy with it's conventions.


## Installation & Usage

To use this in your Rails app, simply add `gem "actionmailer_inline_css"` to your `Gemfile`.

* If you already have an HTML email template, all CSS will be automatically inlined.
* If you don't include a text email template, <tt>premailer</tt> will generate one from the HTML part.
  (Having said that, it is recommended that you write your text templates by hand.)


### Additional Helpers

Rails does not provide any helpers for adding 'embedded' CSS to your layouts (and rightly so!),
but the following helper is now available for your mail layouts:

<tt>embedded_style_tag(file = mailer.mailer_name)</tt>

* Embeds CSS loaded from a file, in a <tt>style</tt> tag.
* File can be given with or without .css extension
* Default path for mailer css files is <tt>public/stylesheets/mailers/#{mailer_name}.css</tt>

#### Example

Given a mailer called <tt>BuildMailer</tt>, you can add the following
line to the `<head>` section of <tt>app/views/layouts/build_mailer.html.erb</tt>:

    <%= embedded_style_tag %>

This will embed the CSS found at <tt>public/stylesheets/mailers/build_mailer.css</tt>.

--------------------------

If you wanted to include different CSS for each mail template, you could do something like this:

    <% content_for 'head' do %>
      <%= embedded_style_tag 'error_notification' %>
    <% end %>


## Other Notes

It may seem like a waste of resources to generate HTML, then parse it with Nokogiri,
alter it, and finally re-render it. However, there is simply no other way to do it.
ERB templates contain HTML tags in plain text, so the output must be parsed.
On-the-fly CSS inlining could theoretically be built for Haml templates,
but it would be far too much effort for such a small use-case.

