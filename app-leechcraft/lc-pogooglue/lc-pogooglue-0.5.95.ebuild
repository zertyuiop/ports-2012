# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-leechcraft/lc-pogooglue/lc-pogooglue-0.5.95.ebuild,v 1.1 2013/05/02 15:34:32 pinkbyte Exp $

EAPI="4"

inherit leechcraft

DESCRIPTION="Provides searching with Google to other LeechCraft plugins"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="~app-leechcraft/lc-core-${PV}"
RDEPEND="${DEPEND}"
