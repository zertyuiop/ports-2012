# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/chromium/chromium-9999-r1.ebuild,v 1.201 2013/06/27 15:05:23 phajdan.jr Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} )

CHROMIUM_LANGS="am ar bg bn ca cs da de el en_GB es es_LA et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt_BR pt_PT ro ru sk sl sr
	sv sw ta te th tr uk vi zh_CN zh_TW"

inherit chromium eutils flag-o-matic multilib multiprocessing \
	pax-utils portability python-any-r1 subversion toolchain-funcs versionator virtualx

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="http://chromium.org/"
ESVN_REPO_URI="http://src.chromium.org/svn/trunk/src"

LICENSE="BSD"
SLOT="live"
KEYWORDS=""
IUSE="bindist cups gnome gnome-keyring gps kerberos pulseaudio selinux +system-ffmpeg system-sqlite tcmalloc"

# Native Client binaries are compiled with different set of flags, bug #452066.
QA_FLAGS_IGNORED=".*\.nexe"

# Native Client binaries may be stripped by the build system, which uses the
# right tools for it, bug #469144 .
QA_PRESTRIPPED=".*\.nexe"

RDEPEND=">=app-accessibility/speech-dispatcher-0.8:=
	app-arch/bzip2:=
	app-arch/snappy:=
	system-sqlite? ( dev-db/sqlite:3 )
	cups? (
		dev-libs/libgcrypt:=
		>=net-print/cups-1.3.11:=
	)
	>=dev-lang/v8-3.19.17:=
	=dev-lang/v8-3.19*
	>=dev-libs/elfutils-0.149
	dev-libs/expat:=
	>=dev-libs/icu-49.1.1-r1:=
	>=dev-libs/jsoncpp-0.5.0-r1:=
	>=dev-libs/libevent-1.4.13:=
	dev-libs/libxml2:=[icu]
	dev-libs/libxslt:=
	dev-libs/nspr:=
	>=dev-libs/nss-3.12.3:=
	dev-libs/protobuf:=
	dev-libs/re2:=
	gnome? ( >=gnome-base/gconf-2.24.0:= )
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.28.2:= )
	gps? ( >=sci-geosciences/gpsd-3.7:=[shm] )
	>=media-libs/alsa-lib-1.0.19
	media-libs/flac:=
	media-libs/harfbuzz:=[icu(+)]
	>=media-libs/libjpeg-turbo-1.2.0-r1:=
	media-libs/libpng:0=
	media-libs/libvpx:=
	>=media-libs/libwebp-0.2.0_rc1:=
	!arm? ( !x86? ( >=media-libs/mesa-9.1:=[gles2] ) )
	media-libs/opus:=
	media-libs/speex:=
	pulseaudio? ( media-sound/pulseaudio:= )
	system-ffmpeg? ( || (
		>=media-video/ffmpeg-1.0:=[opus]
		>=media-video/libav-9.5:=[opus]
	) )
	sys-apps/dbus:=
	sys-apps/pciutils:=
	sys-libs/zlib:=[minizip]
	virtual/udev
	virtual/libusb:1=
	x11-libs/gtk+:2=
	x11-libs/libXinerama:=
	x11-libs/libXScrnSaver:=
	x11-libs/libXtst:=
	kerberos? ( virtual/krb5 )
	selinux? ( sec-policy/selinux-chromium )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	!arm? (
		>=dev-lang/nacl-toolchain-newlib-0_p9093
		dev-lang/yasm
	)
	dev-lang/perl
	dev-perl/JSON
	dev-python/jinja
	dev-python/ply
	dev-python/simplejson
	>=dev-util/gperf-3.0.3
	dev-util/ninja
	sys-apps/hwids
	>=sys-devel/bison-2.4.3
	sys-devel/flex
	virtual/pkgconfig
	test? ( dev-python/pyftpdlib )"
RDEPEND+="
	!=www-client/chromium-9999
	x11-misc/xdg-utils
	virtual/ttf-fonts"

gclient_config() {
	einfo "gclient config -->"
	# Allow the user to keep their config if they know what they are doing.
	if ! grep -q KEEP .gclient; then
		cp -f "${FILESDIR}/dot-gclient" .gclient || die
	fi
	cat .gclient || die
}

