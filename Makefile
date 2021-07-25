TARGET = bpfcontain-benchmarks
RUN_FLAGS = --rm --privileged --cap-add=SYS_ADMIN --cap-add=MAC_ADMIN \
		-v $(shell readlink -f data):/benches/data:rw \
		-v /lib/modules:/lib/modules:ro \
		-v /usr/include/linux:/usr/include/linux:ro \
		-v /sys/kernel/debug:/sys/kernel/debug \
		-v /sys/kernel/security:/sys/kernel/security:rw

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
