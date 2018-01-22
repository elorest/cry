PREFIX=/usr/local
INSTALL_DIR=$(PREFIX)/bin
CRY_SYSTEM=$(INSTALL_DIR)/cry

OUT_DIR=$(shell pwd)/bin
CRY=$(OUT_DIR)/cry
CRY_SOURCES=$(shell find src/ -type f -name '*.cr')

all: build

build: lib $(CRY)

lib:
	@crystal deps

$(CRY): $(CRY_SOURCES) | $(OUT_DIR)
	@echo "Building cry in $@"
	@crystal build -o $@ src/cry.cr -p --no-debug

$(OUT_DIR) $(INSTALL_DIR):
	 @mkdir -p $@

run:
	$(CRY)

install: build | $(INSTALL_DIR)
	@-rm $(CRY_SYSTEM)
	@cp $(CRY) $(CRY_SYSTEM)

link: build | $(INSTALL_DIR)
	@echo "Symlinking $(CRY) to $(CRY_SYSTEM)"
	@ln -s $(CRY) $(CRY_SYSTEM)

force_link: build | $(INSTALL_DIR)
	@echo "Symlinking $(CRY) to $(CRY_SYSTEM)"
	@ln -sf $(CRY) $(CRY_SYSTEM)

clean:
	rm -rf $(CRY)

distclean:
	rm -rf $(CRY) .crystal .shards libs lib
