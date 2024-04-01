CC := nixos-rebuild
CFLAGS := --flake . --use-remote-sudo --impure

.PHONY: all apply clean

all:
	@${CC} test --fast ${CFLAGS}
	@hyprctl reload > /dev/null

apply:
	@${CC} boot ${CFLAGS}

# TODO: switch to nix3 commands
clean:
	@sudo nix-collect-garbage -d
	@sudo nix-store --optimise
