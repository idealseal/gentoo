# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Bandwidth test for ROCm"
HOMEPAGE="https://github.com/RadeonOpenCompute/rocm_bandwidth_test"
SRC_URI="https://github.com/RadeonOpenCompute/${PN}/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-rocm-${PV}"

LICENSE="NCSA-AMD"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

DEPEND="dev-libs/rocr-runtime:="
RDEPEND="${DEPEND}"

src_prepare() {
	# the autodetection logic here is very very confused. This makes it not fail.
	sed -i -e 's/if(${hsa-runtime64_FOUND})/if(false)/' CMakeLists.txt
	cmake_src_prepare
}

src_install() {
	cmake_src_install

	rm -rfv "${ED}"/usr/share/doc/rocm-bandwidth-test
}
