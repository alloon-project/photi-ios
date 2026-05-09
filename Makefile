TUIST = $(shell which tuist)

generate:
	$(TUIST) fetch
	TUIST_ROOT_DIR=${PWD} $(TUIST) generate
	python3 scripts/patch_workspace.py

reset:
	$(TUIST) clean
	rm -rf **/**/*.xcodeproj
	rm -rf *.xcworkspace

regenerate:
	make reset
	make generate
