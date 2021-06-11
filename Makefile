TARGET = bpfcontain-benchmarks

.PHONY: run
run: build
	docker run $(TARGET) $(CMD)

.PHONY: bash
bash: build
	docker run --privileged -it $(TARGET) bash

.PHONY: build
build: Dockerfile .dockerignore **
	docker build -t $(TARGET) .
