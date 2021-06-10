TARGET = bpfcontain-benchmarks

.PHONY: run
run: build
	docker run $(TARGET) $(CMD)

.PHONY: build
build: Dockerfile .dockerignore **
	docker build -t $(TARGET) .
