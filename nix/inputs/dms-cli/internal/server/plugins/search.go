package plugins

import (
	"fmt"
	"net"
	"strings"

	"github.com/AvengeMedia/danklinux/internal/plugins"
	"github.com/AvengeMedia/danklinux/internal/server/models"
)

func HandleSearch(conn net.Conn, req models.Request) {
	query, ok := req.Params["query"].(string)
	if !ok {
		models.RespondError(conn, req.ID, "missing or invalid 'query' parameter")
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

	searchResults := plugins.FuzzySearch(query, pluginList)

	if category, ok := req.Params["category"].(string); ok && category != "" {
		searchResults = plugins.FilterByCategory(category, searchResults)
	}

	if compositor, ok := req.Params["compositor"].(string); ok && compositor != "" {
		searchResults = plugins.FilterByCompositor(compositor, searchResults)
	}

	if capability, ok := req.Params["capability"].(string); ok && capability != "" {
		searchResults = plugins.FilterByCapability(capability, searchResults)
	}

	searchResults = plugins.SortByFirstParty(searchResults)

	manager, err := plugins.NewManager()
	if err != nil {
		models.RespondError(conn, req.ID, fmt.Sprintf("failed to create manager: %v", err))
		return
	}

	result := make([]PluginInfo, len(searchResults))
	for i, p := range searchResults {
		installed, _ := manager.IsInstalled(p)
		result[i] = PluginInfo{
			ID:           p.ID,
			Name:         p.Name,
			Category:     p.Category,
			Author:       p.Author,
			Description:  p.Description,
			Repo:         p.Repo,
			Path:         p.Path,
			Capabilities: p.Capabilities,
			Compositors:  p.Compositors,
			Dependencies: p.Dependencies,
			Installed:    installed,
			FirstParty:   strings.HasPrefix(p.Repo, "https://github.com/AvengeMedia"),
		}
	}

	models.Respond(conn, req.ID, result)
}
