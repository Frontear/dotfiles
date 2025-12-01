package plugins

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/spf13/afero"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func setupTestManager(t *testing.T) (*Manager, afero.Fs, string) {
	fs := afero.NewMemMapFs()
	pluginsDir := "/test-plugins"
	manager := &Manager{
		fs:         fs,
		pluginsDir: pluginsDir,
		gitClient:  &mockGitClient{},
	}
	return manager, fs, pluginsDir
}

func TestNewManager(t *testing.T) {
	manager, err := NewManager()
	assert.NoError(t, err)
	assert.NotNil(t, manager)
	assert.NotEmpty(t, manager.pluginsDir)
}

func TestGetPluginsDir(t *testing.T) {
	t.Run("uses XDG_CONFIG_HOME when set", func(t *testing.T) {
		oldConfig := os.Getenv("XDG_CONFIG_HOME")
		defer func() {
			if oldConfig != "" {
				os.Setenv("XDG_CONFIG_HOME", oldConfig)
			} else {
				os.Unsetenv("XDG_CONFIG_HOME")
			}
		}()

		os.Setenv("XDG_CONFIG_HOME", "/tmp/test-config")
		dir := getPluginsDir()
		assert.Equal(t, "/tmp/test-config/DankMaterialShell/plugins", dir)
	})

	t.Run("falls back to home directory", func(t *testing.T) {
		oldConfig := os.Getenv("XDG_CONFIG_HOME")
		defer func() {
			if oldConfig != "" {
				os.Setenv("XDG_CONFIG_HOME", oldConfig)
			} else {
				os.Unsetenv("XDG_CONFIG_HOME")
			}
		}()

		os.Unsetenv("XDG_CONFIG_HOME")
		dir := getPluginsDir()
		assert.Contains(t, dir, ".config/DankMaterialShell/plugins")
	})
}

func TestIsInstalled(t *testing.T) {
	t.Run("returns true when plugin is installed", func(t *testing.T) {
		manager, fs, pluginsDir := setupTestManager(t)

		plugin := Plugin{ID: "test-plugin", Name: "TestPlugin"}
		pluginPath := filepath.Join(pluginsDir, plugin.ID)
		err := fs.MkdirAll(pluginPath, 0755)
		require.NoError(t, err)

		installed, err := manager.IsInstalled(plugin)
		assert.NoError(t, err)
		assert.True(t, installed)
	})

	t.Run("returns false when plugin is not installed", func(t *testing.T) {
		manager, _, _ := setupTestManager(t)

		plugin := Plugin{ID: "non-existent", Name: "NonExistent"}
		installed, err := manager.IsInstalled(plugin)
		assert.NoError(t, err)
		assert.False(t, installed)
	})
}

func TestInstall(t *testing.T) {
	t.Run("installs plugin successfully", func(t *testing.T) {
		manager, fs, pluginsDir := setupTestManager(t)

		plugin := Plugin{
			ID:   "test-plugin",
			Name: "TestPlugin",
			Repo: "https://github.com/test/plugin",
		}

		cloneCalled := false
		mockGit := &mockGitClient{
			cloneFunc: func(path string, url string) error {
				cloneCalled = true
				assert.Equal(t, filepath.Join(pluginsDir, plugin.ID), path)
				assert.Equal(t, plugin.Repo, url)
				return fs.MkdirAll(path, 0755)
			},
		}
		manager.gitClient = mockGit

		err := manager.Install(plugin)
		assert.NoError(t, err)
		assert.True(t, cloneCalled)

		exists, _ := afero.DirExists(fs, filepath.Join(pluginsDir, plugin.ID))
		assert.True(t, exists)
	})

	t.Run("returns error when plugin already installed", func(t *testing.T) {
		manager, fs, pluginsDir := setupTestManager(t)

		plugin := Plugin{ID: "test-plugin", Name: "TestPlugin"}
		pluginPath := filepath.Join(pluginsDir, plugin.ID)
		err := fs.MkdirAll(pluginPath, 0755)
		require.NoError(t, err)

		err = manager.Install(plugin)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "already installed")
	})

	t.Run("installs monorepo plugin with symlink", func(t *testing.T) {
		t.Skip("Skipping symlink test as MemMapFs doesn't support symlinks")
	})
}