gclient_sync() {
	einfo "gclient sync -->"
	[[ -n "${ESVN_UMASK}" ]] && eumask_push "${ESVN_UMASK}"
	# Only use a single job to prevent hangs.
	"${WORKDIR}/depot_tools/gclient" sync --nohooks --jobs=1 \
		--delete_unversioned_trees || die
	[[ -n "${ESVN_UMASK}" ]] && eumask_pop
}

gclient_runhooks() {
	# Run all hooks except gyp_chromium.
	einfo "gclient runhooks -->"
	cp src/DEPS src/DEPS.orig || die
	sed -e 's:"python", "src/build/gyp_chromium":"true":' -i src/DEPS || die
	"${WORKDIR}/depot_tools/gclient" runhooks
	local ret=$?
	mv src/DEPS.orig src/DEPS || die
	[[ ${ret} -eq 0 ]] || die "gclient runhooks failed"
}

src_unpack() {
	# First grab depot_tools.
	DEPOT_TOOLS_REPO="https://src.chromium.org/svn/trunk/tools/depot_tools"
	addwrite "${ESVN_STORE_DIR}"
	if subversion_wc_info "${DEPOT_TOOLS_REPO}"; then
		if [ "${ESVN_WC_URL}" != "${DEPOT_TOOLS_REPO}" ]; then
			einfo "Removing old (http) depot_tools ${ESVN_WC_PATH}"
			rm -rf "${ESVN_WC_PATH}" || die
		fi
	fi
	ESVN_REVISION= subversion_fetch "${DEPOT_TOOLS_REPO}"
	mv "${S}" "${WORKDIR}"/depot_tools || die

	cd "${ESVN_STORE_DIR}/${PN}" || die

	gclient_config
	gclient_sync

	# Disabled so that we do not download nacl toolchain.
	#gclient_runhooks

	# Remove any lingering nacl toolchain files.
	rm -rf src/native_client/toolchain/linux_x86_newlib

	subversion_wc_info

	cd src || die
	${PYTHON} build/util/lastchange.py -o build/util/LASTCHANGE || die
	${PYTHON} build/util/lastchange.py -s third_party/WebKit \
		-o build/util/LASTCHANGE.blink || die

	mkdir -p "${S}" || die
	einfo "Copying source to ${S}"
	rsync -rlpgo --exclude=".svn/" . "${S}" || die

	. chrome/VERSION
	elog "Installing/updating to version ${MAJOR}.${MINOR}.${BUILD}.${PATCH} (Developer Build ${ESVN_WC_REVISION})"
}

if ! has chromium_pkg_die ${EBUILD_DEATH_HOOKS}; then
	EBUILD_DEATH_HOOKS+=" chromium_pkg_die";
fi

pkg_setup() {
	if [[ "${SLOT}" == "0" ]]; then
		CHROMIUM_SUFFIX=""
	else
		CHROMIUM_SUFFIX="-${SLOT}"
	fi
	CHROMIUM_HOME="/usr/$(get_libdir)/chromium-browser${CHROMIUM_SUFFIX}"

	# Make sure the build system will use the right python, bug #344367.
	python-any-r1_pkg_setup

	chromium_suid_sandbox_check_kernel_config

	if use bindist && ! use system-ffmpeg; then
		elog "bindist enabled: H.264 video support will be disabled."
	fi
	if ! use bindist; then
		elog "bindist disabled: Resulting binaries may not be legal to re-distribute."
	fi
}

