# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/smokeqt/smokeqt-4.10.4.ebuild,v 1.5 2013/07/02 08:06:16 ago Exp $

EAPI=5

DECLARATIVE_REQUIRED="optional"
MULTIMEDIA_REQUIRED="optional"
QTHELP_REQUIRED="optional"
OPENGL_REQUIRED="optional"
KDE_REQUIRED="never"

inherit kde4-base

DESCRIPTION="Scripting Meta Object Kompiler Engine - Qt bindings"
KEYWORDS="amd64 ~arm ppc ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="debug +phonon qimageblitz qscintilla qwt webkit"

# Maybe make more of Qt optional?
DEPEND="
	$(add_kdebase_dep smokegen)
	dev-qt/qtcore:4
	dev-qt/qtdbus:4
	dev-qt/qtgui:4
	dev-qt/qtscript:4
	dev-qt/qtsql:4
	dev-qt/qtsvg:4
	dev-qt/qttest:4
	phonon? ( >=media-libs/phonon-4.4.3 )
	qimageblitz? ( >=media-libs/qimageblitz-0.0.4 )
	qscintilla? ( x11-libs/qscintilla:= )
	qwt? ( x11-libs/qwt:5 )
	webkit? ( dev-qt/qtwebkit:4 )
"
RDEPEND="${DEPEND}"

# Split in 4.7
add_blocker smoke

src_configure() {
	mycmakeargs=(
		-DDISABLE_Qt3Support=ON
		-DWITH_QT3_SUPPORT=OFF
		$(cmake-utils_use_disable declarative QtDeclarative)
		$(cmake-utils_use_disable multimedia QtMultimedia)
		$(cmake-utils_use_disable opengl QtOpenGL)
		$(cmake-utils_use_with phonon)
		$(cmake-utils_use_with qimageblitz QImageBlitz)
		$(cmake-utils_use_with qscintilla QScintilla)
		$(cmake-utils_use_disable qthelp QtHelp)
		$(cmake-utils_use_disable qwt Qwt5)
		$(cmake-utils_use_disable webkit QtWebKit)
	)
	kde4-base_src_configure
}