func TestManagerUpdate(t *testing.T) {
	t.Run("updates plugin successfully", func(t *testing.T) {
		manager, fs, pluginsDir := setupTestManager(t)

		plugin := Plugin{ID: "test-plugin", Name: "TestPlugin"}
		pluginPath := filepath.Join(pluginsDir, plugin.ID)
		err := fs.MkdirAll(pluginPath, 0755)
		require.NoError(t, err)

		pullCalled := false
		mockGit := &mockGitClient{
			pullFunc: func(path string) error {
				pullCalled = true
				assert.Equal(t, pluginPath, path)
				return nil
			},
		}
		manager.gitClient = mockGit

		err = manager.Update(plugin)
		assert.NoError(t, err)
		assert.True(t, pullCalled)
	})

	t.Run("returns error when plugin not installed", func(t *testing.T) {
		manager, _, _ := setupTestManager(t)

		plugin := Plugin{ID: "non-existent", Name: "NonExistent"}
		err := manager.Update(plugin)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not installed")
	})
}

func TestUninstall(t *testing.T) {
	t.Run("uninstalls plugin successfully", func(t *testing.T) {
		manager, fs, pluginsDir := setupTestManager(t)

		plugin := Plugin{ID: "test-plugin", Name: "TestPlugin"}
		pluginPath := filepath.Join(pluginsDir, plugin.ID)
		err := fs.MkdirAll(pluginPath, 0755)
		require.NoError(t, err)

		err = manager.Uninstall(plugin)
		assert.NoError(t, err)

		exists, _ := afero.DirExists(fs, pluginPath)
		assert.False(t, exists)
	})

	t.Run("returns error when plugin not installed", func(t *testing.T) {
		manager, _, _ := setupTestManager(t)

		plugin := Plugin{ID: "non-existent", Name: "NonExistent"}
		err := manager.Uninstall(plugin)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "not installed")
	})
}

func TestListInstalled(t *testing.T) {
	t.Run("lists installed plugins", func(t *testing.T) {
		manager, fs, pluginsDir := setupTestManager(t)

		err := fs.MkdirAll(filepath.Join(pluginsDir, "Plugin1"), 0755)
		require.NoError(t, err)
		err = afero.WriteFile(fs, filepath.Join(pluginsDir, "Plugin1", "plugin.json"), []byte(`{"id":"Plugin1"}`), 0644)
		require.NoError(t, err)

		err = fs.MkdirAll(filepath.Join(pluginsDir, "Plugin2"), 0755)
		require.NoError(t, err)
		err = afero.WriteFile(fs, filepath.Join(pluginsDir, "Plugin2", "plugin.json"), []byte(`{"id":"Plugin2"}`), 0644)
		require.NoError(t, err)

		installed, err := manager.ListInstalled()
		assert.NoError(t, err)
		assert.Len(t, installed, 2)
		assert.Contains(t, installed, "Plugin1")
		assert.Contains(t, installed, "Plugin2")
	})

	t.Run("returns empty list when no plugins installed", func(t *testing.T) {
		manager, _, _ := setupTestManager(t)

		installed, err := manager.ListInstalled()
		assert.NoError(t, err)
		assert.Empty(t, installed)
	})

	t.Run("ignores files and .repos directory", func(t *testing.T) {
		manager, fs, pluginsDir := setupTestManager(t)

		err := fs.MkdirAll(pluginsDir, 0755)
		require.NoError(t, err)
		err = fs.MkdirAll(filepath.Join(pluginsDir, "Plugin1"), 0755)
		require.NoError(t, err)
		err = afero.WriteFile(fs, filepath.Join(pluginsDir, "Plugin1", "plugin.json"), []byte(`{"id":"Plugin1"}`), 0644)
		require.NoError(t, err)
		err = fs.MkdirAll(filepath.Join(pluginsDir, ".repos"), 0755)
		require.NoError(t, err)
		err = afero.WriteFile(fs, filepath.Join(pluginsDir, "README.md"), []byte("test"), 0644)
		require.NoError(t, err)

		installed, err := manager.ListInstalled()
		assert.NoError(t, err)
		assert.Len(t, installed, 1)
		assert.Equal(t, "Plugin1", installed[0])
	})
}

func TestManagerGetPluginsDir(t *testing.T) {
	manager, _, pluginsDir := setupTestManager(t)
	assert.Equal(t, pluginsDir, manager.GetPluginsDir())
}
