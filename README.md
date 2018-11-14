# Indieweb::Authorship

Indieweb::Authorship is a Ruby gem for identifying the author of an IndieWeb post using the [authorship algorithm](http://indieweb.org/authorship#How_to_determine).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'indieweb-authorship'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install indieweb-authorship

## Usage

### From a URL

You can simply provide a URL and the page will be retrieved before authorship is determined.

```ruby
author = Indieweb::Authorship.identify(url)
```

### With pre-downloaded html (from a URL)

It is also possible to provide the html directly, along with the URL, in cases where you already have the page.

```ruby
author = Indieweb::Authorship.identify(url, html)
```

### Result

If an author is identified then the result will be a hash containing the fields `name` (for the name of the author), `photo` (with a url for a photo of the author), and `url` (with a url for the page of the author). Some of these may be `nil`, but all will still be provided. If no author can be identified then the result will simply be a `nil`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/srushe/indieweb-authorship.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Indieweb::Authorship project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/srushe/indieweb-authorship/blob/master/CODE_OF_CONDUCT.md).

## Credits

A number of the spec example files are from...

  * https://github.com/aaronpk/XRay/tree/master/tests/data/author.example.com

