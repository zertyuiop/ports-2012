# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/flickcurl/flickcurl-1.22.ebuild,v 1.1 2012/02/19 11:44:57 radhermit Exp $

EAPI="4"

inherit autotools

DESCRIPTION="C library for the Flickr API"
HOMEPAGE="http://librdf.org/flickcurl/"
SRC_URI="http://download.dajobe.org/flickcurl/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 GPL-2 Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc oauth raptor static-libs"

RDEPEND=">=net-misc/curl-7.10.0
	>=dev-libs/libxml2-2.6.8:2
	raptor? ( media-libs/raptor:2 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	if ! use doc ; then
		# Only install html documentation when the use flag is enabled
		sed -i -e '/gtk-doc.make/d' \
			-e 's:+=:=:' docs/Makefile.am || die
	else
		# Install html docs in the correct directory
		sed -i -e '/^TARGET_DIR/s:/$(DOC_MODULE)::' gtk-doc.make || die
	fi

	eautoreconf
}

src_configure() {
	econf \
		--with-html-dir=/usr/share/doc/${PF}/html \
		$(use_enable oauth) \
		$(use_with raptor) \
		$(use_enable static-libs static)
}

src_install() {
	default
	find "${ED}" -name '*.la' -exec rm -f '{}' +
}