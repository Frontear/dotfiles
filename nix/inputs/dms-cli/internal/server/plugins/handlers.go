package plugins

import (
	"fmt"
	"net"

	"github.com/AvengeMedia/danklinux/internal/server/models"
)

func HandleRequest(conn net.Conn, req models.Request) {
	switch req.Method {
	case "plugins.list":
		HandleList(conn, req)
	case "plugins.listInstalled":
		HandleListInstalled(conn, req)
	case "plugins.install":
		HandleInstall(conn, req)
	case "plugins.uninstall":
		HandleUninstall(conn, req)
	case "plugins.update":
		HandleUpdate(conn, req)
	case "plugins.search":
		HandleSearch(conn, req)
	default:
		models.RespondError(conn, req.ID, fmt.Sprintf("unknown method: %s", req.Method))
	}
}
