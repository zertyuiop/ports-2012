# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/pinta/pinta-1.3.ebuild,v 1.2 2012/05/05 07:00:23 jdhore Exp $

EAPI=4

inherit fdo-mime multilib mono

DESCRIPTION="Simple Painting for Gtk"
HOMEPAGE="http://pinta-project.com"
SRC_URI="mirror://github/PintaProject/Pinta/${P}.tar.gz"

LICENSE="MIT CCPL-Attribution-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="jpeg tiff"

COMMON_DEPEND="dev-dotnet/atk-sharp:2
	dev-dotnet/gdk-sharp:2
	dev-dotnet/glib-sharp:2
	dev-dotnet/gtk-sharp:2
	dev-dotnet/mono-addins[gtk]
	dev-dotnet/pango-sharp:2
	dev-lang/mono"
RDEPEND="${COMMON_DEPEND}
	x11-libs/cairo[X]
	x11-libs/gdk-pixbuf[X,jpeg=,tiff=]
	x11-themes/gnome-icon-theme"
DEPEND="${COMMON_DEPEND}
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext"

src_prepare() {
	sed \
		-e "s/lib/$(get_libdir)/" \
		-i pinta.in || die
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}