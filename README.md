# ELIXIR Toolkit Theme Plugins

Here we collect scripts to add aditional features to the [ELIXIR Toolkit Theme](https://github.com/ELIXIR-Belgium/elixir-toolkit-theme).

This features include:

* An improved way of tagging tools from a central tools table in the content of a page.
* Making sure the correct Git branch is detected when the theme is being deployed.

## Local development

### Requirements

* **Ruby** (the release workflow uses Ruby 3.3)
* **Bundler**

### Building the gem locally

The gem version is read from [`lib/elixir-toolkit-theme-plugins/version.rb`](lib/elixir-toolkit-theme-plugins/version.rb), so bump `VERSION` there first if needed. Then build from the root of this repository:

```sh
gem build elixir-toolkit-theme-plugins.gemspec
```

This produces `elixir-toolkit-theme-plugins-<VERSION>.gem`. Built gems are ignored by `.gitignore`, so they will not show up in `git status`.

To install your local build into your Ruby installation:

```sh
gem install ./elixir-toolkit-theme-plugins-<VERSION>.gem
```

### Testing with an ETT deployment

You need a Jekyll site that uses the theme to see the plugins in action. Either works:

* the [theme repository](https://github.com/ELIXIR-Belgium/elixir-toolkit-theme) itself, which is a full Jekyll site
* the [example site](https://github.com/ELIXIR-Belgium/elixir-toolkit-theme-example)


Pin that exact version in the site's `Gemfile`:

```ruby
gem "elixir-toolkit-theme-plugins", "<VERSION>"
```

Followed by `bundle install`. This is the closest match to what users get from RubyGems.

#### What to check

The plugins only do something on pages that use them, so make sure your test site exercises them:

* The `{% tool "tool_id" %}` tag and the resource tables read `_data/tool_and_resource_list.yml` from the **site root**. Run `jekyll` from that root, otherwise the tools file is not found.
* In the theme repository, `pages/documentation/resource_table.md` already contains `{% tool %}` examples. Load that page and click a tool to open its popover.

## Releasing

Releases are automated by [`.github/workflows/release.yml`](.github/workflows/release.yml).

Consumers pin this gem to an exact version, so a new release also needs the version bumped in the theme's `Gemfile` and `elixir-toolkit-theme.gemspec`.
