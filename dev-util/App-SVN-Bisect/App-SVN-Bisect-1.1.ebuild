# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/App-SVN-Bisect/App-SVN-Bisect-1.1.ebuild,v 1.1 2012/02/22 03:55:22 floppym Exp $

EAPI="4"

MODULE_AUTHOR="INFINOID"

inherit perl-module

DESCRIPTION="Binary search through svn revisions"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/perl
	dev-perl/YAML-Syck
	dev-perl/IO-All
	dev-vcs/subversion"
DEPEND="${RDEPEND}
	virtual/perl-Module-Build
	test? ( dev-perl/Test-Exception
		dev-perl/Test-Output
		dev-perl/Test-Pod
		dev-perl/Test-Pod-Coverage )"

SRC_TEST="do"