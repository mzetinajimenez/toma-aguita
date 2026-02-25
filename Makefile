SCHEME    = toma-aguita
PROJECT   = toma-aguita.xcodeproj
SIMULATOR = platform=iOS Simulator,name=iPhone 16

.PHONY: help format lint build test clean

help:
	@echo "Toma Aguita — available commands:"
	@echo ""
	@echo "  make fmt      Format all Swift files in place"
	@echo "  make lint     Check formatting without modifying files"
	@echo "  make build    Debug build"
	@echo "  make test     Run tests on iPhone 16 simulator"
	@echo "  make clean    Clean build folder"
	@echo ""

fmt:
	swiftformat .

lint:
	swiftformat --lint .

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Debug -destination '$(SIMULATOR)' build

test:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) -destination '$(SIMULATOR)'

clean:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean
