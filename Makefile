export TOP := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST)))/../..)
include $(TOP)/support/mk/Makefile.pkg.mk

APEX_TOP := $(TOP)/apex
APEX_FUNS := $(shell $(FIND_Q) $(APEX_TOP)/functions -mindepth 1 -maxdepth 1 -type d -printf "%f\n")

export ENV_NAME
export API_BASE_URL
export WEB_BASE_URL

# ------------------------------------------------------------------------------

.PHONY: build
build: apex ## Build.


apex:
	ln -snf $(TOP)/apex apex


package.dir/VERSION:
	$(MAKE) -f "$(TOP)/support/mk/Makefile.pkg.mk" $@
	cd package.dir && \
		$(CAT) "package.json" | $(JSON) -e "delete this.dependencies" | $(SPONGE) "package.json"
	$(RM) package.dir/apex
	for f in $(APEX_FUNS); do \
		$(MKDIR) package.dir/apex/functions/$${f}; \
		cp $(APEX_TOP)/functions/$${f}/package.json package.dir/apex/functions/$${f}/package.json; \
	done


server: ## Start the LambdaProxy server.
	AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID) $(NODE) $(NODE_DEBUG_BRK) ./index.js | ./node_modules/bunyan/bin/bunyan


server/debug: ## Start the LambdaProxy server in debug-brk mode.
	NODE_DEBUG_BRK="--inspect --debug-brk" $(MAKE) start
