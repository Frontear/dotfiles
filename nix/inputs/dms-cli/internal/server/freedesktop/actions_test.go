package freedesktop

import (
	"sync"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestManager_SetIconFile(t *testing.T) {
	t.Run("accounts not available", func(t *testing.T) {
		manager := &Manager{
			state: &FreedeskState{
				Accounts: AccountsState{
					Available: false,
				},
			},
			stateMutex: sync.RWMutex{},
		}

		err := manager.SetIconFile("/path/to/icon.png")
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "accounts service not available")
	})
}

func TestManager_SetRealName(t *testing.T) {
	t.Run("accounts not available", func(t *testing.T) {
		manager := &Manager{
			state: &FreedeskState{
				Accounts: AccountsState{
					Available: false,
				},
			},
			stateMutex: sync.RWMutex{},
		}

		err := manager.SetRealName("New Name")
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "accounts service not available")
	})
}

func TestManager_SetEmail(t *testing.T) {
	t.Run("accounts not available", func(t *testing.T) {
		manager := &Manager{
			state: &FreedeskState{
				Accounts: AccountsState{
					Available: false,
				},
			},
			stateMutex: sync.RWMutex{},
		}

		err := manager.SetEmail("test@example.com")
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "accounts service not available")
	})
}

func TestManager_SetLanguage(t *testing.T) {
	t.Run("accounts not available", func(t *testing.T) {
		manager := &Manager{
			state: &FreedeskState{
				Accounts: AccountsState{
					Available: false,
				},
			},
			stateMutex: sync.RWMutex{},
		}

		err := manager.SetLanguage("en_US.UTF-8")
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "accounts service not available")
	})
}

func TestManager_SetLocation(t *testing.T) {
	t.Run("accounts not available", func(t *testing.T) {
		manager := &Manager{
			state: &FreedeskState{
				Accounts: AccountsState{
					Available: false,
				},
			},
			stateMutex: sync.RWMutex{},
		}

		err := manager.SetLocation("Test Location")
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "accounts service not available")
	})
}

func TestManager_GetUserIconFile(t *testing.T) {
	t.Run("accounts not available", func(t *testing.T) {
		manager := &Manager{
			state: &FreedeskState{
				Accounts: AccountsState{
					Available: false,
				},
			},
			stateMutex: sync.RWMutex{},
		}

		iconFile, err := manager.GetUserIconFile("testuser")
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "accounts service not available")
		assert.Empty(t, iconFile)
	})
}

func TestManager_UpdateAccountsState(t *testing.T) {
	t.Run("accounts not available", func(t *testing.T) {
		manager := &Manager{
			state: &FreedeskState{
				Accounts: AccountsState{
					Available: false,
				},
			},
			stateMutex: sync.RWMutex{},
		}

		err := manager.updateAccountsState()
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "accounts service not available")
	})
}

func TestManager_UpdateSettingsState(t *testing.T) {
	t.Run("settings not available", func(t *testing.T) {
		manager := &Manager{
			state: &FreedeskState{
				Settings: SettingsState{
					Available: false,
				},
			},
			stateMutex: sync.RWMutex{},
		}

		err := manager.updateSettingsState()
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "settings portal not available")
	})
}
