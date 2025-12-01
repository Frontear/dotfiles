package hyprland

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

const (
	TitleRegex         = "#+!"
	HideComment        = "[hidden]"
	CommentBindPattern = "#/#"
)

var ModSeparators = []rune{'+', ' '}

type KeyBinding struct {
	Mods       []string `json:"mods"`
	Key        string   `json:"key"`
	Dispatcher string   `json:"dispatcher"`
	Params     string   `json:"params"`
	Comment    string   `json:"comment"`
}

type Section struct {
	Children []Section    `json:"children"`
	Keybinds []KeyBinding `json:"keybinds"`
	Name     string       `json:"name"`
}

type Parser struct {
	contentLines []string
	readingLine  int
}

func NewParser() *Parser {
	return &Parser{
		contentLines: []string{},
		readingLine:  0,
	}
}

func (p *Parser) ReadContent(directory string) error {
	expandedDir := os.ExpandEnv(directory)
	expandedDir = filepath.Clean(expandedDir)
	if strings.HasPrefix(expandedDir, "~") {
		home, err := os.UserHomeDir()
		if err != nil {
			return err
		}
		expandedDir = filepath.Join(home, expandedDir[1:])
	}

	info, err := os.Stat(expandedDir)
	if err != nil {
		return err
	}
	if !info.IsDir() {
		return os.ErrNotExist
	}

	confFiles, err := filepath.Glob(filepath.Join(expandedDir, "*.conf"))
	if err != nil {
		return err
	}
	if len(confFiles) == 0 {
		return os.ErrNotExist
	}

	var combinedContent []string
	for _, confFile := range confFiles {
		if fileInfo, err := os.Stat(confFile); err == nil && fileInfo.Mode().IsRegular() {
			data, err := os.ReadFile(confFile)
			if err == nil {
				combinedContent = append(combinedContent, string(data))
			}
		}
	}

	if len(combinedContent) == 0 {
		return os.ErrNotExist
	}

	fullContent := strings.Join(combinedContent, "\n")
	p.contentLines = strings.Split(fullContent, "\n")
	return nil
}

func autogenerateComment(dispatcher, params string) string {
	switch dispatcher {
	case "resizewindow":
		return "Resize window"

	case "movewindow":
		if params == "" {
			return "Move window"
		}
		dirMap := map[string]string{
			"l": "left",
			"r": "right",
			"u": "up",
			"d": "down",
		}
		if dir, ok := dirMap[params]; ok {
			return "Window: move in " + dir + " direction"
		}
		return "Window: move in null direction"

	case "pin":
		return "Window: pin (show on all workspaces)"

	case "splitratio":
		return "Window split ratio " + params

	case "togglefloating":
		return "Float/unfloat window"

	case "resizeactive":
		return "Resize window by " + params

	case "killactive":
		return "Close window"

	case "fullscreen":
		fsMap := map[string]string{
			"0": "fullscreen",
			"1": "maximization",
			"2": "fullscreen on Hyprland's side",
		}
		if fs, ok := fsMap[params]; ok {
			return "Toggle " + fs
		}
		return "Toggle null"

	case "fakefullscreen":
		return "Toggle fake fullscreen"

	case "workspace":
		if params == "+1" {
			return "Workspace: focus right"
		} else if params == "-1" {
			return "Workspace: focus left"
		}
		return "Focus workspace " + params

	case "movefocus":
		dirMap := map[string]string{
			"l": "left",
			"r": "right",
			"u": "up",
			"d": "down",
		}
		if dir, ok := dirMap[params]; ok {
			return "Window: move focus " + dir
		}
		return "Window: move focus null"

	case "swapwindow":
		dirMap := map[string]string{
			"l": "left",
			"r": "right",
			"u": "up",
			"d": "down",
		}
		if dir, ok := dirMap[params]; ok {
			return "Window: swap in " + dir + " direction"
		}
		return "Window: swap in null direction"

	case "movetoworkspace":
		if params == "+1" {
			return "Window: move to right workspace (non-silent)"
		} else if params == "-1" {
			return "Window: move to left workspace (non-silent)"
		}
		return "Window: move to workspace " + params + " (non-silent)"

	case "movetoworkspacesilent":
		if params == "+1" {
			return "Window: move to right workspace"
		} else if params == "-1" {
			return "Window: move to right workspace"
		}
		return "Window: move to workspace " + params

	case "togglespecialworkspace":
		return "Workspace: toggle special"

	case "exec":
		return "Execute: " + params

	default:
		return ""
	}
}

