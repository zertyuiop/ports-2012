# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
GCONF_DEBUG="yes"

inherit mate multilib

DESCRIPTION="Fork of bluez-gnome focused on integration with MATE"
HOMEPAGE="http://mate-desktop.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="doc +introspection test"

COMMON_DEPEND="dev-libs/glib:2
	x11-libs/gtk+:2
	>=x11-libs/libmatenotify-1.2.0
	>=mate-base/mate-conf-1.2.1
	dev-libs/dbus-glib
	dev-libs/libunique:1"

RDEPEND="${COMMON_DEPEND}
	net-wireless/bluez
	app-mobilephone/obexd
	virtual/udev
	introspection? ( dev-libs/gobject-introspection )"

DEPEND="${COMMON_DEPEND}
	!net-wireless/bluez-gnome
	app-text/docbook-xml-dtd:4.1.2
	>=app-text/mate-doc-utils-1.2.1
	app-text/scrollkeeper
	dev-libs/libxml2
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext
	x11-libs/libX11
	x11-libs/libXi
	x11-proto/xproto
	doc? ( dev-util/gtk-doc )
	>=mate-base/mate-common-1.2.2
	dev-util/gtk-doc-am"

# Tests are not ready to pass with docs enabled, upstream bug #573392
REQUIRED_USE="test? ( !doc )"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable introspection)
		--disable-moblin
		--disable-desktop-update
		--disable-icon-update
		--disable-schemas-compile"

	DOCS="AUTHORS README NEWS ChangeLog"

	enewgroup plugdev
}

src_install() {
	mate_src_install

	insinto /$(get_libdir)/udev/rules.d
	doins "${FILESDIR}"/80-mate-rfkill.rules
}

pkg_postinst() {
	mate_pkg_postinst

	elog "Don't forget to add yourself to the plugdev group "
	elog "if you want to be able to control bluetooth transmitter."
}
