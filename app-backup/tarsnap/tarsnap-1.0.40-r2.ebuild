# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1 toolchain-funcs

DESCRIPTION="Online backups for the truly paranoid"
HOMEPAGE="https://www.tarsnap.com/"
SRC_URI="https://www.tarsnap.com/download/${PN}-autoconf-${PV}.tgz"
S="${WORKDIR}"/${PN}-autoconf-${PV}

LICENSE="tarsnap BSD BSD-2 MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="acl bzip2 lzma xattr"
# The tarsnap license allows redistribution only without modification.
# Commented out because patches apply only to files with a free license.
#RESTRICT="bindist"

RDEPEND="
	app-arch/bzip2
	dev-libs/openssl:=
	sys-fs/e2fsprogs
	sys-libs/zlib
	acl? ( sys-apps/acl )
	lzma? ( app-arch/xz-utils )
	xattr? ( sys-apps/attr )
"
# Required for "magic.h"
DEPEND="
	${RDEPEND}
	virtual/os-headers
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.0.39-respect-AR.patch
	"${FILESDIR}"/${P}-strict-aliasing-fix.patch
)

QA_CONFIG_IMPL_DECL_SKIP=(
	# false positive due to outdated autoconf, bug #900124
	# release tarballs don't contain configure.ac!!!
	makedev
)

src_configure() {
	local myeconfargs=(
		$(use_enable xattr)
		$(use_enable acl)
		# The bundled libarchive (ancient copy) always builds
		# the bzip2 bits.
		--with-bz2lib
		--without-lzmadec
		$(use_with lzma)
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	emake AR="$(tc-getAR)"
}

src_install() {
	default
	dobashcomp misc/bash_completion.d/*
}
