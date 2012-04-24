# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/ski/ski-1.3.2.ebuild,v 1.2 2012/04/17 04:01:05 vapier Exp $

EAPI="4"

inherit autotools eutils

DESCRIPTION="ia64 instruction set simulator"
HOMEPAGE="http://ski.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+gtk motif"

# We use ltdl from libtool at runtime.
RDEPEND="sys-devel/libtool
	|| ( dev-libs/elfutils dev-libs/libelf )
	sys-libs/ncurses
	gtk? ( x11-libs/gtk+:2 )
	motif? ( x11-libs/openmotif )"
DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex
	dev-util/gperf"

PATCHES=(
	"${FILESDIR}"/${P}-syscall-linux-includes.patch
	"${FILESDIR}"/${P}-remove-hayes.patch
	"${FILESDIR}"/${P}-no-local-ltdl.patch
	"${FILESDIR}"/${P}-AC_C_BIGENDIAN.patch
	"${FILESDIR}"/${P}-configure-withval.patch
)

src_prepare() {
	epatch "${PATCHES[@]}"

	rm -rf libltdl src/ltdl.[ch] macros/ltdl.m4

	AT_M4DIR="macros" eautoreconf
}

src_configure() {
	econf \
		--without-included-ltdl \
		$(use_with gtk) \
		$(use_with motif x11)
}