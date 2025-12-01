package freedesktop

import (
	"sync"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestManager_GetState(t *testing.T) {
	state := &FreedeskState{
		Accounts: AccountsState{
			Available: true,
			UserName:  "testuser",
			RealName:  "Test User",
			UID:       1000,
		},
		Settings: SettingsState{
			Available:   true,
			ColorScheme: 1,
		},
	}

	manager := &Manager{
		state:      state,
		stateMutex: sync.RWMutex{},
	}

	result := manager.GetState()
	assert.True(t, result.Accounts.Available)
	assert.Equal(t, "testuser", result.Accounts.UserName)
	assert.Equal(t, "Test User", result.Accounts.RealName)
	assert.Equal(t, uint64(1000), result.Accounts.UID)
	assert.True(t, result.Settings.Available)
	assert.Equal(t, uint32(1), result.Settings.ColorScheme)
}

func TestManager_GetState_ThreadSafe(t *testing.T) {
	manager := &Manager{
		state: &FreedeskState{
			Accounts: AccountsState{
				Available: true,
				UserName:  "testuser",
			},
			Settings: SettingsState{
				Available:   true,
				ColorScheme: 1,
			},
		},
		stateMutex: sync.RWMutex{},
	}

	// Test concurrent reads
	done := make(chan bool)
	for i := 0; i < 10; i++ {
		go func() {
			state := manager.GetState()
			assert.True(t, state.Accounts.Available)
			assert.Equal(t, "testuser", state.Accounts.UserName)
			done <- true
		}()
	}

	// Wait for all goroutines to complete
	for i := 0; i < 10; i++ {
		<-done
	}
}

func TestManager_Close(t *testing.T) {
	manager := &Manager{
		state:       &FreedeskState{},
		stateMutex:  sync.RWMutex{},
		systemConn:  nil, // Would be set in real scenario
		sessionConn: nil,
	}

	// Should not panic even with nil connections
	assert.NotPanics(t, func() {
		manager.Close()
	})
}

func TestNewManager(t *testing.T) {
	// This test will fail in environments without freedesktop D-Bus services
	// It's primarily for local testing with proper desktop environment
	t.Run("attempts to create manager", func(t *testing.T) {
		manager, err := NewManager()
		if err != nil {
			// Expected in test environments without freedesktop services
			assert.Nil(t, manager)
		} else {
			assert.NotNil(t, manager)
			assert.NotNil(t, manager.state)
			assert.NotNil(t, manager.systemConn)

			// Clean up
			manager.Close()
		}
	})
}

func TestManager_GetState_EmptyState(t *testing.T) {
	manager := &Manager{
		state:      &FreedeskState{},
		stateMutex: sync.RWMutex{},
	}

	result := manager.GetState()
	assert.False(t, result.Accounts.Available)
	assert.Empty(t, result.Accounts.UserName)
	assert.False(t, result.Settings.Available)
	assert.Equal(t, uint32(0), result.Settings.ColorScheme)
}

func TestManager_AccountsState_Modification(t *testing.T) {
	manager := &Manager{
		state: &FreedeskState{
			Accounts: AccountsState{
				Available: true,
				UserName:  "testuser",
			},
		},
		stateMutex: sync.RWMutex{},
	}

	// Get state and modify it
	state := manager.GetState()
	state.Accounts.UserName = "modifieduser"

	// Original state should remain unchanged (copy semantics)
	original := manager.GetState()
	assert.Equal(t, "testuser", original.Accounts.UserName)
}

func TestManager_SettingsState_Modification(t *testing.T) {
	manager := &Manager{
		state: &FreedeskState{
			Settings: SettingsState{
				Available:   true,
				ColorScheme: 0,
			},
		},
		stateMutex: sync.RWMutex{},
	}

	// Get state and modify it
	state := manager.GetState()
	state.Settings.ColorScheme = 1

	// Original state should remain unchanged (copy semantics)
	original := manager.GetState()
	assert.Equal(t, uint32(0), original.Settings.ColorScheme)
}
