# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/rar2fs/rar2fs-1.16.0.ebuild,v 1.3 2013/05/09 18:16:03 ssuominen Exp $

EAPI=5
inherit autotools eutils

DESCRIPTION="A FUSE based filesystem that can mount one or multiple RAR archive(s)"
HOMEPAGE="http://code.google.com/p/rar2fs/"
SRC_URI="http://rar2fs.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND="=app-arch/unrar-4.2*:=
	sys-fs/fuse"
DEPEND="${RDEPEND}"

DOCS="AUTHORS ChangeLog"

src_prepare() {
	epatch "${FILESDIR}"/${P}-destdir.patch
	sed -i -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' configure.ac || die
	eautoreconf
}

src_configure() {
	export USER_CFLAGS="${CFLAGS}"

	local mydebug
	use debug && mydebug="--enable-debug=4"

	econf \
		--with-unrar=/usr/include/libunrar \
		${mydebug}
}
