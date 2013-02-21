#
#	RPM spec file for the Embedthis Appweb HTTP web server
#
Summary: ${settings.title} -- Embeddable HTTP Web Server
Name: ${settings.product}
Version: ${settings.version}
Release: ${settings.buildNumber}
License: Dual GPL/commercial
Group: Applications/Internet
URL: http://appwebserver.org
Distribution: Embedthis
Vendor: Embedthis Software
BuildRoot: ${prefixes.rpm}/BUILDROOT/${settings.product}-${settings.version}-${settings.buildNumber}.${platform.mappedCpu}
AutoReqProv: no

%description
Embedthis Appweb is the fast, little web server.

%prep

%build

%install
    if [ -x "${prefixes.vapp}/bin/uninstall" ] ; then
        appweb_HEADLESS=1 "${prefixes.vapp}/bin/uninstall" </dev/null 2>&1 >/dev/null
    fi
    mkdir -p ${prefixes.rpm}/BUILDROOT/${settings.product}-${settings.version}-${settings.buildNumber}.${platform.mappedCpu}
    cp -r ${prefixes.content}/* ${prefixes.rpm}/BUILDROOT/${settings.product}-${settings.version}-${settings.buildNumber}.${platform.mappedCpu}

%clean

%files -f binFiles.txt

%post
if [ -x /usr/bin/chcon ] ; then 
	sestatus | grep enabled >/dev/null 2>&1
	if [ $? = 0 ] ; then
		for f in ${prefixes.vapp}/bin/*.so ; do
			chcon /usr/bin/chcon -t texrel_shlib_t $f
		done
	fi
fi
ldconfig -n ${prefixes.vapp}/bin

%preun

%postun
