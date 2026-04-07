.PHONY: generate build open clean run

XCODEGEN := /opt/homebrew/bin/xcodegen

generate:
	$(XCODEGEN) generate

build: generate
	xcodebuild -project NotchAgent.xcodeproj -scheme NotchAgent -configuration Debug build

open: generate
	open NotchAgent.xcodeproj

clean:
	rm -rf build/
	rm -rf NotchAgent.xcodeproj

run: build
	open build/Build/Products/Debug/NotchAgent.app
