CC := nixos-rebuild
CFLAGS := --flake . --use-remote-sudo --verbose

.PHONY: all apply clean

all:
	@${CC} test --fast ${CFLAGS}

apply:
	@${CC} boot ${CFLAGS}

# TODO: switch to nix3 commands
clean:
	@sudo nix-collect-garbage -d
	@sudo nix-store --optimise