src_prepare() {
	if ! use arm; then
		mkdir -p out/Release/gen/sdk/toolchain || die
		# Do not preserve SELinux context, bug #460892 .
		cp -a --no-preserve=context /usr/$(get_libdir)/nacl-toolchain-newlib \
			out/Release/gen/sdk/toolchain/linux_x86_newlib || die
		touch out/Release/gen/sdk/toolchain/linux_x86_newlib/stamp.untar || die
	fi

	epatch "${FILESDIR}/${PN}-system-ffmpeg-r7.patch"

	epatch_user

	# Remove most bundled libraries. Some are still needed.
	find third_party -type f \! -iname '*.gyp*' \
		\! -path 'third_party/WebKit/*' \
		\! -path 'third_party/angle_dx11/*' \
		\! -path 'third_party/cacheinvalidation/*' \
		\! -path 'third_party/cld/*' \
		\! -path 'third_party/cros_system_api/*' \
		\! -path 'third_party/ffmpeg/*' \
		\! -path 'third_party/flot/*' \
		\! -path 'third_party/hunspell/*' \
		\! -path 'third_party/hyphen/*' \
		\! -path 'third_party/iccjpeg/*' \
		\! -path 'third_party/jstemplate/*' \
		\! -path 'third_party/khronos/*' \
		\! -path 'third_party/leveldatabase/*' \
		\! -path 'third_party/libjingle/*' \
		\! -path 'third_party/libphonenumber/*' \
		\! -path 'third_party/libsrtp/*' \
		\! -path 'third_party/libxml/chromium/*' \
		\! -path 'third_party/libXNVCtrl/*' \
		\! -path 'third_party/libyuv/*' \
		\! -path 'third_party/lss/*' \
		\! -path 'third_party/lzma_sdk/*' \
		\! -path 'third_party/mesa/*' \
		\! -path 'third_party/modp_b64/*' \
		\! -path 'third_party/mongoose/*' \
		\! -path 'third_party/mt19937ar/*' \
		\! -path 'third_party/npapi/*' \
		\! -path 'third_party/openmax/*' \
		\! -path 'third_party/ots/*' \
		\! -path 'third_party/pywebsocket/*' \
		\! -path 'third_party/qcms/*' \
		\! -path 'third_party/sfntly/*' \
		\! -path 'third_party/skia/*' \
		\! -path 'third_party/smhasher/*' \
		\! -path 'third_party/sqlite/*' \
		\! -path 'third_party/tcmalloc/*' \
		\! -path 'third_party/tlslite/*' \
		\! -path 'third_party/trace-viewer/*' \
		\! -path 'third_party/undoview/*' \
		\! -path 'third_party/usrsctp/*' \
		\! -path 'third_party/v8-i18n/*' \
		\! -path 'third_party/webdriver/*' \
		\! -path 'third_party/webrtc/*' \
		\! -path 'third_party/widevine/*' \
		\! -path 'third_party/x86inc/*' \
		\! -path 'third_party/zlib/google/*' \
		-delete || die

	local v8_bundled="$(chromium_bundled_v8_version)"
	local v8_installed="$(chromium_installed_v8_version)"
	einfo "V8 version: bundled - ${v8_bundled}; installed - ${v8_installed}"

	# Remove bundled v8.
	find v8 -type f \! -iname '*.gyp*' -delete || die
}

