# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/thunar-volman/thunar-volman-0.8.0.ebuild,v 1.2 2012/05/04 07:39:29 ssuominen Exp $

EAPI=4
inherit xfconf

DESCRIPTION="Daemon that enforces volume-related policies"
HOMEPAGE="http://goodies.xfce.org/projects/thunar-plugins/thunar-volman"
SRC_URI="mirror://xfce/src/apps/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="debug libnotify"

COMMON_DEPEND=">=dev-libs/glib-2.20
	|| ( >=sys-fs/udev-171-r5[gudev] <sys-fs/udev-171[extras] )
	>=x11-libs/gtk+-2.24:2
	>=xfce-base/exo-0.8
	>=xfce-base/libxfce4ui-4.10
	>=xfce-base/libxfce4util-4.10
	>=xfce-base/xfconf-4.10
	libnotify? ( >=x11-libs/libnotify-0.7 )"
RDEPEND="${COMMON_DEPEND}
	>=xfce-base/thunar-1.4[udev]"
DEPEND="${COMMON_DEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

pkg_setup() {
	XFCONF=(
		$(use_enable libnotify notifications)
		$(xfconf_use_debug)
		)

	DOCS=( AUTHORS ChangeLog NEWS README THANKS )
}