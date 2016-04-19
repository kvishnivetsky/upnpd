include $(top_srcdir)/config/project.am
include $(top_srcdir)/config/utility.am

bin_SCRIPTS = $(shell find bin)

@PACKAGE@_confdir = $(sysconfdir)
nobase_@PACKAGE@_conf_DATA = $(shell find upnpd -name *.xml)

@PACKAGE@_EXTRA_DIST = \
    $(bin_SCRIPTS) \
    $(nobase_@PACKAGE@_conf_DATA)

install-@PACKAGE@_confDATA:
	for f in $(@PACKAGE@_confDATA); do echo $f; /usr/bin/install -c -m 644 $f $(@PACKAGE@_confdir); done;
