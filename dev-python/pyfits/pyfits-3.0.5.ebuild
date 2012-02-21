# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyfits/pyfits-3.0.5.ebuild,v 1.1 2012/02/16 10:04:42 xarthisius Exp $

EAPI=4
SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND="*:2.6"

inherit distutils eutils

DESCRIPTION="Provides an interface to FITS formatted files under python"
HOMEPAGE="http://www.stsci.edu/resources/software_hardware/pyfits http://pypi.python.org/pypi/pyfits"
SRC_URI="mirror://pypi/p/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-fbsd"
IUSE="test"

RDEPEND="dev-python/numpy
	dev-python/setuptools"
DEPEND="${RDEPEND}
	dev-python/stsci-distutils
	dev-python/d2to1
	test? ( dev-python/nose )"

src_prepare() {
	sed -e 's/Exception, e/Exception as e/g' \
		-i lib/pyfits/{hdu/base.py,_release.py,tests/test_core.py} || die
	epatch "${FILESDIR}"/${PN}-3.0.4-tests_python3.patch
	distutils_src_prepare
}

src_test() {
	testing() {
		local t
		for t in lib/${PN}/tests/test_*.py; do
			PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib*)"  "$(PYTHON)" "${t}" || die "${t} failed with Python ${PYTHON_ABI}"
		done
	}
	python_execute_function testing
}