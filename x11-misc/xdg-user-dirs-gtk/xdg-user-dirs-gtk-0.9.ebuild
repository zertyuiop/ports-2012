# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xdg-user-dirs-gtk/xdg-user-dirs-gtk-0.9.ebuild,v 1.1 2012/04/06 03:27:00 tetromino Exp $

EAPI=4
inherit gnome.org

DESCRIPTION="xdg-user-dirs-gtk integrates xdg-user-dirs into the Gnome desktop and Gtk+ applications"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/xdg-user-dirs"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=x11-misc/xdg-user-dirs-0.13
	x11-libs/gtk+:3"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	dev-util/pkgconfig"

src_prepare() {
	sed -i \
		-e '/Encoding/d' \
		-e 's:OnlyShowIn=GNOME;LXDE;Unity;:NotShowIn=KDE;:' \
		user-dirs-update-gtk.desktop.in || die
}

pkg_postinst() {
	elog
	elog " This package tries to automatically use some sensible default "
	elog " directories for your documents, music, video and other stuff. "
	elog
	elog " If you want to change those directories to your needs, see "
	elog " the settings in ~/.config/user-dir.dirs "
	elog
}