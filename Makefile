OUT_DIR=bin

all: build force_link

install: build link

build:
	@echo "Building cry in $(shell pwd)"
	@mkdir -p $(OUT_DIR)
	@crystal build -o $(OUT_DIR)/cry src/cry.cr -p --no-debug

run:
	$(OUT_DIR)/cry

clean:
	rm -rf  $(OUT_DIR) .crystal .shards libs lib

link:
	@ln -s `pwd`/bin/cry /usr/local/bin/cry

force_link:
	@echo "Symlinking `pwd`/bin/cry to /usr/local/bin/amber"
	@ln -sf `pwd`/bin/cry /usr/local/bin/cry
