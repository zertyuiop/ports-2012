# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/ccrtp/ccrtp-1.6.0.ebuild,v 1.3 2012/05/05 02:54:23 jdhore Exp $

inherit multilib eutils

DESCRIPTION="GNU ccRTP is an implementation of RTP, the real-time transport protocol from the IETF"
HOMEPAGE="http://www.gnu.org/software/ccrtp/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

KEYWORDS="~amd64 ppc ~ppc64 ~x86"
LICENSE="GPL-2"
IUSE="doc"
SLOT="0"

RDEPEND=">=dev-cpp/commoncpp2-1.3.0
	dev-libs/libgcrypt"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-stdlib.patch
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README ChangeLog AUTHORS NEWS TODO
	use doc && dohtml -r doc/html/*
}

pkg_postinst() {
	if [[ -e "${ROOT}"/usr/$(get_libdir)/libccrtp1-1.4.so.0 ]] ; then
		elog "Please run: revdep-rebuild --library libccrtp1-1.4.so.0"
	fi
	if [[ -e "${ROOT}"/usr/$(get_libdir)/libccrtp1-1.5.so.0 ]] ; then
		elog "Please run: revdep-rebuild --library libccrtp1-1.5.so.0"
	fi
}
