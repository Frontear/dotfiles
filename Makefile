CC := nixos-rebuild
CFLAGS := --flake . --use-remote-sudo --max-jobs 4

.PHONY: all switch

all:
	@${CC} test --fast ${CFLAGS}

apply:
	@${CC} boot ${CFLAGS}