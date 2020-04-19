.PHONY: clean

build: clean
	mkdir -p build
	./node_modules/.bin/coffee --output build --compile src/index.coffee
	./node_modules/.bin/coffee --output build --compile src/helpers.coffee

clean:
	rm -rf build
