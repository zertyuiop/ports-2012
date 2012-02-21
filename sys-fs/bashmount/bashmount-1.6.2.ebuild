# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/bashmount/bashmount-1.6.2.ebuild,v 1.1 2012/02/20 11:08:52 ssuominen Exp $

EAPI=4

DESCRIPTION="A bash script that uses udisks to handle removable devices without dependencies on any GUI"
HOMEPAGE="http://sourceforge.net/projects/bashmount/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="app-shells/bash
	sys-apps/dbus
	sys-fs/udisks"
DEPEND=""

src_install() {
	dobin ${PN}
	insinto /etc
	doins ${PN}.conf
	doman ${PN}.1
	dodoc NEWS
}