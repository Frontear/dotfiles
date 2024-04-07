CC := nixos-rebuild
CFLAGS := --flake . --use-remote-sudo

.PHONY: all apply clean

all:
	@rm -f ~/.config/hypr/hyprland.conf

	@${CC} test --fast ${CFLAGS}

	@cp ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.bak
	@mv ~/.config/hypr/hyprland.conf.bak ~/.config/hypr/hyprland.conf
	@chmod +w ~/.config/hypr/hyprland.conf

	@hyprctl reload > /dev/null

apply:
	@${CC} boot ${CFLAGS}

# TODO: switch to nix3 commands
clean:
	@sudo nix-collect-garbage -d
	@sudo nix-store --optimise
