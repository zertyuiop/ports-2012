# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/django-annoying/django-annoying-0.7.7.ebuild,v 1.1 2013/05/18 13:14:46 idella4 Exp $

EAPI=5
PYTHON_COMPAT=( python2_5 python2_6 python2_7 )

inherit distutils-r1

DESCRIPTION="This is django application that try to eliminate annoying things in Django framework."
HOMEPAGE="http://bitbucket.org/offline/django-annoying/wiki/Home"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="dev-python/django[${PYTHON_USEDEP}]"
