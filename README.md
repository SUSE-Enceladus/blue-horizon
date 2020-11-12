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
* terraform 0.13.4
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
    If you have trouble with _nokogiri_, make sure you have development versions of _libxml2_ & _libxslt_ installed. Install also sqlite-devel. On (open)SUSE:
    ```
    sudo zypper in libxml2-devel libxslt-devel sqlite3-devel
    ```


4.  If you need to use a path _other than_ `./vendor/` for customization, create a dotenv file (e.g. `.env.development`) that defines:
    *   The path to the customization JSON:
        ```
        BLUE_HORIZON_CUSTOMIZER = "./vendor/customization.yml"
        ```
    *   The path where _terraform_ sources will be imported from:
        ```
        TERRAFORM_SOURCES_PATH = "./vendor/sources"
        ```

5.  Place original _terraform_ scripts in `/vendor/sources` (or your custom `TERRAFORM_SOURCES_PATH`)

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

Variables **must** be defined in terraform JSON format, and named `variable*.tf.json`. Here some additional tips to customize your variables options:
- Variables will be _required_ unless the description includes the word "optional".
- Variables with "password" word in the description will be configured as password inputs hiding the content. This keyword value can be changed in the `en.yml` configuration file changing `password_key` entry.
- Variables with `options=[option1,option2]` content in the description will create a multi option input. Options are comma-separated, but may include any other punctuation, or spaces. The keyword value can be changed in the `en.yml` configuration file changing `options_key` entry.
- Variables with `[group:some_group_name]` will be grouped together (but still listed as ordered in the variables file). The group name will be pulled form I18N configuration, or otherwise titleized. (e.g. `[group:important_things]` will render as 'Important Things')
- Variables with `[pattern:/my expression/]` will have a client side validation to check if the input string is valid.
- Variables with `[extra_information:my variable information]` will have the provided content in the input title attribute, which creates a tooltip text when the mouse moves over the element. This option combines together with the pattern option to display the error message if the pattern validation fails.
- Variables of type `string` with a name ending in `_file` (e.g. `key_file`) will be presented as a file upload form field. The file contents will be appended to sources, and written back to disk with the full terraform source set. The file name will be stored in the variable. Inside _terraform_ scripts the file can be accessed via `file(var.key_file)`.
- Variable descriptions may include a comment that is not displayed. Any content contained in an HTML comment block `<!-- like this -->` will not be included in the UI, but _will_ be parsed for other customization flags.
- Variable descriptions will be rendered as inline _markdown_ in the UI.

#### Special variables

The following variables will not be displayed on the variable entry form, but will be populated via other application interfaces:
- `instance_type`: the virtual machine type to be used when starting cloud instances; this will be populated from the _Size Cluster_ page.
- `instance_count`: the number of virtual machines to be deployed; this will be populate from the _Size Cluster_ page.
- `region`: the cloud provider's region where services will be established. If _blue-horizon_ is run in a cloud environment; the location will be autodetected via Instance Meta Data Services (IMDS).
  ⚠ _End users should be notified that the application needs to run in the same region where it will be deployed._

To use a different path, set the environment variable `TERRAFORM_SOURCES_PATH` before seeding the database.

### String customization/localization

`.yml` and `.rb` files can be placed in `vendor/locales`, and will be loaded automatically.

See the
[Rails Internationalization Guide](https://guides.rubyonrails.org/i18n.html#how-to-store-your-custom-translations)
for advice on formatting.

See `config/locales/custom-en.yml` for a sample/template with keys defined.

To use a different path, set the environment variable `BLUE_HORIZON_LOCALIZERS` with the directory where custom internationalization files are stored.

#### Including *terraform* output in *Next steps*

The `next_steps` content, presented on the last page after deployment, can include terraform outputs. Put a placeholder in the content in the format `%{OUTPUT_NAME}`.

For example, if your terraform scripts include:

```
output "greeting" {
    value = "Hello, World."
}
```

... and your `next_steps` translation includes:

```
**%{greeting}**
```

It would render as:

> **Hello, World.**

### Application customization

`vendor/customization.json` defines configuration keys that can be modified to alter the behavior of the application.

See `config/initializers/customization.rb` for an explanation of the available keys and options.

To use a different path, set the environment variable `BLUE_HORIZON_CUSTOMIZER` with the full path of the customization JSON file to load.

#### View overrides

Any view or partial view (see `app/views`) can be overridden with an application-specific view. Set the configuration option `"override_views": true`, then copy the original to `vendor/views`, (e.g. `app/views/plans/_plan.haml` to `vendor/views/plans/_plan.haml`) and make your customizations in the copy.

#### Top menu items

A a group of custom top-menu links can be added to application views. If the links use *terraform* outputs, they will only be enabled on the `/wrapup` (*Next steps*) page. Links may open in the same browser context, or request a new tab/window.

The following example custom configuration will provide a static link that opens in a new tab, as well as an output-driven link that will only be enabled on *next steps*:

```
"top_menu_items": [
    {
        "key": "more-info",
        "url": "https://github.com/SUSE-Enceladus/blue-horizon",
        "target_new_window": true
    },
    {
        "key": "monitor",
        "url": "%{monitoring_url}"
    }
]
```

The `"key"` must match a translation value in the `menu` scope (e.g. `menu.more-info`, `menu.monitor`). Some common values are provided for convenience, but may be overriden or extended via localization.

`"target_new_window"` only needs to be set if the value is `true`; `false` is otherwise assumed.

A "*Deploy*" menu entry will be set, first, if any custom menu items are included.

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