src_configure() {
	local myconf=""

	# Never tell the build system to "enable" SSE2, it has a few unexpected
	# additions, bug #336871.
	myconf+=" -Ddisable_sse2=1"

	# Optional tcmalloc. Note it causes problems with e.g. NVIDIA
	# drivers, bug #413637.
	myconf+=" $(gyp_use tcmalloc linux_use_tcmalloc)"

	# Disable glibc Native Client toolchain, we don't need it (bug #417019).
	myconf+=" -Ddisable_glibc=1"

	# TODO: also build with pnacl
	myconf+=" -Ddisable_pnacl=1"

	# It would be awkward for us to tar the toolchain and get it untarred again
	# during the build.
	myconf+=" -Ddisable_newlib_untar=1"

	# Make it possible to remove third_party/adobe.
	echo > "${T}/flapper_version.h" || die
	myconf+=" -Dflapper_version_h_file=${T}/flapper_version.h"

	# Use system-provided libraries.
	# TODO: use_system_hunspell (upstream changes needed).
	# TODO: use_system_libsrtp (bug #459932).
	# TODO: use_system_ssl (http://crbug.com/58087).
	# TODO: use_system_sqlite (http://crbug.com/22208).
	myconf+="
		-Duse_system_bzip2=1
		-Duse_system_flac=1
		-Duse_system_harfbuzz=1
		-Duse_system_icu=1
		-Duse_system_jsoncpp=1
		-Duse_system_libevent=1
		-Duse_system_libjpeg=1
		-Duse_system_libpng=1
		-Duse_system_libusb=1
		-Duse_system_libvpx=1
		-Duse_system_libwebp=1
		-Duse_system_libxml=1
		-Duse_system_libxslt=1
		-Duse_system_minizip=1
		-Duse_system_nspr=1
		-Duse_system_opus=1
		-Duse_system_protobuf=1
		-Duse_system_re2=1
		-Duse_system_snappy=1
		-Duse_system_speex=1
		-Duse_system_v8=1
		-Duse_system_xdg_utils=1
		-Duse_system_zlib=1
		$(gyp_use system-ffmpeg use_system_ffmpeg)"

	# TODO: Use system mesa on x86, bug #457130 .
	if ! use x86 && ! use arm; then
		myconf+="
			-Duse_system_mesa=1"
	fi

	# TODO: patch gyp so that this arm conditional is not needed.
	if ! use arm; then
		myconf+="
			-Duse_system_yasm=1"
	fi

	# TODO: re-enable on vp9 libvpx release (http://crbug.com/174287).
	myconf+="
		-Dmedia_use_libvpx=0"

	# Optional dependencies.
	# TODO: linux_link_kerberos, bug #381289.
	myconf+="
		$(gyp_use cups)
		$(gyp_use gnome use_gconf)
		$(gyp_use gnome-keyring use_gnome_keyring)
		$(gyp_use gnome-keyring linux_link_gnome_keyring)
		$(gyp_use gps linux_use_libgps)
		$(gyp_use gps linux_link_libgps)
		$(gyp_use kerberos)
		$(gyp_use pulseaudio)"

	if use system-sqlite; then
		elog "Enabling system sqlite. WebSQL - http://www.w3.org/TR/webdatabase/"
		elog "will not work. Please report sites broken by this"
		elog "to https://bugs.gentoo.org"
		myconf+="
			-Duse_system_sqlite=1
			-Denable_sql_database=0"
	fi

	# Use explicit library dependencies instead of dlopen.
	# This makes breakages easier to detect by revdep-rebuild.
	myconf+="
		-Dlinux_link_gsettings=1
		-Dlinux_link_libpci=1
		-Dlinux_link_libspeechd=1
		-Dlibspeechd_h_prefix=speech-dispatcher/"

	# TODO: use the file at run time instead of effectively compiling it in.
	myconf+="
		-Dusb_ids_path=/usr/share/misc/usb.ids"

	# Enable SUID sandbox.
	myconf+="
		-Dlinux_sandbox_path=${CHROMIUM_HOME}/chrome_sandbox
		-Dlinux_sandbox_chrome_path=${CHROMIUM_HOME}/chrome"

	# Never use bundled gold binary. Disable gold linker flags for now.
	myconf+="
		-Dlinux_use_gold_binary=0
		-Dlinux_use_gold_flags=0"

	# Always support proprietary codecs.
	myconf+=" -Dproprietary_codecs=1"

	if ! use bindist && ! use system-ffmpeg; then
		# Enable H.624 support in bundled ffmpeg.
		myconf+=" -Dffmpeg_branding=Chrome"
	fi

	# Set up Google API keys, see http://www.chromium.org/developers/how-tos/api-keys .
	# Note: these are for Gentoo use ONLY. For your own distribution,
	# please get your own set of keys. Feel free to contact chromium@gentoo.org
	# for more info.
	myconf+=" -Dgoogle_api_key=AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc
		-Dgoogle_default_client_id=329227923882.apps.googleusercontent.com
		-Dgoogle_default_client_secret=vgKG0NNv7GoDpbtoFNLxCUXu"

	local myarch="$(tc-arch)"
	if [[ $myarch = amd64 ]] ; then
		myconf+=" -Dtarget_arch=x64"
	elif [[ $myarch = x86 ]] ; then
		myconf+=" -Dtarget_arch=ia32"
	elif [[ $myarch = arm ]] ; then
		# TODO: re-enable NaCl (NativeClient).
		myconf+=" -Dtarget_arch=arm
			-Dsysroot=
			-Darmv7=0
			-Darm_neon=0
			-Ddisable_nacl=1"
	else
		die "Failed to determine target arch, got '$myarch'."
	fi

	# Make sure that -Werror doesn't get added to CFLAGS by the build system.
	# Depending on GCC version the warnings are different and we don't want
	# the build to fail because of that.
	myconf+=" -Dwerror="

	# Avoid CFLAGS problems, bug #352457, bug #390147.
	if ! use custom-cflags; then
		replace-flags "-Os" "-O2"
		strip-flags

		# Prevent linker from running out of address space, bug #471810 .
		if use x86; then
			filter-flags "-g*"
		fi
	fi

	# Make sure the build system will use the right tools, bug #340795.
	tc-export AR CC CXX RANLIB

	# Tools for building programs to be executed on the build system, bug #410883.
	tc-export_build_env BUILD_AR BUILD_CC BUILD_CXX

	# Tools for building programs to be executed on the build system, bug #410883.
	export AR_host=$(tc-getBUILD_AR)
	export CC_host=$(tc-getBUILD_CC)
	export CXX_host=$(tc-getBUILD_CXX)
	export LD_host=${CXX_host}

	build/linux/unbundle/replace_gyp_files.py ${myconf} || die
	egyp_chromium ${myconf} || die
}

