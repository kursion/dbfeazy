.PHONY: clean

build: clean
	mkdir -p build
	coffee --output build --compile src/index.coffee
	coffee --output build --compile src/helpers.coffee

clean:
	rm -rf build
