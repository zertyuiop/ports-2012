# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-tseng/xf86-video-tseng-1.2.5-r1.ebuild,v 1.1 2013/03/12 16:38:13 chithanh Exp $

EAPI=5
inherit xorg-2

DESCRIPTION="Tseng Labs video driver"
KEYWORDS="~amd64 ~ia64 ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE=""

RDEPEND=">=x11-base/xorg-server-1.0.99"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-remove-mibstore_h.patch
)
