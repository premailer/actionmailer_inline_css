# ActionMailer Inline CSS [![TravisCI](http://travis-ci.org/ndbroadbent/actionmailer_inline_css.png?branch=master)](http://travis-ci.org/ndbroadbent/actionmailer_inline_css)

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


### Including CSS in Mail Templates

You can use the `stylesheet_link_tag` helper to add stylesheets to your mailer layouts.
<tt>actionmailer_inline_css</tt> contains a <tt>premailer</tt> override that properly handles
these CSS URIs.

#### Example

Add the following line to the `<head>` section of <tt>app/views/layouts/build_mailer.html.erb</tt>:

    <%= stylesheet_link_tag 'mailers/build_mailer' %>

This will add a stylesheet link for <tt>/stylesheets/mailers/build_mailer.css</tt>.
Premailer will then inline the CSS from that file, and remove the link tag.

