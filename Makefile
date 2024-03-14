CC := nixos-rebuild
CFLAGS := --use-remote-sudo --flake . --max-jobs 4

.PHONY: all switch

all:
	@${CC} test ${CFLAGS}

boot:
	@${CC} boot ${CFLAGS}