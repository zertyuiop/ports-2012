# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_DEPEND="python? ( <<>> )"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit autotools flag-o-matic linux-info pam python

DESCRIPTION="eCryptfs userspace utilities"
HOMEPAGE="https://launchpad.net/ecryptfs"
SRC_URI="http://launchpad.net/ecryptfs/trunk/${PV}/+download/${PN}_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc gpg gtk openssl pam pkcs11 python suid tpm"

RDEPEND=">=dev-libs/libgcrypt-1.2.0
	dev-libs/nss
	>=sys-apps/keyutils-1.0
	gpg? ( app-crypt/gpgme )
	gtk? ( x11-libs/gtk+:2 )
	openssl? ( >=dev-libs/openssl-0.9.7 )
	pam? ( sys-libs/pam )
	pkcs11? (
		>=dev-libs/openssl-0.9.7
		>=dev-libs/pkcs11-helper-1.04
	)
	tpm? ( app-crypt/trousers )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.41.0
	sys-devel/gettext
	virtual/pkgconfig
	python? ( dev-lang/swig )"

pkg_setup() {
	if use python; then
		python_pkg_setup
	fi

	CONFIG_CHECK="~ECRYPT_FS"
	linux-info_pkg_setup
}

src_prepare() {
	if use python; then
		python_clean_py-compile_files
	fi

	# Python bindings are built/installed manually.
	sed -e "/SUBDIRS =/s/ libecryptfs-swig//" -i src/Makefile.am || die "sed failed"

	eautoreconf
}

src_configure() {
	append-flags -D_FILE_OFFSET_BITS=64

	econf \
		--docdir="/usr/share/doc/${PF}" \
		--enable-nss \
		--with-pamdir=$(getpam_mod_dir) \
		$(use_enable doc docs) \
		$(use_enable gpg) \
		$(use_enable gtk gui) \
		$(use_enable openssl) \
		$(use_enable pam) \
		$(use_enable pkcs11 pkcs11-helper) \
		$(use_enable python pywrap) \
		$(use_enable tpm tspi)
}

src_compile() {
	default

	if use python; then
		python_copy_sources src/libecryptfs-swig
		building() {
			emake \
				PYTHON="$(PYTHON)" \
				PYTHON_CPPFLAGS="-I$(python_get_includedir)" \
				PYTHON_LDFLAGS="-L$(python_get_libdir) $(python_get_library -l)" \
				PYTHON_SITE_PKG="$(python_get_sitedir)" \
				PYTHON_VERSION="$(python_get_version)" \
				SWIG_PYTHON_CPPFLAGS="-I$(python_get_includedir)" \
				pyexecdir="$(python_get_sitedir)" \
				pythondir="$(python_get_sitedir)"
		}
		python_execute_function -s --source-dir src/libecryptfs-swig building
	fi
}

src_install(){
	emake DESTDIR="${D}" install

	if use python; then
		installation() {
			emake \
				DESTDIR="${D}" \
				PYTHON="$(PYTHON)" \
				PYTHON_CPPFLAGS="-I$(python_get_includedir)" \
				PYTHON_LDFLAGS="-L$(python_get_libdir) $(python_get_library -l)" \
				PYTHON_SITE_PKG="$(python_get_sitedir)" \
				PYTHON_VERSION="$(python_get_version)" \
				SWIG_PYTHON_CPPFLAGS="-I$(python_get_includedir)" \
				pyexecdir="$(python_get_sitedir)" \
				pythondir="$(python_get_sitedir)" \
				install || return 1
			echo "ecryptfs-utils" > "${ED}$(python_get_sitedir)/ecryptfs-utils.pth"
		}
		python_execute_function -s --source-dir src/libecryptfs-swig installation

		python_clean_installation_image
	fi

	use suid && fperms u+s /sbin/mount.ecryptfs_private

	find "${ED}" -name "*.la" -delete
}

pkg_postinst() {
	if use python; then
		python_mod_optimize ecryptfs-utils
	fi

	if use suid; then
		ewarn
		ewarn "You have chosen to install ${PN} with the binary setuid root. This"
		ewarn "means that if there are any undetected vulnerabilities in the binary,"
		ewarn "then local users may be able to gain root access on your machine."
		ewarn
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup ecryptfs-utils
	fi
}