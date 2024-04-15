CC := nixos-rebuild
CFLAGS := --flake . --use-remote-sudo --verbose --option eval-cache false

.PHONY: all apply clean

all:
	@${CC} test --fast ${CFLAGS}

apply:
	@${CC} switch ${CFLAGS}

# TODO: switch to nix3 commands
clean:
	@sudo nix-collect-garbage -d
	@sudo nix-store --optimise

update:
	@nix flake update
	@cd templates/flake && nix flake update