src_compile() {
	# TODO: add media_unittests after fixing compile (bug #462546).
	local test_targets=""
	for x in base cacheinvalidation content crypto \
		googleurl gpu net printing sql; do
		test_targets+=" ${x}_unittests"
	done

	local ninja_targets="chrome chrome_sandbox chromedriver"
	if use test; then
		ninja_targets+=" $test_targets"
	fi

	# Even though ninja autodetects number of CPUs, we respect
	# user's options, for debugging with -j 1 or any other reason.
	ninja -C out/Release -v -j $(makeopts_jobs) ${ninja_targets} || die

	pax-mark m out/Release/chrome
	if use test; then
		for x in $test_targets; do
			pax-mark m out/Release/${x}
		done
	fi
}

src_test() {
	# For more info see bug #350349.
	local mylocale='en_US.utf8'
	if ! locale -a | grep -q "$mylocale"; then
		eerror "${PN} requires ${mylocale} locale for tests"
		eerror "Please read the following guides for more information:"
		eerror "  http://www.gentoo.org/doc/en/guide-localization.xml"
		eerror "  http://www.gentoo.org/doc/en/utf-8.xml"
		die "locale ${mylocale} is not supported"
	fi

	# For more info see bug #370957.
	if [[ $UID -eq 0 ]]; then
		die "Tests must be run as non-root. Please use FEATURES=userpriv."
	fi

	runtest() {
		local cmd=$1
		shift
		local filter="--gtest_filter=$(IFS=:; echo "-${*}")"
		einfo "${cmd}" "${filter}"
		LC_ALL="${mylocale}" VIRTUALX_COMMAND="${cmd}" virtualmake "${filter}"
	}

	local excluded_base_unittests=(
		"ICUStringConversionsTest.*" # bug #350347
		"MessagePumpLibeventTest.*" # bug #398591
		"TimeTest.JsTime" # bug #459614
	)
	runtest out/Release/base_unittests "${excluded_base_unittests[@]}"

	runtest out/Release/cacheinvalidation_unittests

	local excluded_content_unittests=(
		"RendererDateTimePickerTest.*" # bug #465452
	)
	runtest out/Release/content_unittests "${excluded_content_unittests[@]}"

	runtest out/Release/crypto_unittests
	runtest out/Release/googleurl_unittests
	runtest out/Release/gpu_unittests

	# TODO: add media_unittests after fixing compile (bug #462546).
	# runtest out/Release/media_unittests

	local excluded_net_unittests=(
		"NetUtilTest.IDNToUnicode*" # bug 361885
		"NetUtilTest.FormatUrl*" # see above
		"DnsConfigServiceTest.GetSystemConfig" # bug #394883
		"CertDatabaseNSSTest.ImportServerCert_SelfSigned" # bug #399269
		"CertDatabaseNSSTest.TrustIntermediateCa*" # http://crbug.com/224612
		"URLFetcher*" # bug #425764
		"HTTPSOCSPTest.*" # bug #426630
		"HTTPSEVCRLSetTest.*" # see above
		"HTTPSCRLSetTest.*" # see above
		"*SpdyFramerTest.BasicCompression*" # bug #465444
	)
	runtest out/Release/net_unittests "${excluded_net_unittests[@]}"

	runtest out/Release/printing_unittests

	local excluded_sql_unittests=(
		"SQLiteFeaturesTest.FTS2" # bug #461286
	)
	runtest out/Release/sql_unittests "${excluded_sql_unittests[@]}"
}

