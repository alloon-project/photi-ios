generate:
	tuist fetch
	TUIST_ROOT_DIR=${PWD} tuist generate

reset:
	tuist clean
	rm -rf **/**/*.xcodeproj
	rm -rf *.xcworkspace

regenerate: 
	make reset
	make generate
