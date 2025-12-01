package freedesktop

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestAccountsState_Struct(t *testing.T) {
	state := AccountsState{
		Available: true,
		UserPath:  "/org/freedesktop/Accounts/User1000",
		RealName:  "Test User",
		UserName:  "testuser",
		Locked:    false,
		UID:       1000,
	}

	assert.True(t, state.Available)
	assert.Equal(t, "/org/freedesktop/Accounts/User1000", state.UserPath)
	assert.Equal(t, "Test User", state.RealName)
	assert.Equal(t, "testuser", state.UserName)
	assert.Equal(t, uint64(1000), state.UID)
	assert.False(t, state.Locked)
}

func TestSettingsState_Struct(t *testing.T) {
	state := SettingsState{
		Available:   true,
		ColorScheme: 1, // Dark mode
	}

	assert.True(t, state.Available)
	assert.Equal(t, uint32(1), state.ColorScheme)
}

func TestFreedeskState_Struct(t *testing.T) {
	state := FreedeskState{
		Accounts: AccountsState{
			Available: true,
			UserName:  "testuser",
			UID:       1000,
		},
		Settings: SettingsState{
			Available:   true,
			ColorScheme: 0, // Light mode
		},
	}

	assert.True(t, state.Accounts.Available)
	assert.Equal(t, "testuser", state.Accounts.UserName)
	assert.True(t, state.Settings.Available)
	assert.Equal(t, uint32(0), state.Settings.ColorScheme)
}

func TestAccountsState_DefaultValues(t *testing.T) {
	state := AccountsState{}

	assert.False(t, state.Available)
	assert.Empty(t, state.UserPath)
	assert.Empty(t, state.UserName)
	assert.Equal(t, uint64(0), state.UID)
}

func TestSettingsState_DefaultValues(t *testing.T) {
	state := SettingsState{}

	assert.False(t, state.Available)
	assert.Equal(t, uint32(0), state.ColorScheme)
}
