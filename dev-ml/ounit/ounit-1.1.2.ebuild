# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ml/ounit/ounit-1.1.2.ebuild,v 1.1 2012/06/12 12:42:34 aballier Exp $

EAPI="3"

OASIS_BUILD_DOCS=1

inherit oasis

DESCRIPTION="Unit testing framework for OCaml"
HOMEPAGE="http://ounit.forge.ocamlcore.org/"
SRC_URI="http://forge.ocamlcore.org/frs/download.php/886/${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
DEPEND=""
RDEPEND="${DEPEND}"
IUSE=""

DOCS=( "README.txt" "AUTHORS.txt" "changelog" )