func (p *Parser) getKeybindAtLine(lineNumber int) *KeyBinding {
	line := p.contentLines[lineNumber]
	parts := strings.SplitN(line, "=", 2)
	if len(parts) < 2 {
		return nil
	}

	keys := parts[1]
	keyParts := strings.SplitN(keys, "#", 2)
	keys = keyParts[0]

	var comment string
	if len(keyParts) > 1 {
		comment = strings.TrimSpace(keyParts[1])
	}

	keyFields := strings.SplitN(keys, ",", 5)
	if len(keyFields) < 3 {
		return nil
	}

	mods := strings.TrimSpace(keyFields[0])
	key := strings.TrimSpace(keyFields[1])
	dispatcher := strings.TrimSpace(keyFields[2])

	var params string
	if len(keyFields) > 3 {
		paramParts := keyFields[3:]
		params = strings.TrimSpace(strings.Join(paramParts, ","))
	}

	if comment != "" {
		if strings.HasPrefix(comment, HideComment) {
			return nil
		}
	} else {
		comment = autogenerateComment(dispatcher, params)
	}

	var modList []string
	if mods != "" {
		modstring := mods + string(ModSeparators[0])
		p := 0
		for index, char := range modstring {
			isModSep := false
			for _, sep := range ModSeparators {
				if char == sep {
					isModSep = true
					break
				}
			}
			if isModSep {
				if index-p > 1 {
					modList = append(modList, modstring[p:index])
				}
				p = index + 1
			}
		}
	}

	return &KeyBinding{
		Mods:       modList,
		Key:        key,
		Dispatcher: dispatcher,
		Params:     params,
		Comment:    comment,
	}
}

func (p *Parser) getBindsRecursive(currentContent *Section, scope int) *Section {
	titleRegex := regexp.MustCompile(TitleRegex)

	for p.readingLine < len(p.contentLines) {
		line := p.contentLines[p.readingLine]

		loc := titleRegex.FindStringIndex(line)
		if loc != nil && loc[0] == 0 {
			headingScope := strings.Index(line, "!")

			if headingScope <= scope {
				p.readingLine--
				return currentContent
			}

			sectionName := strings.TrimSpace(line[headingScope+1:])
			p.readingLine++

			childSection := &Section{
				Children: []Section{},
				Keybinds: []KeyBinding{},
				Name:     sectionName,
			}
			result := p.getBindsRecursive(childSection, headingScope)
			currentContent.Children = append(currentContent.Children, *result)

		} else if strings.HasPrefix(line, CommentBindPattern) {
			keybind := p.getKeybindAtLine(p.readingLine)
			if keybind != nil {
				currentContent.Keybinds = append(currentContent.Keybinds, *keybind)
			}

		} else if line == "" || !strings.HasPrefix(strings.TrimSpace(line), "bind") {

		} else {
			keybind := p.getKeybindAtLine(p.readingLine)
			if keybind != nil {
				currentContent.Keybinds = append(currentContent.Keybinds, *keybind)
			}
		}

		p.readingLine++
	}

	return currentContent
}

func (p *Parser) ParseKeys() *Section {
	p.readingLine = 0
	rootSection := &Section{
		Children: []Section{},
		Keybinds: []KeyBinding{},
		Name:     "",
	}
	return p.getBindsRecursive(rootSection, 0)
}

func ParseKeys(path string) (*Section, error) {
	parser := NewParser()
	if err := parser.ReadContent(path); err != nil {
		return nil, err
	}
	return parser.ParseKeys(), nil
}
