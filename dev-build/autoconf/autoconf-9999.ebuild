# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Bumping notes:
# * Remember to modify LAST_KNOWN_VER 'upstream' in dev-build/autoconf-wrapper
# on new autoconf releases, as well as the dependency in RDEPEND below too.
# * Update _WANT_AUTOCONF and _autoconf_atom case statement in autotools.eclass.

if [[ ${PV} == 9999 ]] ; then
	EGIT_REPO_URI="https://git.savannah.gnu.org/git/autoconf.git"
	inherit git-r3
else
	# For _beta handling replace with real version number
	MY_PV="${PV}"
	MY_P="${PN}-${MY_PV}"
	#PATCH_TARBALL_NAME="${PN}-2.70-patches-01"

	VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/zackweinberg.asc
	inherit verify-sig

	SRC_URI="
		mirror://gnu/${PN}/${MY_P}.tar.xz
		https://alpha.gnu.org/pub/gnu/${PN}/${MY_P}.tar.xz
		https://meyering.net/ac/${P}.tar.xz
		verify-sig? ( mirror://gnu/${PN}/${MY_P}.tar.xz.sig )
	"
	S="${WORKDIR}"/${MY_P}

	if [[ ${PV} != *_beta* ]] && ! [[ $(ver_cut 3) =~ [a-z] ]] ; then
		KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
	fi

	BDEPEND="verify-sig? ( sec-keys/openpgp-keys-zackweinberg )"
fi

inherit toolchain-autoconf multiprocessing

DESCRIPTION="Used to create autoconfiguration files"
HOMEPAGE="https://www.gnu.org/software/autoconf/autoconf.html"

LICENSE="GPL-3+"
SLOT="$(ver_cut 1-2)"

BDEPEND+="
	>=dev-lang/perl-5.10
	>=sys-devel/m4-1.4.16
"
RDEPEND="
	${BDEPEND}
	>=dev-build/autoconf-wrapper-20231224
	sys-devel/gnuconfig
	!~${CATEGORY}/${P}:2.5
"
[[ ${PV} == 9999 ]] && BDEPEND+=" >=sys-apps/texinfo-4.3"

src_prepare() {
	if [[ ${PV} == *9999 ]] ; then
		# Avoid the "dirty" suffix in the git version by generating it
		# before we run later stages which might modify source files.
		local ver=$(./build-aux/git-version-gen .tarball-version)
		echo "${ver}" > .tarball-version || die

		export WANT_AUTOCONF=2.5
		export WANT_AUTOMAKE=1.17
		# Don't try wrapping the autotools - this thing runs as it tends
		# to be a bit esoteric, and the script does `set -e` itself.
		./bootstrap || die
	fi

	# usr/bin/libtool is provided by binutils-apple, need gnu libtool
	if [[ ${CHOST} == *-darwin* ]] ; then
		PATCHES+=( "${FILESDIR}"/${PN}-2.71-darwin.patch )
	fi

	# Save timestamp to avoid later makeinfo call
	touch -r doc/{,old_}autoconf.texi || die

	toolchain-autoconf_src_prepare

	# Restore timestamp to avoid makeinfo call
	# We already have an up to date autoconf.info page at this point.
	touch -r doc/{old_,}autoconf.texi || die
}

src_test() {
	emake check TESTSUITEFLAGS="--jobs=$(get_makeopts_jobs)"
}

src_install() {
	toolchain-autoconf_src_install

	local f
	for f in config.{guess,sub} ; do
		ln -fs ../../gnuconfig/${f} \
			"${ED}"/usr/share/autoconf-*/build-aux/${f} || die
	done
}
