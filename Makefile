TUIST = ~/.tuist/versions/3.17.0/tuist

generate:
	$(TUIST) fetch
	TUIST_ROOT_DIR=${PWD} $(TUIST) generate

reset:
	$(TUIST) clean
	rm -rf **/**/*.xcodeproj
	rm -rf *.xcworkspace

regenerate:
	make reset
	make generate
