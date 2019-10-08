# blue-horizon
web-based user interface to terraforming the public cloud

[![Build Status](https://travis-ci.org/SUSE-Enceladus/blue-horizon.svg?branch=master)](https://travis-ci.org/SUSE-Enceladus/blue-horizon)

## Requirements

Requirements are based on supported versions from SUSE Linux Enterprise Server 15 SP1.

* ruby 2.5.5
* rails 5.1.4
* puma 3.11.0
* sqlite3

## Contributing

The Ruby project uses [rvm](http://rvm.io/rvm/basics) to manage a virtual environment for development.

1. Clone this project
2. RVM will prompt you to istall the required ruby version, if necessary, when entering the project directory.
3. Install dependencies
  ```
  gem install bundler
  bundle
  ```
  If you have trouble with _nokogiri_, make sure you have development versions of _libxml2_ & _libxslt_ installed. On (open)SUSE:
  ```
  sudo zypper in libxml2-devel libxslt-devel
  ```
4. Initialize a development database
  ```
  rails db:reset
  ```
5. Start a development server on http://localhost:3000
   ```
   rails server -b localhost -p 3000
   ````
## License

Copyright © 2019 SUSE LLC.
Distributed under the terms of GPL-3.0+ license, see [LICENSE](LICENSE) for details.