src_install() {
	exeinto "${CHROMIUM_HOME}"
	doexe out/Release/chrome || die

	doexe out/Release/chrome_sandbox || die
	fperms 4755 "${CHROMIUM_HOME}/chrome_sandbox"

	doexe out/Release/chromedriver || die

	if ! use arm; then
		doexe out/Release/nacl_helper{,_bootstrap} || die
		insinto "${CHROMIUM_HOME}"
		doins out/Release/nacl_irt_*.nexe || die
		doins out/Release/libppGoogleNaClPluginChrome.so || die
	fi

	newexe "${FILESDIR}"/chromium-launcher-r3.sh chromium-launcher.sh || die
	if [[ "${CHROMIUM_SUFFIX}" != "" ]]; then
		sed "s:chromium-browser:chromium-browser${CHROMIUM_SUFFIX}:g" \
			-i "${ED}"/"${CHROMIUM_HOME}"/chromium-launcher.sh || die
		sed "s:chromium.desktop:chromium${CHROMIUM_SUFFIX}.desktop:g" \
			-i "${ED}"/"${CHROMIUM_HOME}"/chromium-launcher.sh || die
		sed "s:plugins:plugins --user-data-dir=\${HOME}/.config/chromium${CHROMIUM_SUFFIX}:" \
			-i "${ED}"/"${CHROMIUM_HOME}"/chromium-launcher.sh || die
	fi

	# It is important that we name the target "chromium-browser",
	# xdg-utils expect it; bug #355517.
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser${CHROMIUM_SUFFIX} || die
	# keep the old symlink around for consistency
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium${CHROMIUM_SUFFIX} || die

	# Allow users to override command-line options, bug #357629.
	dodir /etc/chromium || die
	insinto /etc/chromium
	newins "${FILESDIR}/chromium.default" "default" || die

	pushd out/Release/locales > /dev/null || die
	chromium_remove_language_paks
	popd

	insinto "${CHROMIUM_HOME}"
	doins out/Release/*.pak || die

	doins -r out/Release/locales || die
	doins -r out/Release/resources || die

	newman out/Release/chrome.1 chromium${CHROMIUM_SUFFIX}.1 || die
	newman out/Release/chrome.1 chromium-browser${CHROMIUM_SUFFIX}.1 || die

	if ! use system-ffmpeg; then
		doexe out/Release/libffmpegsumo.so || die
	fi

	# Install icons and desktop entry.
	local branding size
	for size in 16 22 24 32 48 64 128 256 ; do
		case ${size} in
			16|32) branding="chrome/app/theme/default_100_percent/chromium" ;;
				*) branding="chrome/app/theme/chromium" ;;
		esac
		newicon -s ${size} "${branding}/product_logo_${size}.png" \
			chromium-browser${CHROMIUM_SUFFIX}.png
	done

	local mime_types="text/html;text/xml;application/xhtml+xml;"
	mime_types+="x-scheme-handler/http;x-scheme-handler/https;" # bug #360797
	mime_types+="x-scheme-handler/ftp;" # bug #412185
	mime_types+="x-scheme-handler/mailto;x-scheme-handler/webcal;" # bug #416393
	make_desktop_entry \
		chromium-browser${CHROMIUM_SUFFIX} \
		"Chromium${CHROMIUM_SUFFIX}" \
		chromium-browser${CHROMIUM_SUFFIX} \
		"Network;WebBrowser" \
		"MimeType=${mime_types}\nStartupWMClass=chromium-browser"
	sed -e "/^Exec/s/$/ %U/" -i "${ED}"/usr/share/applications/*.desktop || die

	# Install GNOME default application entry (bug #303100).
	if use gnome; then
		dodir /usr/share/gnome-control-center/default-apps || die
		insinto /usr/share/gnome-control-center/default-apps
		newins "${FILESDIR}"/chromium-browser.xml chromium-browser${CHROMIUM_SUFFIX}.xml || die
		if [[ "${CHROMIUM_SUFFIX}" != "" ]]; then
			sed "s:chromium-browser:chromium-browser${CHROMIUM_SUFFIX}:g" -i \
				"${ED}"/usr/share/gnome-control-center/default-apps/chromium-browser${CHROMIUM_SUFFIX}.xml
		fi
	fi
}
