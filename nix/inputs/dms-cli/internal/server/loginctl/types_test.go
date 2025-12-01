package loginctl

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestEventType_Constants(t *testing.T) {
	assert.Equal(t, EventType("state_changed"), EventStateChanged)
	assert.Equal(t, EventType("lock"), EventLock)
	assert.Equal(t, EventType("unlock"), EventUnlock)
	assert.Equal(t, EventType("prepare_for_sleep"), EventPrepareForSleep)
	assert.Equal(t, EventType("idle_hint_changed"), EventIdleHintChanged)
	assert.Equal(t, EventType("locked_hint_changed"), EventLockedHintChanged)
}

func TestSessionState_Struct(t *testing.T) {
	state := SessionState{
		SessionID:         "1",
		SessionPath:       "/org/freedesktop/login1/session/_31",
		Locked:            false,
		Active:            true,
		IdleHint:          false,
		IdleSinceHint:     0,
		LockedHint:        false,
		SessionType:       "wayland",
		SessionClass:      "user",
		User:              1000,
		UserName:          "testuser",
		RemoteHost:        "",
		Service:           "gdm-password",
		TTY:               "tty2",
		Display:           ":1",
		Remote:            false,
		Seat:              "seat0",
		VTNr:              2,
		PreparingForSleep: false,
	}

	assert.Equal(t, "1", state.SessionID)
	assert.True(t, state.Active)
	assert.False(t, state.Locked)
	assert.Equal(t, "wayland", state.SessionType)
	assert.Equal(t, uint32(1000), state.User)
	assert.Equal(t, "testuser", state.UserName)
}

func TestSessionEvent_Struct(t *testing.T) {
	state := SessionState{
		SessionID: "1",
		Locked:    true,
	}

	event := SessionEvent{
		Type: EventLock,
		Data: state,
	}

	assert.Equal(t, EventLock, event.Type)
	assert.Equal(t, "1", event.Data.SessionID)
	assert.True(t, event.Data.Locked)
}
