# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

MY_TESTDATA_COMMIT="381b447563f9bef87b218ebbedde3159afdc3032"

DESCRIPTION="Snowball compiler and stemming algorithms"
HOMEPAGE="https://snowballstem.org/ https://github.com/snowballstem/snowball/"
SRC_URI="https://github.com/snowballstem/snowball/archive/v${PV}.tar.gz -> ${P}.tar.gz
	test? ( https://github.com/snowballstem/snowball-data/archive/${MY_TESTDATA_COMMIT}.tar.gz -> snowball-data-${MY_TESTDATA_COMMIT}.tar.gz )"
S="${WORKDIR}/snowball-${PV}"

LICENSE="BSD"
SLOT="0/$(ver_cut 1)"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~ppc-macos"
IUSE="static-libs test"

BDEPEND="dev-lang/perl
	test? ( virtual/libiconv )"

RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}/${P}-shared-library.patch"
)

src_compile() {
	tc-export CC AR
	default
}

src_test() {
	emake -j1 STEMMING_DATA="${WORKDIR}/snowball-data-${MY_TESTDATA_COMMIT}" check
}

src_install() {
	dodoc README.rst NEWS

	dobin stemwords

	doheader include/libstemmer.h

	dolib.so libstemmer.so.${PV}
	dolib.so libstemmer.so.$(ver_cut 1)
	dolib.so libstemmer.so

	use static-libs && dolib.a libstemmer.a
}
