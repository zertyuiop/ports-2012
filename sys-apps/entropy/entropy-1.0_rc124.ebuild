# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2"
PYTHON_USE_WITH="sqlite"
inherit eutils python user

DESCRIPTION="Entropy Package Manager foundation library"
HOMEPAGE="http://www.sabayon.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

IUSE=""
SRC_URI="mirror://sabayon/${CATEGORY}/${P}.tar.bz2"

RDEPEND="dev-db/sqlite[soundex]
	net-misc/rsync
	sys-apps/diffutils
	sys-apps/sandbox
	>=sys-apps/portage-2.1.9
	sys-devel/gettext"
DEPEND="${RDEPEND}
	dev-util/intltool"

REPO_CONFPATH="${ROOT}/etc/entropy/repositories.conf"
REPO_D_CONFPATH="${ROOT}/etc/entropy/repositories.conf.d"
ENTROPY_CACHEDIR="${ROOT}/var/lib/entropy/caches"

pkg_setup() {
	# Can:
	# - update repos
	# - update security advisories
	# - handle on-disk cache (atm)
	enewgroup entropy || die "failed to create entropy group"
	# Create unprivileged entropy user
	enewgroup entropy-nopriv || die "failed to create entropy-nopriv group"
	enewuser entropy-nopriv -1 -1 -1 entropy-nopriv || die "failed to create entropy-nopriv user"
}

src_compile() {
	cd "${S}"/client/po || die
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="usr/lib" entropy-install || die "make install failed"
	cd "${S}"/client/po || die
	emake DESTDIR="${D}" LIBDIR="usr/lib" install || die "make install failed"
}

pkg_postinst() {
	for ex_conf in "${REPO_D_CONFPATH}"/_entropy_sabayon-limbo.example; do
		real_conf="${ex_conf%.example}"
		if [ -f "${real_conf}" ] || [ -f "${real_conf/_}" ]; then
			# skip installation then
			continue
		fi
		elog "Installing: ${real_conf}"
		cp "${ex_conf}" "${real_conf}" -p
	done

	# Copy config file over
	if [ -f "${REPO_CONFPATH}.example" ] && [ ! -f "${REPO_CONFPATH}" ]; then
		elog "Copying ${REPO_CONFPATH}.example over to ${REPO_CONFPATH}"
		cp "${REPO_CONFPATH}.example" "${REPO_CONFPATH}" -p
	fi

	if [ -d "${ENTROPY_CACHEDIR}" ]; then
		einfo "Purging current Entropy cache"
		rm -rf "${ENTROPY_CACHEDIR}"/*
	fi

	# Fixup Entropy Resources Lock, and /etc/entropy/packages
	# files permissions. This fixes unprivileged Entropy Library usage
	local res_file="${ROOT}"/var/lib/entropy/client/database/*/.using_resources
	if [ -f "${res_file}" ]; then
		chown root:entropy "${res_file}"
		chmod g+rw "${res_file}"
		chmod o+r "${res_file}"
	fi
	local pkg_files="package.mask package.unmask package.mask.d package.unmask.d"
	local pkg_file
	for pkg_file in ${pkg_files}; do
		pkg_file="${ROOT}/etc/entropy/packages/${pkg_file}"
		recursive=""
		if [ -d "${pkg_file}" ]; then
			recursive="-R"
		fi
		if [ -e "${pkg_file}" ]; then
			chown ${recursive} root:entropy "${pkg_file}"
			chmod ${recursive} go+r "${pkg_file}"
		fi
	done

	# Setup Entropy Library directories ownership
	chown -R root:entropy "${ROOT}/var/tmp/entropy"
	chown root:entropy "${ROOT}/var/lib/entropy" # no recursion
	chown root:entropy "${ROOT}/var/lib/entropy/client/packages" # no recursion
	chown root:entropy "${ROOT}/var/log/entropy" # no recursion

	python_mod_optimize "/usr/lib/entropy/lib/entropy"

	echo
	elog "If you want to enable Entropy packages delta download support, please"
	elog "install dev-util/bsdiff."
	echo
}

pkg_postrm() {
	python_mod_cleanup "/usr/lib/entropy/lib/entropy"
}
