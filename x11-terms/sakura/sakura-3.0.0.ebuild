# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/sakura/sakura-3.0.0.ebuild,v 1.1 2012/02/28 02:42:04 radhermit Exp $

EAPI=4
inherit cmake-utils

DESCRIPTION="sakura is a terminal emulator based on GTK and VTE"
HOMEPAGE="http://www.pleyades.net/david/projects/sakura/"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
LANGS=" ca cs de es fr hr hu it ja ko pl pt_BR ru zh_CN"
IUSE="${LANGS// / linguas_}"

RDEPEND="
	>=dev-libs/glib-2.20:2
	x11-libs/gtk+:3
	>=x11-libs/vte-0.28:2.90
"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5.10.1
	dev-util/pkgconfig
"

PATCHES=( "${FILESDIR}"/${P}-cflags.patch )

DOCS=( AUTHORS INSTALL )

src_prepare() {
	sed -i -e "/FILES INSTALL/d" CMakeLists.txt || die

	for lang in ${LANGS}; do
		if ! use linguas_${lang}; then
			rm -f po/${lang}.po || die
		fi
	done

	base_src_prepare
}