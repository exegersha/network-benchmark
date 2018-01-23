##########################################################################  
DISTREL = output

ZIPREL = $(DISTREL)
PKGREL = $(DISTREL)

BAMBOODIR = bamboo
APPSOURCEDIR = source
BUILDDIR = build
TARGET = target

NATIVEDEVREL  = $(DISTREL)/rootfs/Linux86_dev.OBJ/root/nvram/incoming
NATIVEDEVPKG  = $(NATIVEDEVREL)/dev.zip
NATIVETICKLER = $(DISTREL)/application/Linux86_dev.OBJ/root/bin/plethora  tickle-plugin-installer

ifdef DEVPASSWORD
    USERPASS = rokudev:$(DEVPASSWORD)
else
    USERPASS = rokudev
endif

ifndef ZIP_EXCLUDE
	ZIP_EXCLUDE =
	# exclude hidden files (name starting with .)
	ZIP_EXCLUDE += -x .\*
	# exclude files with name ending with ~
	ZIP_EXCLUDE += -x \*~
	ZIP_EXCLUDE += -x \*.pkg
	ZIP_EXCLUDE += -x Makefile
	ZIP_EXCLUDE += -x app.mk
	ZIP_EXCLUDE += -x build\*
	ZIP_EXCLUDE += -x docs\*
	ZIP_EXCLUDE += -x output\*
	ZIP_EXCLUDE += -x README.md
	ZIP_EXCLUDE += -x bamboo\*
	ZIP_EXCLUDE += -x \*
	ZIP_EXCLUDE += -x storeassets\*
	ZIP_EXCLUDE += -x *.DS_Store*
	ZIP_EXCLUDE += -x *.git*
endif

HTTPSTATUS = $(shell curl --silent --write-out "\n%{http_code}\n" $(ROKU_DEV_TARGET))


build: setTestEnv $(APPNAME)

buildTest: remove clearTemp setTestEnv install
buildStaging: remove clearTemp setStagingEnv install
buildProduction: remove clearTemp setProductionEnv install

quickBuildTest: clearTemp setTestEnv $(APPNAME)
quickBuildStaging: clearTemp setStagingEnv $(APPNAME)
quickBuildProduction: clearTemp setProductionEnv $(APPNAME)

clearTemp:
	rm -rf $(DISTREL)/temp; \
	mkdir -p $(DISTREL)/temp; \
	chmod 755 $(DISTREL)/temp; \

setTestEnv:	
	cp -R $(TARGET)/test/ $(DISTREL)/temp/data/; \

setStagingEnv:
	cp -R $(TARGET)/staging/ $(DISTREL)/temp/data/; \

setProductionEnv:
	cp -R $(TARGET)/production/ $(DISTREL)/temp/data/; \

$(APPNAME): manifest
	@echo "*** Creating $(APPNAME).zip ***"

	@echo "  >> removing old application zip $(ZIPREL)/$(APPNAME).zip"
	@if [ -e "$(ZIPREL)/$(APPNAME).zip" ]; \
	then \
		rm  $(ZIPREL)/$(APPNAME).zip; \
	fi

	cp manifest $(DISTREL)/temp/; \
	cp -R resources/ $(DISTREL)/temp/; \
	cp -R src/ $(DISTREL)/temp/; \

	cd $(DISTREL)/temp ; zip -r $(APPNAME).zip .
	cp $(DISTREL)/temp/$(APPNAME).zip $(DISTREL)/$(APPNAME).zip; \
	rm -rf $(DISTREL)/temp; \

bambooBuilds: bambooTest bambooStaging bambooProduction

bambooTest: clearTemp setTestEnv $(APPNAME)
	@if [ ! -d $(BAMBOODIR) ]; \
	then \
		mkdir -p $(BAMBOODIR); \
	fi
	cp $(ZIPREL)/$(APPNAME).zip $(BAMBOODIR)/$(APPNAME)_test.zip; \

bambooStaging: clearTemp setStagingEnv $(APPNAME)
	@if [ ! -d $(BAMBOODIR) ]; \
	then \
		mkdir -p $(BAMBOODIR); \
	fi
	cp $(ZIPREL)/$(APPNAME).zip $(BAMBOODIR)/$(APPNAME)_staging.zip; \

