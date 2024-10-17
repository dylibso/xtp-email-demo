.PHONY: test
test:
	$(MAKE) -s build
	xtp plugin test example-plugin/dist/plugin.wasm \
		--with simulation/test/test.wasm \
		--mock-host simulation/host/dist/plugin.wasm

.PHONY: build
build:
	$(MAKE) -C example-plugin
	$(MAKE) -C simulation/test
	$(MAKE) -C simulation/host

.PHONY: newplugin
newplugin:
	xtp plugin init --schema-file schema.yaml --feature stub-with-code-samples

.PHONY: clean
clean:
	$(MAKE) -C example-plugin clean
	$(MAKE) -C simulation/test clean
	$(MAKE) -C simulation/host clean

.PHONY: veryclean
veryclean:
	$(MAKE) -C example-plugin veryclean
	$(MAKE) -C simulation/test clean
	$(MAKE) -C simulation/host veryclean
