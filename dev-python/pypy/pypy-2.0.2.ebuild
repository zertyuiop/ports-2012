# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pypy/pypy-2.0.2.ebuild,v 1.3 2013/06/18 10:41:29 idella4 Exp $

EAPI=5

# XXX: test other implementations
PYTHON_COMPAT=( python2_7 pypy{1_8,1_9,2_0} )
inherit check-reqs eutils flag-o-matic multilib multiprocessing pax-utils python-any-r1 toolchain-funcs versionator

DESCRIPTION="A fast, compliant alternative implementation of the Python language"
HOMEPAGE="http://pypy.org/"
SRC_URI="mirror://bitbucket/pypy/pypy/downloads/${P}-src.tar.bz2"

LICENSE="MIT"
SLOT=$(get_version_component_range 1-2 ${PV})
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="bzip2 doc examples +jit ncurses sandbox shadowstack sqlite ssl +xml"

RDEPEND=">=sys-libs/zlib-1.1.3
	virtual/libffi
	virtual/libintl
	dev-libs/expat
	bzip2? ( app-arch/bzip2 )
	ncurses? ( sys-libs/ncurses )
	sqlite? ( dev-db/sqlite:3 )
	ssl? ( dev-libs/openssl )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}"
PDEPEND="app-admin/python-updater"

S="${WORKDIR}/${P}-src"

pkg_pretend() {
	CHECKREQS_MEMORY="2G"
	use amd64 && CHECKREQS_MEMORY="4G"
	check-reqs_pkg_pretend
#	if [[ ${MERGE_TYPE} != binary && "$(gcc-version)" == "4.8" ]]; then
#		die "PyPy does not build correctly with GCC 4.8"
#	fi
}

pkg_setup() {
	pkg_pretend
	python-any-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/1.9-scripts-location.patch"
	epatch "${FILESDIR}/1.9-distutils.unixccompiler.UnixCCompiler.runtime_library_dir_option.patch"
	epatch "${FILESDIR}/2.0.2-distutils-fix_handling_of_executables_and_flags.patch"
}

src_compile() {
	tc-export CC

	local args=(
		$(usex jit -Ojit -O2)
		$(usex shadowstack --gcrootfinder=shadowstack '')
		$(usex sandbox --sandbox '')

		--make-jobs=$(makeopts_jobs)

		pypy/goal/targetpypystandalone
	)

	# Avoid linking against libraries disabled by use flags
	local opts=(
		bzip2:bz2
		ncurses:_minimal_curses
		ssl:_ssl
	)

	local opt
	for opt in "${opts[@]}"; do
		local flag=${opt%:*}
		local mod=${opt#*:}

		args+=(
			$(usex ${flag} --withmod --withoutmod)-${mod}
		)
	done

	set -- "${PYTHON}" rpython/bin/rpython --batch "${args[@]}"
	echo -e "\033[1m${@}\033[0m"
	"${@}" || die "compile error"

	use doc && emake -C ${PN}/doc/ html
}

src_test() {
	PYTHONDONTWRITEBYTECODE="" "${PYTHON}" ./pypy/test_all.py --pypy=./pypy-c lib-python || die
}

src_install() {
	insinto "/usr/$(get_libdir)/pypy${SLOT}"
	doins -r include lib_pypy lib-python pypy-c
	fperms a+x ${INSDESTTREE}/pypy-c
	use jit && pax-mark m "${ED%/}${INSDESTTREE}/pypy-c"
	dosym ../$(get_libdir)/pypy${SLOT}/pypy-c /usr/bin/pypy-c${SLOT}
	dosym ../$(get_libdir)/pypy${SLOT}/include /usr/include/pypy${SLOT}
	dodoc README.rst

	if ! use sqlite; then
		rm -fr "${ED%/}${INSDESTTREE}"/lib-python/{2.7,modified-2.7}/sqlite3
		rm -f "${ED%/}${INSDESTTREE}"/lib_pypy/_sqlite3.py
	fi

	python_export pypy-c${SLOT} EPYTHON PYTHON PYTHON_SITEDIR

	# if not using a cross-compiler, use the fresh binary
	if ! tc-is-cross-compiler; then
		local PYTHON=${ED%/}${INSDESTTREE}/pypy-c
	fi

	runpython() {
		PYTHONPATH="${ED%/}${INSDESTTREE}/lib_pypy:${ED%/}${INSDESTTREE}/lib-python/2.7" \
			"${PYTHON}" "$@"
	}

	# Generate Grammar and PatternGrammar pickles.
	runpython -c "import lib2to3.pygram, lib2to3.patcomp; lib2to3.patcomp.PatternCompiler()" \
		|| die "Generation of Grammar and PatternGrammar pickles failed"

	# Generate cffi cache
	runpython -c "import _curses" || die "Failed to import _curses"
	if use sqlite; then
		runpython -c "import _sqlite3" || die "Failed to import _sqlite3"
	fi

	# compile the installed modules
	python_optimize "${ED%/}${INSDESTTREE}"

	# Install docs
	use doc && dohtml -r ${PN}/doc/_build/html/

	echo "EPYTHON='${EPYTHON}'" > epython.py
	python_domodule epython.py
}
