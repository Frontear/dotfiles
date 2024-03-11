all:
	@sudo nixos-rebuild test --flake .#`hostname`
