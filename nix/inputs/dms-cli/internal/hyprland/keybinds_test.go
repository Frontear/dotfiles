package hyprland

import (
	"os"
	"path/filepath"
	"testing"
)

func TestAutogenerateComment(t *testing.T) {
	tests := []struct {
		dispatcher string
		params     string
		expected   string
	}{
		{"resizewindow", "", "Resize window"},
		{"movewindow", "", "Move window"},
		{"movewindow", "l", "Window: move in left direction"},
		{"movewindow", "r", "Window: move in right direction"},
		{"movewindow", "u", "Window: move in up direction"},
		{"movewindow", "d", "Window: move in down direction"},
		{"pin", "", "Window: pin (show on all workspaces)"},
		{"splitratio", "0.5", "Window split ratio 0.5"},
		{"togglefloating", "", "Float/unfloat window"},
		{"resizeactive", "10 20", "Resize window by 10 20"},
		{"killactive", "", "Close window"},
		{"fullscreen", "0", "Toggle fullscreen"},
		{"fullscreen", "1", "Toggle maximization"},
		{"fullscreen", "2", "Toggle fullscreen on Hyprland's side"},
		{"fakefullscreen", "", "Toggle fake fullscreen"},
		{"workspace", "+1", "Workspace: focus right"},
		{"workspace", "-1", "Workspace: focus left"},
		{"workspace", "5", "Focus workspace 5"},
		{"movefocus", "l", "Window: move focus left"},
		{"movefocus", "r", "Window: move focus right"},
		{"movefocus", "u", "Window: move focus up"},
		{"movefocus", "d", "Window: move focus down"},
		{"swapwindow", "l", "Window: swap in left direction"},
		{"swapwindow", "r", "Window: swap in right direction"},
		{"swapwindow", "u", "Window: swap in up direction"},
		{"swapwindow", "d", "Window: swap in down direction"},
		{"movetoworkspace", "+1", "Window: move to right workspace (non-silent)"},
		{"movetoworkspace", "-1", "Window: move to left workspace (non-silent)"},
		{"movetoworkspace", "3", "Window: move to workspace 3 (non-silent)"},
		{"movetoworkspacesilent", "+1", "Window: move to right workspace"},
		{"movetoworkspacesilent", "-1", "Window: move to right workspace"},
		{"movetoworkspacesilent", "2", "Window: move to workspace 2"},
		{"togglespecialworkspace", "", "Workspace: toggle special"},
		{"exec", "firefox", "Execute: firefox"},
		{"unknown", "", ""},
	}

	for _, tt := range tests {
		t.Run(tt.dispatcher+"_"+tt.params, func(t *testing.T) {
			result := autogenerateComment(tt.dispatcher, tt.params)
			if result != tt.expected {
				t.Errorf("autogenerateComment(%q, %q) = %q, want %q",
					tt.dispatcher, tt.params, result, tt.expected)
			}
		})
	}
}

