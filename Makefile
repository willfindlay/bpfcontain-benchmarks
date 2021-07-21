TARGET = bpfcontain-benchmarks
RUN_FLAGS = --privileged -v $(shell readlink -f data):/benches/data:rw \
	-v /lib/modules:/lib/modules:ro  -v /usr/include/linux:/usr/include/linux:ro \
	-v /sys/kernel/debug:/sys/kernel/debug

.PHONY: run
run: | build
	docker run $(RUN_FLAGS) $(TARGET) $(CMD)

.PHONY: bash
bash: | build
	docker run $(RUN_FLAGS) -it $(TARGET) bash

.PHONY: build
build:
	docker build -t $(TARGET) .

.PHONY: force-build
force-build:
	docker build --no-cache -t $(TARGET) .
