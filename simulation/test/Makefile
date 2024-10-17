test.wasm: test.go
	tinygo build -o test.wasm -target wasi test.go

.PHONY: clean
clean:
	rm -f test.wasm
