#
# spec file for package blue-horizon
# this code base is under development
#
# Copyright (c) 2020 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugzilla.suse.com/
#

Name:      blue-horizon
Version:   0.0.1
Release:   0
License:   GPL-3.0
Summary:   Web server interface for terraforming in a public cloud
URL:       http://www.github.com/suse-enceladus/blue-horizon
Source0:   %{name}-%{version}.tar.bz2
# requirements generated via `rake gems:rpmspec:requires`
BuildRequires:  ruby-macros >= 5
Requires:  %{ruby}
Requires:  %{rubygem actioncable}
Requires:  %{rubygem actionmailer}
Requires:  %{rubygem actionpack}
Requires:  %{rubygem actionview}
Requires:  %{rubygem active_link_to}
Requires:  %{rubygem activejob}
Requires:  %{rubygem activemodel}
Requires:  %{rubygem activerecord}
Requires:  %{rubygem activesupport}
Requires:  %{rubygem addressable}
Requires:  %{rubygem arel}
Requires:  %{rubygem builder}
Requires:  %{rubygem cloud-instancetype}
Requires:  %{rubygem concurrent-ruby}
Requires:  %{rubygem crass}
Requires:  %{rubygem erubi}
Requires:  %{rubygem erubis}
Requires:  %{rubygem globalid}
Requires:  %{rubygem haml}
Requires:  %{rubygem haml-rails}
Requires:  %{rubygem hamster}
Requires:  %{rubygem hcl-checker}
Requires:  %{rubygem html2haml}
Requires:  %{rubygem i18n}
Requires:  %{rubygem jbuilder}
Requires:  %{rubygem lino}
Requires:  %{rubygem loofah}
Requires:  %{rubygem mail}
Requires:  %{rubygem method_source}
Requires:  %{rubygem mini_mime}
Requires:  %{rubygem mini_portile2}
Requires:  %{rubygem minitest}
Requires:  %{rubygem nio4r}
Requires:  %{rubygem nokogiri}
Requires:  %{rubygem open4}
Requires:  %{rubygem public_suffix}
Requires:  %{rubygem puma}
Requires:  %{rubygem rack}
Requires:  %{rubygem rack-test}
Requires:  %{rubygem rails}
Requires:  %{rubygem rails-dom-testing}
Requires:  %{rubygem rails-html-sanitizer}
Requires:  %{rubygem railties}
Requires:  %{rubygem rake}
Requires:  %{rubygem redcarpet}
Requires:  %{rubygem ruby-terraform}
Requires:  %{rubygem ruby_parser}
Requires:  %{rubygem sexp_processor}
Requires:  %{rubygem sprockets}
Requires:  %{rubygem sprockets-rails}
Requires:  %{rubygem sqlite3}
Requires:  %{rubygem temple}
Requires:  %{rubygem thor}
Requires:  %{rubygem thread_safe}
Requires:  %{rubygem tilt}
Requires:  %{rubygem tzinfo}
Requires:  %{rubygem websocket-driver}
Requires:  %{rubygem websocket-extensions}
# end generated requirements
BuildRequires: nginx
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch: noarch

%description
A customizable web interface for setting variables and executing a predefined
terraform script in a supported cloud service provider (CSP) environment.

%prep
%setup

%build

%install
install -m 0755 -d %{buildroot}/srv/www/%{name}
cp -r app config db public config.ru Gemfile %{buildroot}/srv/www/%{name}/

%files
%defattr(-,root,root,-)
%doc README.md LICENSE
%defattr(-,nginx,nginx,-)
/srv/www/%{name}

%changelog
