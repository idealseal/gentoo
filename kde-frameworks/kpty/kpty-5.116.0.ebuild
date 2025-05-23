# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PVCUT=$(ver_cut 1-2)
inherit ecm frameworks.kde.org

DESCRIPTION="Framework for pseudo terminal devices and running child processes"
LICENSE="LGPL-2+"
KEYWORDS="amd64 ~arm arm64 ~loong ~ppc64 ~riscv ~x86"
IUSE=""

DEPEND="
	=kde-frameworks/kcoreaddons-${PVCUT}*:5
	=kde-frameworks/ki18n-${PVCUT}*:5
	sys-libs/libutempter
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DUTEMPTER_EXECUTABLE="${EPREFIX}/usr/sbin/utempter"
	)

	ecm_src_configure
}
