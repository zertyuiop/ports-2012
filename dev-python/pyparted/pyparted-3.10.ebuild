# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyparted/pyparted-3.10.ebuild,v 1.2 2013/06/14 19:08:26 chutzpah Exp $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_1,3_2,3_3} )
inherit distutils-r1

DESCRIPTION="Python bindings for sys-block/parted"
HOMEPAGE="https://fedorahosted.org/pyparted/"
SRC_URI="https://fedorahosted.org/releases/p/y/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="test"

RDEPEND="
	>=sys-block/parted-3.1
	dev-python/decorator
	sys-libs/ncurses
"
DEPEND="
	${RDEPEND}
"
# test? ( dev-python/pychecker )

src_test() {
	ewarn "Test suite disabled until dev-python/pychecker"
	ewarn "is migrated to -r1.eclass"
}
