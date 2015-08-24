# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

DESCRIPTION="Make /etc/resolv.conf a symlink to a runtime-writable location"
HOMEPAGE="https://www.gentoo.org"
SRC_URI=""

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+symlink"

S=${WORKDIR}

pkg_preinst() {
	if use symlink; then
		if [[ -f "${ROOT}"etc/resolv.conf && ! -L "${ROOT}"etc/resolv.conf ]]
		then # migrate existing resolv.conf
			if [[ "$(head -n 1 "${ROOT}"etc/resolv.conf)" \
					!= "# Generated by "* ]]; then

				eerror "${ROOT}etc/resolv.conf seems not to be autogenerated."
				eerror "Aborting build to avoid removing user data. If that file is supposed"
				eerror "to be autogenerated, please remove it manually. Otherwise, please"
				eerror "set USE=-symlink to avoid installing resolv.conf symlink."

				die "${ROOT}etc/resolv.conf not autogenerated"
			else
				ebegin "Moving ${ROOT}etc/resolv.conf to ${ROOT}var/run/"
				mv "${ROOT}"etc/resolv.conf "${ROOT}"var/run/
				eend ${?} || die
			fi
		fi
	fi
}

src_install() {
	# XXX: /run should be more correct, when it's supported by baselayout

	use symlink && dosym /var/run/resolv.conf /etc/resolv.conf
}

pkg_postrm() {
	# Don't leave the user with no resolv.conf
	if [[ ! -e "${ROOT}"etc/resolv.conf && -f "${ROOT}"var/run/resolv.conf ]]; then
		ebegin "Moving ${ROOT}var/run/resolv.conf to ${ROOT}etc/"
		mv "${ROOT}"var/run/resolv.conf "${ROOT}"etc/
		eend ${?} || die
	fi
}
