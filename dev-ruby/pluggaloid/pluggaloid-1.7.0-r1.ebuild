# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby31 ruby32 ruby33 ruby34"

RUBY_FAKEGEM_EXTRADOC="README.md"

inherit ruby-fakegem
DESCRIPTION="Pluggaloid is extensible plugin system for mikutter"
HOMEPAGE="https://rubygems.org/gems/pluggaloid/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~riscv ~x86"

ruby_add_rdepend "
	>=dev-ruby/delayer-1.1.0:1
	dev-ruby/instance_storage:0
"

all_ruby_prepare() {
	sed -i -e '/bundler/ s:^:#:' Rakefile test/*_test.rb || die
}
