# blue-horizon
web-based user interface to terraforming the public cloud

[![Build Status](https://travis-ci.org/SUSE-Enceladus/blue-horizon.svg?branch=master)](https://travis-ci.org/SUSE-Enceladus/blue-horizon)
[![codecov](https://codecov.io/gh/SUSE-Enceladus/blue-horizon/branch/master/graph/badge.svg)](https://codecov.io/gh/SUSE-Enceladus/blue-horizon)
[![security](https://hakiri.io/github/SUSE-Enceladus/blue-horizon/master.svg)](https://hakiri.io/github/SUSE-Enceladus/blue-horizon/master)

## Requirements

Requirements are based on supported versions from SUSE Linux Enterprise Server 15 SP1.

* ruby 2.5.5
* rails 5.1.7
* puma 3.11.0
* sqlite3
* terraform 0.12
* any dependencies of your terraform scripts (e.g. `kubectl`, `helm`, etc.)

## Contributing

The Ruby project uses [rvm](http://rvm.io/rvm/basics) to manage a virtual environment for development.

1.  Clone this project

2.  RVM will prompt you to install the required ruby version, if necessary, when entering the project directory.

3.  Install dependencies
    ```
    gem install bundler
    bundle
    ```
    If you have trouble with _nokogiri_, make sure you have development versions of _libxml2_ & _libxslt_ installed. On (open)SUSE:
    ```
    sudo zypper in libxml2-devel libxslt-devel
    ```

4.  Create a dotenv file (e.g. `.env.development`) that defines:
    *   The cloud framework
        ```
        CLOUD_FRAMEWORK="aws"
        ```

5.  Place original _terraform_ scripts in `/vendor/sources`

    💡 _Need a simple script for development? Try this [gist](https://gist.github.com/bear454/96c067ab082f5c6cc9321061f601373f)._

6.  Initialize a development database
    ```
    rails db:setup
    ```

7.  Start a development server on http://localhost:3000
    ```
    rails server -b localhost -p 3000
    ````

Before submitting a change, please be sure it passes all existing tests and conforms with our coding style:

```
rspec
rubocop
```

Please be sure to include a screenshot with any view or style changes.

## Customization

_blue-horizon_ is pointless, without a set of terraform scripts to work from, and those scripts represent a "target application", which _blue-horizon_ can adapt to support. The `vendor` path is used by default to host content about the target application.

### Terraform sources

⚠ In order for terraform sources to work within _blue-horizon_, all customization must happen through terraform variables. Source files must not require editing.

`.tf`, `.tmpl`, `.sh`, `.yaml/.yml`, and `.json` files can be placed in `vendor/sources`, and loaded via `rails db:setup`.

**NOTE:** _The content of those files will be stored in the database, and may be edited by the application user. When terraform runs, it will run on exported content from the database, so it may not be identical to what was initially provided in `vendor/sources`._

Variables **must** be defined in terraform JSON format, and named `variable*.tf.json`.

To use a different path, set the environment variable `TERRAFORM_SOURCES_PATH` before seeding the database.

### String customization/localization

`.yml` and `.rb` files can be placed in `vendor/locales`, and will be loaded automatically.

See the
[Rails Internationalization Guide](https://guides.rubyonrails.org/i18n.html#how-to-store-your-custom-translations)
for advice on formatting.

See `config/locales/custom-en.yml` for a sample/template with keys defined.

To use a different path, set the environment variable `BLUE_HORIZON_LOCALIZERS` with the directory where custom internationalization files are stored.

### Application customization

`vendor/customization.json` defines configuration keys that can be modified to alter the behavior of the application.

See `config/initializers/customization.rb` for an explanation of the available keys and options.

To use a different path, set the environment variable `BLUE_HORIZON_CUSTOMIZER` with the full path of the customization JSON file to load.

## Packaging

_blue-horizon_ includes supporting tools and documents to build on an open build service (OBS) instance, such as https://build.opensuse.org

### New dependencies

1. When updating dependencies, add a categorized entry with a comment, in Gemfile.development. If the dependency is required in production, add the gemfile entry only, alphabetically, in Gemfile.production.

2. Run `rails gems:rpmspec:requires` and update the specfile (`packaging/blue-horizon.spec`) with the new dependency set.

### Releases

[bumpversion](https://pypi.org/project/bumpversion/) is used to tag releases.

```
bumpversion [major|minor|patch]
```

### Generating a tarball

1. In order to produce a production-ready tarball, assets need to be precompiled, then the tarball built:
  ```
  RAILS_ENV=production rails assets:clobber assets:precompile obs:tar
  ```
2. Copy the specfile and move the tarball to an OBS project dir
  ```
  cp packaging/* path/of/your/project/
  ```

## License

Copyright © 2019 SUSE LLC.
Distributed under the terms of GPL-3.0+ license, see [LICENSE](LICENSE) for details.
