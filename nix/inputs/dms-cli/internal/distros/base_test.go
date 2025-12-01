package distros

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/AvengeMedia/danklinux/internal/deps"
)

func TestBaseDistribution_detectDMS_NotInstalled(t *testing.T) {
	originalHome := os.Getenv("HOME")
	defer os.Setenv("HOME", originalHome)

	tempDir := t.TempDir()
	os.Setenv("HOME", tempDir)

	logChan := make(chan string, 10)
	defer close(logChan)

	base := NewBaseDistribution(logChan)
	dep := base.detectDMS()

	if dep.Status != deps.StatusMissing {
		t.Errorf("Expected StatusMissing, got %d", dep.Status)
	}

	if dep.Name != "dms (DankMaterialShell)" {
		t.Errorf("Expected name 'dms (DankMaterialShell)', got %s", dep.Name)
	}

	if !dep.Required {
		t.Error("Expected Required to be true")
	}
}

func TestBaseDistribution_detectDMS_Installed(t *testing.T) {
	if !commandExists("git") {
		t.Skip("git not available")
	}

	tempDir := t.TempDir()
	dmsPath := filepath.Join(tempDir, ".config", "quickshell", "dms")
	os.MkdirAll(dmsPath, 0755)

	originalHome := os.Getenv("HOME")
	defer os.Setenv("HOME", originalHome)
	os.Setenv("HOME", tempDir)

	exec.Command("git", "init", dmsPath).Run()
	exec.Command("git", "-C", dmsPath, "config", "user.email", "test@test.com").Run()
	exec.Command("git", "-C", dmsPath, "config", "user.name", "Test User").Run()
	exec.Command("git", "-C", dmsPath, "checkout", "-b", "master").Run()

	testFile := filepath.Join(dmsPath, "test.txt")
	os.WriteFile(testFile, []byte("test"), 0644)
	exec.Command("git", "-C", dmsPath, "add", ".").Run()
	exec.Command("git", "-C", dmsPath, "commit", "-m", "initial").Run()

	logChan := make(chan string, 10)
	defer close(logChan)

	base := NewBaseDistribution(logChan)
	dep := base.detectDMS()

	if dep.Status == deps.StatusMissing {
		t.Error("Expected DMS to be detected as installed")
	}

	if dep.Name != "dms (DankMaterialShell)" {
		t.Errorf("Expected name 'dms (DankMaterialShell)', got %s", dep.Name)
	}

	if !dep.Required {
		t.Error("Expected Required to be true")
	}

	t.Logf("Status: %d, Version: %s", dep.Status, dep.Version)
}

func TestBaseDistribution_detectDMS_NeedsUpdate(t *testing.T) {
	if !commandExists("git") {
		t.Skip("git not available")
	}

	tempDir := t.TempDir()
	dmsPath := filepath.Join(tempDir, ".config", "quickshell", "dms")
	os.MkdirAll(dmsPath, 0755)

	originalHome := os.Getenv("HOME")
	defer os.Setenv("HOME", originalHome)
	os.Setenv("HOME", tempDir)

	exec.Command("git", "init", dmsPath).Run()
	exec.Command("git", "-C", dmsPath, "config", "user.email", "test@test.com").Run()
	exec.Command("git", "-C", dmsPath, "config", "user.name", "Test User").Run()
	exec.Command("git", "-C", dmsPath, "remote", "add", "origin", "https://github.com/AvengeMedia/DankMaterialShell.git").Run()

	testFile := filepath.Join(dmsPath, "test.txt")
	os.WriteFile(testFile, []byte("test"), 0644)
	exec.Command("git", "-C", dmsPath, "add", ".").Run()
	exec.Command("git", "-C", dmsPath, "commit", "-m", "initial").Run()
	exec.Command("git", "-C", dmsPath, "tag", "v0.0.1").Run()
	exec.Command("git", "-C", dmsPath, "checkout", "v0.0.1").Run()

	logChan := make(chan string, 10)
	defer close(logChan)

	base := NewBaseDistribution(logChan)
	dep := base.detectDMS()

	if dep.Name != "dms (DankMaterialShell)" {
		t.Errorf("Expected name 'dms (DankMaterialShell)', got %s", dep.Name)
	}

	if !dep.Required {
		t.Error("Expected Required to be true")
	}

	t.Logf("Status: %d, Version: %s", dep.Status, dep.Version)
}

func TestBaseDistribution_detectDMS_DirectoryWithoutGit(t *testing.T) {
	tempDir := t.TempDir()
	dmsPath := filepath.Join(tempDir, ".config", "quickshell", "dms")
	os.MkdirAll(dmsPath, 0755)

	originalHome := os.Getenv("HOME")
	defer os.Setenv("HOME", originalHome)
	os.Setenv("HOME", tempDir)

	logChan := make(chan string, 10)
	defer close(logChan)

	base := NewBaseDistribution(logChan)
	dep := base.detectDMS()

	if dep.Status == deps.StatusMissing {
		t.Error("Expected DMS to be detected as present")
	}

	if dep.Name != "dms (DankMaterialShell)" {
		t.Errorf("Expected name 'dms (DankMaterialShell)', got %s", dep.Name)
	}

	if !dep.Required {
		t.Error("Expected Required to be true")
	}
}

func TestBaseDistribution_NewBaseDistribution(t *testing.T) {
	logChan := make(chan string, 10)
	defer close(logChan)

	base := NewBaseDistribution(logChan)

	if base == nil {
		t.Fatal("NewBaseDistribution returned nil")
	}

	if base.logChan == nil {
		t.Error("logChan was not set")
	}
}

func commandExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}

func TestBaseDistribution_versionCompare(t *testing.T) {
	logChan := make(chan string, 10)
	defer close(logChan)

	base := NewBaseDistribution(logChan)

	tests := []struct {
		v1       string
		v2       string
		expected int
	}{
		{"0.1.0", "0.1.0", 0},
		{"0.1.0", "0.1.1", -1},
		{"0.1.1", "0.1.0", 1},
		{"0.2.0", "0.1.9", 1},
		{"1.0.0", "0.9.9", 1},
	}

	for _, tt := range tests {
		result := base.versionCompare(tt.v1, tt.v2)
		if result != tt.expected {
			t.Errorf("versionCompare(%q, %q) = %d; want %d", tt.v1, tt.v2, result, tt.expected)
		}
	}
}

func TestBaseDistribution_versionCompare_WithPrefix(t *testing.T) {
	logChan := make(chan string, 10)
	defer close(logChan)

	base := NewBaseDistribution(logChan)

	tests := []struct {
		v1       string
		v2       string
		expected int
	}{
		{"v0.1.0", "v0.1.0", 0},
		{"v0.1.0", "v0.1.1", -1},
		{"v0.1.1", "v0.1.0", 1},
	}

	for _, tt := range tests {
		result := base.versionCompare(tt.v1, tt.v2)
		if result != tt.expected {
			t.Errorf("versionCompare(%q, %q) = %d; want %d", tt.v1, tt.v2, result, tt.expected)
		}
	}
}
