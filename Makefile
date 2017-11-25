ARCHS = armv7 arm64
BUNDLE_NAME = xyz.xninja.dopesettings
xyz.xninja.dopesettings_INSTALL_PATH = /private/var/mobile/Library/Application Support


include ~/theos/makefiles/common.mk
include ~/theos/makefiles/bundle.mk


TWEAK_NAME = DopeSettings
DopeSettings_FILES = Tweak.xm
DopeSettings_FRAMEWORKS = UIKit

include ~/theos/makefiles/tweak.mk

after-install::
	install.exec "killall -9 Preferences"
