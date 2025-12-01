package plugins

import (
	"fmt"
	"net"

	"github.com/AvengeMedia/danklinux/internal/plugins"
	"github.com/AvengeMedia/danklinux/internal/server/models"
)

func HandleUninstall(conn net.Conn, req models.Request) {
	name, ok := req.Params["name"].(string)
	if !ok {
		models.RespondError(conn, req.ID, "missing or invalid 'name' parameter")
		return
	}

	registry, err := plugins.NewRegistry()
	if err != nil {
		models.RespondError(conn, req.ID, fmt.Sprintf("failed to create registry: %v", err))
		return
	}

	pluginList, err := registry.List()
	if err != nil {
		models.RespondError(conn, req.ID, fmt.Sprintf("failed to list plugins: %v", err))
		return
	}

	var plugin *plugins.Plugin
	for _, p := range pluginList {
		if p.Name == name {
			plugin = &p
			break
		}
	}

	if plugin == nil {
		models.RespondError(conn, req.ID, fmt.Sprintf("plugin not found: %s", name))
		return
	}

	manager, err := plugins.NewManager()
	if err != nil {
		models.RespondError(conn, req.ID, fmt.Sprintf("failed to create manager: %v", err))
		return
	}

	installed, err := manager.IsInstalled(*plugin)
	if err != nil {
		models.RespondError(conn, req.ID, fmt.Sprintf("failed to check if plugin is installed: %v", err))
		return
	}

	if !installed {
		models.RespondError(conn, req.ID, fmt.Sprintf("plugin not installed: %s", name))
		return
	}

	if err := manager.Uninstall(*plugin); err != nil {
		models.RespondError(conn, req.ID, fmt.Sprintf("failed to uninstall plugin: %v", err))
		return
	}

	models.Respond(conn, req.ID, SuccessResult{
		Success: true,
		Message: fmt.Sprintf("plugin uninstalled: %s", name),
	})
}