func TestGetKeybindAtLine(t *testing.T) {
	tests := []struct {
		name     string
		line     string
		expected *KeyBinding
	}{
		{
			name: "basic_keybind",
			line: "bind = SUPER, Q, killactive",
			expected: &KeyBinding{
				Mods:       []string{"SUPER"},
				Key:        "Q",
				Dispatcher: "killactive",
				Params:     "",
				Comment:    "Close window",
			},
		},
		{
			name: "keybind_with_params",
			line: "bind = SUPER, left, movefocus, l",
			expected: &KeyBinding{
				Mods:       []string{"SUPER"},
				Key:        "left",
				Dispatcher: "movefocus",
				Params:     "l",
				Comment:    "Window: move focus left",
			},
		},
		{
			name: "keybind_with_comment",
			line: "bind = SUPER, T, exec, kitty # Open terminal",
			expected: &KeyBinding{
				Mods:       []string{"SUPER"},
				Key:        "T",
				Dispatcher: "exec",
				Params:     "kitty",
				Comment:    "Open terminal",
			},
		},
		{
			name:     "keybind_hidden",
			line:     "bind = SUPER, H, exec, secret # [hidden]",
			expected: nil,
		},
		{
			name: "keybind_multiple_mods",
			line: "bind = SUPER+SHIFT, F, fullscreen, 0",
			expected: &KeyBinding{
				Mods:       []string{"SUPER", "SHIFT"},
				Key:        "F",
				Dispatcher: "fullscreen",
				Params:     "0",
				Comment:    "Toggle fullscreen",
			},
		},
		{
			name: "keybind_no_mods",
			line: "bind = , Print, exec, screenshot",
			expected: &KeyBinding{
				Mods:       []string{},
				Key:        "Print",
				Dispatcher: "exec",
				Params:     "screenshot",
				Comment:    "Execute: screenshot",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			parser := NewParser()
			parser.contentLines = []string{tt.line}
			result := parser.getKeybindAtLine(0)

			if tt.expected == nil {
				if result != nil {
					t.Errorf("expected nil, got %+v", result)
				}
				return
			}

			if result == nil {
				t.Errorf("expected %+v, got nil", tt.expected)
				return
			}

			if result.Key != tt.expected.Key {
				t.Errorf("Key = %q, want %q", result.Key, tt.expected.Key)
			}
			if result.Dispatcher != tt.expected.Dispatcher {
				t.Errorf("Dispatcher = %q, want %q", result.Dispatcher, tt.expected.Dispatcher)
			}
			if result.Params != tt.expected.Params {
				t.Errorf("Params = %q, want %q", result.Params, tt.expected.Params)
			}
			if result.Comment != tt.expected.Comment {
				t.Errorf("Comment = %q, want %q", result.Comment, tt.expected.Comment)
			}
			if len(result.Mods) != len(tt.expected.Mods) {
				t.Errorf("Mods length = %d, want %d", len(result.Mods), len(tt.expected.Mods))
			} else {
				for i := range result.Mods {
					if result.Mods[i] != tt.expected.Mods[i] {
						t.Errorf("Mods[%d] = %q, want %q", i, result.Mods[i], tt.expected.Mods[i])
					}
				}
			}
		})
	}
}

func TestParseKeysWithSections(t *testing.T) {
	tmpDir := t.TempDir()
	configFile := filepath.Join(tmpDir, "hyprland.conf")

	content := `##! Window Management
bind = SUPER, Q, killactive
bind = SUPER, F, fullscreen, 0

###! Movement
bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r

##! Applications
bind = SUPER, T, exec, kitty # Terminal
`

	if err := os.WriteFile(configFile, []byte(content), 0644); err != nil {
		t.Fatalf("Failed to write test config: %v", err)
	}

	section, err := ParseKeys(tmpDir)
	if err != nil {
		t.Fatalf("ParseKeys failed: %v", err)
	}

	if len(section.Children) != 2 {
		t.Errorf("Expected 2 top-level sections, got %d", len(section.Children))
	}

	if len(section.Children) >= 1 {
		windowMgmt := section.Children[0]
		if windowMgmt.Name != "Window Management" {
			t.Errorf("First section name = %q, want %q", windowMgmt.Name, "Window Management")
		}
		if len(windowMgmt.Keybinds) != 2 {
			t.Errorf("Window Management keybinds = %d, want 2", len(windowMgmt.Keybinds))
		}

		if len(windowMgmt.Children) != 1 {
			t.Errorf("Window Management children = %d, want 1", len(windowMgmt.Children))
		} else {
			movement := windowMgmt.Children[0]
			if movement.Name != "Movement" {
				t.Errorf("Movement section name = %q, want %q", movement.Name, "Movement")
			}
			if len(movement.Keybinds) != 2 {
				t.Errorf("Movement keybinds = %d, want 2", len(movement.Keybinds))
			}
		}
	}

	if len(section.Children) >= 2 {
		apps := section.Children[1]
		if apps.Name != "Applications" {
			t.Errorf("Second section name = %q, want %q", apps.Name, "Applications")
		}
		if len(apps.Keybinds) != 1 {
			t.Errorf("Applications keybinds = %d, want 1", len(apps.Keybinds))
		}
		if len(apps.Keybinds) > 0 && apps.Keybinds[0].Comment != "Terminal" {
			t.Errorf("Applications keybind comment = %q, want %q", apps.Keybinds[0].Comment, "Terminal")
		}
	}
}

