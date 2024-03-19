CC := nixos-rebuild
CFLAGS := --flake . --use-remote-sudo --max-jobs 4

.PHONY: all apply clean

all:
	@${CC} test --fast ${CFLAGS}

apply:
	@${CC} boot ${CFLAGS}

# Doing it twice wipes the boot entries as well.
clean:
	@${CC} boot ${CFLAGS}
	@sudo nix-collect-garbage -d
	@${CC} boot ${CFLAGS}
	@sudo nix-collect-garbage -d