# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/grilo-plugins/grilo-plugins-0.2.8.ebuild,v 1.1 2013/05/26 11:35:36 pacho Exp $

EAPI="5"
GCONF_DEBUG="no" # --enable-debug only changes CFLAGS
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="A framework for easy media discovery and browsing"
HOMEPAGE="https://live.gnome.org/Grilo"

LICENSE="LGPL-2.1+"
SLOT="0.2"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="daap +dvd flickr gnome-online-accounts tracker upnp-av +vimeo +youtube"

RDEPEND="
	>=dev-libs/glib-2.28:2
	>=media-libs/grilo-0.2.6:${SLOT}[network]

	dev-libs/gmime:2.6
	dev-libs/json-glib
	dev-libs/libxml2:2
	dev-db/sqlite:3

	daap? ( >=net-libs/libdmapsharing-2.9.12:3.0 )
	dvd? ( >=dev-libs/totem-pl-parser-3.4.1 )
	flickr? ( net-libs/liboauth )
	gnome-online-accounts? ( >=net-libs/gnome-online-accounts-3.7.1 )
	tracker? ( >=app-misc/tracker-0.10.5:= )
	youtube? (
		>=dev-libs/libgdata-0.9.1
		>=media-libs/libquvi-0.4.0 )
	upnp-av? (
		net-libs/gssdp
		>=net-libs/gupnp-0.13
		>=net-libs/gupnp-av-0.5 )
	vimeo? (
		dev-libs/libgcrypt
		>=media-libs/libquvi-0.4.0 )
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.5
	app-text/gnome-doc-utils
	>=dev-util/intltool-0.40.0
	virtual/pkgconfig
"

src_configure() {
	local myconf
	# --enable-debug only changes CFLAGS, useless for us
	myconf="${myconf}
		--disable-static
		--disable-debug
		--disable-uninstalled"

	# Plugins
	# shoutcast seems to be broken
	myconf="${myconf}
		--enable-bliptv
		--enable-apple-trailers
		--enable-bookmarks
		--enable-filesystem
		--enable-gravatar
		--enable-jamendo
		--enable-lastfm-albumart
		--enable-localmetadata
		--enable-magnatune
		--enable-metadata-store
		--enable-podcasts
		--enable-raitv
		--disable-shoutcast
		--enable-tmdb
		$(use_enable daap dmap)
		$(use_enable dvd optical-media)
		$(use_enable flickr)
		$(use_enable gnome-online-accounts goa)
		$(use_enable tracker)
		$(use_enable upnp-av upnp)
		$(use_enable vimeo)
		$(use_enable youtube)"

	gnome2_src_configure ${myconf}
}
