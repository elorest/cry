OUT_DIR=bin

all: build

install: build force_link

build: $(OUT_DIR)/cry

$(OUT_DIR)/cry: src/** lib
	@echo "Building cry in $(shell pwd)"
	@mkdir -p $(OUT_DIR)
	@crystal build -o $(OUT_DIR)/cry src/cry.cr -p --no-debug

lib:
	@shards

run:
	$(OUT_DIR)/cry

clean:
	rm -rf  $(OUT_DIR) .crystal .shards libs lib

link:
	@ln -s `pwd`/bin/cry /usr/local/bin/cry

force_link:
	@echo "Symlinking `pwd`/bin/cry to /usr/local/bin/cry"
	@ln -sf `pwd`/bin/cry /usr/local/bin/cry