func TestParseKeysWithCommentBinds(t *testing.T) {
	tmpDir := t.TempDir()
	configFile := filepath.Join(tmpDir, "test.conf")

	content := `#/# = SUPER, A, exec, app1
bind = SUPER, B, exec, app2
#/# = SUPER, C, exec, app3 # Custom comment
`

	if err := os.WriteFile(configFile, []byte(content), 0644); err != nil {
		t.Fatalf("Failed to write test config: %v", err)
	}

	section, err := ParseKeys(tmpDir)
	if err != nil {
		t.Fatalf("ParseKeys failed: %v", err)
	}

	if len(section.Keybinds) != 3 {
		t.Errorf("Expected 3 keybinds, got %d", len(section.Keybinds))
	}

	if len(section.Keybinds) > 0 && section.Keybinds[0].Key != "A" {
		t.Errorf("First keybind key = %q, want %q", section.Keybinds[0].Key, "A")
	}
	if len(section.Keybinds) > 1 && section.Keybinds[1].Key != "B" {
		t.Errorf("Second keybind key = %q, want %q", section.Keybinds[1].Key, "B")
	}
	if len(section.Keybinds) > 2 && section.Keybinds[2].Comment != "Custom comment" {
		t.Errorf("Third keybind comment = %q, want %q", section.Keybinds[2].Comment, "Custom comment")
	}
}

func TestReadContentMultipleFiles(t *testing.T) {
	tmpDir := t.TempDir()

	file1 := filepath.Join(tmpDir, "a.conf")
	file2 := filepath.Join(tmpDir, "b.conf")

	content1 := "bind = SUPER, Q, killactive\n"
	content2 := "bind = SUPER, T, exec, kitty\n"

	if err := os.WriteFile(file1, []byte(content1), 0644); err != nil {
		t.Fatalf("Failed to write file1: %v", err)
	}
	if err := os.WriteFile(file2, []byte(content2), 0644); err != nil {
		t.Fatalf("Failed to write file2: %v", err)
	}

	parser := NewParser()
	if err := parser.ReadContent(tmpDir); err != nil {
		t.Fatalf("ReadContent failed: %v", err)
	}

	section := parser.ParseKeys()
	if len(section.Keybinds) != 2 {
		t.Errorf("Expected 2 keybinds from multiple files, got %d", len(section.Keybinds))
	}
}

func TestReadContentErrors(t *testing.T) {
	tests := []struct {
		name string
		path string
	}{
		{
			name: "nonexistent_directory",
			path: "/nonexistent/path/that/does/not/exist",
		},
		{
			name: "empty_directory",
			path: t.TempDir(),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := ParseKeys(tt.path)
			if err == nil {
				t.Error("Expected error, got nil")
			}
		})
	}
}

func TestReadContentWithTildeExpansion(t *testing.T) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		t.Skip("Cannot get home directory")
	}

	tmpSubdir := filepath.Join(homeDir, ".config", "test-hypr-"+t.Name())
	if err := os.MkdirAll(tmpSubdir, 0755); err != nil {
		t.Skip("Cannot create test directory in home")
	}
	defer os.RemoveAll(tmpSubdir)

	configFile := filepath.Join(tmpSubdir, "test.conf")
	if err := os.WriteFile(configFile, []byte("bind = SUPER, Q, killactive\n"), 0644); err != nil {
		t.Fatalf("Failed to write test config: %v", err)
	}

	relPath, err := filepath.Rel(homeDir, tmpSubdir)
	if err != nil {
		t.Skip("Cannot create relative path")
	}

	parser := NewParser()
	tildePathMatch := "~/" + relPath
	err = parser.ReadContent(tildePathMatch)

	if err != nil {
		t.Errorf("ReadContent with tilde path failed: %v", err)
	}
}

func TestKeybindWithParamsContainingCommas(t *testing.T) {
	parser := NewParser()
	parser.contentLines = []string{"bind = SUPER, R, exec, notify-send 'Title' 'Message, with comma'"}

	result := parser.getKeybindAtLine(0)

	if result == nil {
		t.Fatal("Expected keybind, got nil")
	}

	expected := "notify-send 'Title' 'Message, with comma'"
	if result.Params != expected {
		t.Errorf("Params = %q, want %q", result.Params, expected)
	}
}

func TestEmptyAndCommentLines(t *testing.T) {
	tmpDir := t.TempDir()
	configFile := filepath.Join(tmpDir, "test.conf")

	content := `
# This is a comment
bind = SUPER, Q, killactive

# Another comment

bind = SUPER, T, exec, kitty
`

	if err := os.WriteFile(configFile, []byte(content), 0644); err != nil {
		t.Fatalf("Failed to write test config: %v", err)
	}

	section, err := ParseKeys(tmpDir)
	if err != nil {
		t.Fatalf("ParseKeys failed: %v", err)
	}

	if len(section.Keybinds) != 2 {
		t.Errorf("Expected 2 keybinds (comments ignored), got %d", len(section.Keybinds))
	}
}
