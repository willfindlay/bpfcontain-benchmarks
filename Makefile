TARGET = bpfcontain-benchmarks
RUN_FLAGS = --privileged -v $(shell readlink -f data):/benches/data:rw

.PHONY: run
run: build
	docker run $(RUN_FLAGS) $(TARGET) $(CMD)

.PHONY: bash
bash: build
	docker run $(RUN_FLAGS) -it $(TARGET) bash

.PHONY: build
build: Dockerfile .dockerignore **
	docker build -t $(TARGET) .
