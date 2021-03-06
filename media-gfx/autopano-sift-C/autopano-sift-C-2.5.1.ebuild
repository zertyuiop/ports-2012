# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/autopano-sift-C/autopano-sift-C-2.5.1.ebuild,v 1.6 2013/06/01 14:05:57 creffett Exp $
EAPI=5

inherit cmake-utils versionator

DESCRIPTION="SIFT algorithm for automatic panorama creation in C"
HOMEPAGE="http://hugin.sourceforge.net/ http://user.cs.tu-berlin.de/~nowozin/autopano-sift/"
SRC_URI="mirror://sourceforge/hugin/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

S="${WORKDIR}/${PN}-$(get_version_component_range 1-3)"

DEPEND="!media-gfx/autopano-sift
	dev-libs/libxml2
	media-libs/libpano13
	media-libs/libpng
	media-libs/tiff
	sys-libs/zlib
	virtual/jpeg"
RDEPEND="${DEPEND}"