bambooProduction: clearTemp setProductionEnv $(APPNAME)
	@if [ ! -d $(BAMBOODIR) ]; \
	then \
		mkdir -p $(BAMBOODIR); \
	fi
	cp $(ZIPREL)/$(APPNAME).zip $(BAMBOODIR)/$(APPNAME)_prod.zip; \

install: $(APPNAME)
	@echo "Installing $(APPNAME) to host $(ROKU_DEV_TARGET)"
	@if [ "$(HTTPSTATUS)" == " 401" ]; \
	then \
		curl --user $(USERPASS) --digest -s -S -F "mysubmit=Install" -F "archive=@$(ZIPREL)/$(APPNAME).zip" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[[" ; \
	else \
		curl -s -S -F "mysubmit=Install" -F "archive=@$(ZIPREL)/$(APPNAME).zip" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[[" ; \
	fi

deeplinkMovie:
	curl -d '' 'http://$(ROKU_DEV_TARGET):8060/launch/dev?contentID=83330&MediaType=movie'

deeplinkShow:
	curl -d '' 'http://$(ROKU_DEV_TARGET):8060/launch/dev?contentID=83458&MediaType=series'

deeplinkEpisode:
	curl -d '' 'http://$(ROKU_DEV_TARGET):8060/launch/dev?contentID=83460&MediaType=episode'

pkgTest: buildTest pkg
pkgStaging: buildStaging pkg
pkgProduction: buildProduction pkg

pkg: 
	@echo "*** Creating Package ***"

	@echo "  >> creating destination directory $(PKGREL)"	
	@if [ ! -d $(PKGREL) ]; \
	then \
		mkdir -p $(PKGREL); \
	fi

	@echo "  >> setting directory permissions for $(PKGREL)"
	@if [ ! -w $(PKGREL) ]; \
	then \
		chmod 755 $(PKGREL); \
	fi

	@echo "Packaging  $(APPSRC)/$(APPNAME) on host $(ROKU_DEV_TARGET)"
	@if [ "$(HTTPSTATUS)" == " 401" ]; \
	then \
		read -p "Password: " REPLY ; echo $$REPLY | xargs -i curl --user $(USERPASS) --digest -s -S -Fmysubmit=Package -Fapp_name=$(APPNAME)/$(VERSION) -Fpasswd={} -Fpkg_time=`expr \`date +%s\` \* 1000` "http://$(ROKU_DEV_TARGET)/plugin_package" | grep '^<tr><td><font face="Courier"><a' | sed 's/.*href=\"\([^\"]*\)\".*/\1/' | sed 's#pkgs//##' | xargs -i curl --user $(USERPASS) --digest -s -S -o $(PKGREL)/$(APPNAME)_`date +%F-%T`.pkg http://$(ROKU_DEV_TARGET)/pkgs/{} ; \
	else \
		read -p "Password: " REPLY ; echo $$REPLY | xargs -i curl -s -S -Fmysubmit=Package -Fapp_name=$(APPNAME)/$(VERSION) -Fpasswd={} -Fpkg_time=`expr \`date +%s\` \* 1000` "http://$(ROKU_DEV_TARGET)/plugin_package" | grep '^<tr><td><font face="Courier"><a' | sed 's/.*href=\"\([^\"]*\)\".*/\1/' | sed 's#pkgs//##' | xargs -i curl -s -S -o $(PKGREL)/$(APPNAME)_`date +%F-%T`.pkg http://$(ROKU_DEV_TARGET)/pkgs/{} ; \
	fi

	@echo "*** Package  $(APPNAME) complete ***" 

remove:
	@echo "Removing $(APPNAME) from host $(ROKU_DEV_TARGET)"
	@if [ "$(HTTPSTATUS)" == " 401" ]; \
	then \
		curl --user $(USERPASS) --digest -s -S -F "mysubmit=Delete" -F "archive=" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[[" ; \
	else \
		curl -s -S -F "mysubmit=Delete" -F "archive=" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[[" ; \
	fi
