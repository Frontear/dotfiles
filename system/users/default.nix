{ ... }:
{
    imports = [
        ./frontear
    ];

    # disallow user mutation
    users.mutableUsers = false;
}
