# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_10 python3_11 python3_12 python3_13 )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

MY_PN="check_openvpn"
DESCRIPTION="A Nagios plugin to check whether an OpenVPN server is alive"
HOMEPAGE="https://github.com/liquidat/nagios-icinga-openvpn"
SRC_URI="https://github.com/liquidat/nagios-icinga-openvpn/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~riscv"

src_install() {
	distutils-r1_src_install

	local nagiosplugindir="/usr/$(get_libdir)/nagios/plugins"
	dodir "${nagiosplugindir}"

	# Create a symlink from the nagios plugin directory to the /usr/bin
	# location. The "binary" in /usr/bin should also be a symlink, since
	# the python machinery allows the user to switch out the
	# interpreter. We don't want to mess with any of that, so we just
	# point to whatever the system would use if the user executed
	# ${MY_PN}.
	#
	# The relative symlink is preferred so that if the package is
	# installed e.g. while in a chroot, the symlink will never point
	# outside of that chroot.
	#
	dosym "../../../bin/${MY_PN}" "${nagiosplugindir}/${MY_PN}"
}
