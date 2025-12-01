package loginctl

import (
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestManager_GetState(t *testing.T) {
	state := &SessionState{
		SessionID:    "1",
		Locked:       false,
		Active:       true,
		IdleHint:     false,
		SessionType:  "wayland",
		SessionClass: "user",
		UserName:     "testuser",
	}

	manager := &Manager{
		state:      state,
		stateMutex: sync.RWMutex{},
	}

	result := manager.GetState()
	assert.Equal(t, "1", result.SessionID)
	assert.False(t, result.Locked)
	assert.True(t, result.Active)
	assert.Equal(t, "wayland", result.SessionType)
	assert.Equal(t, "testuser", result.UserName)
}

func TestManager_Subscribe(t *testing.T) {
	manager := &Manager{
		state:       &SessionState{},
		subscribers: make(map[string]chan SessionState),
		subMutex:    sync.RWMutex{},
	}

	ch := manager.Subscribe("test-client")
	assert.NotNil(t, ch)
	assert.Equal(t, 64, cap(ch))

	manager.subMutex.RLock()
	_, exists := manager.subscribers["test-client"]
	manager.subMutex.RUnlock()
	assert.True(t, exists)
}

func TestManager_Unsubscribe(t *testing.T) {
	manager := &Manager{
		state:       &SessionState{},
		subscribers: make(map[string]chan SessionState),
		subMutex:    sync.RWMutex{},
	}

	// Subscribe first
	ch := manager.Subscribe("test-client")

	// Unsubscribe
	manager.Unsubscribe("test-client")

	// Check channel is closed
	_, ok := <-ch
	assert.False(t, ok)

	// Check client is removed
	manager.subMutex.RLock()
	_, exists := manager.subscribers["test-client"]
	manager.subMutex.RUnlock()
	assert.False(t, exists)
}

func TestManager_Unsubscribe_NonExistent(t *testing.T) {
	manager := &Manager{
		state:       &SessionState{},
		subscribers: make(map[string]chan SessionState),
		subMutex:    sync.RWMutex{},
	}

	// Unsubscribe a non-existent client should not panic
	assert.NotPanics(t, func() {
		manager.Unsubscribe("non-existent")
	})
}

func TestManager_NotifySubscribers(t *testing.T) {
	manager := &Manager{
		state: &SessionState{
			SessionID: "1",
			Locked:    false,
		},
		stateMutex:  sync.RWMutex{},
		subscribers: make(map[string]chan SessionState),
		subMutex:    sync.RWMutex{},
		stopChan:    make(chan struct{}),
		dirty:       make(chan struct{}, 1),
	}
	manager.notifierWg.Add(1)
	go manager.notifier()

	// Subscribe a client
	ch := make(chan SessionState, 10)
	manager.subMutex.Lock()
	manager.subscribers["test-client"] = ch
	manager.subMutex.Unlock()

	// Notify subscribers
	manager.notifySubscribers()

	// Check that state was sent (wait for debounce timer + some slack)
	select {
	case state := <-ch:
		assert.Equal(t, "1", state.SessionID)
		assert.False(t, state.Locked)
	case <-time.After(200 * time.Millisecond):
		t.Fatal("did not receive state update")
	}

	close(manager.stopChan)
	manager.notifierWg.Wait()
}

func TestManager_NotifySubscribers_Debounce(t *testing.T) {
	manager := &Manager{
		state: &SessionState{
			SessionID: "1",
			Locked:    false,
		},
		stateMutex:  sync.RWMutex{},
		subscribers: make(map[string]chan SessionState),
		subMutex:    sync.RWMutex{},
		stopChan:    make(chan struct{}),
		dirty:       make(chan struct{}, 1),
	}
	manager.notifierWg.Add(1)
	go manager.notifier()

	// Subscribe a client
	ch := make(chan SessionState, 10)
	manager.subMutex.Lock()
	manager.subscribers["test-client"] = ch
	manager.subMutex.Unlock()

	// Send multiple rapid notifications
	manager.notifySubscribers()
	manager.notifySubscribers()
	manager.notifySubscribers()

	// Should only receive one state update due to debouncing
	receivedCount := 0
	timeout := time.After(200 * time.Millisecond)
	for {
		select {
		case <-ch:
			receivedCount++
		case <-timeout:
			assert.Equal(t, 1, receivedCount, "should receive exactly one debounced update")
			close(manager.stopChan)
			manager.notifierWg.Wait()
			return
		}
	}
}

func TestManager_Close(t *testing.T) {
	manager := &Manager{
		state:       &SessionState{},
		stateMutex:  sync.RWMutex{},
		subscribers: make(map[string]chan SessionState),
		subMutex:    sync.RWMutex{},
		stopChan:    make(chan struct{}),
	}

	// Add subscribers
	ch1 := make(chan SessionState, 1)
	ch2 := make(chan SessionState, 1)
	manager.subMutex.Lock()
	manager.subscribers["client1"] = ch1
	manager.subscribers["client2"] = ch2
	manager.subMutex.Unlock()

	// Close manager
	manager.Close()

	// Check that stopChan is closed
	select {
	case <-manager.stopChan:
		// Expected
	case <-time.After(100 * time.Millisecond):
		t.Fatal("stopChan not closed")
	}

	// Check that subscriber channels are closed
	_, ok1 := <-ch1
	_, ok2 := <-ch2
	assert.False(t, ok1, "ch1 should be closed")
	assert.False(t, ok2, "ch2 should be closed")

	// Check that subscribers map is reset
	assert.Len(t, manager.subscribers, 0)
}

func TestManager_GetState_ThreadSafe(t *testing.T) {
	manager := &Manager{
		state: &SessionState{
			SessionID: "1",
			Locked:    false,
			Active:    true,
		},
		stateMutex: sync.RWMutex{},
	}

	// Test concurrent reads
	done := make(chan bool)
	for i := 0; i < 10; i++ {
		go func() {
			state := manager.GetState()
			assert.Equal(t, "1", state.SessionID)
			assert.True(t, state.Active)
			done <- true
		}()
	}

	// Wait for all goroutines to complete
	for i := 0; i < 10; i++ {
		select {
		case <-done:
		case <-time.After(1 * time.Second):
			t.Fatal("timeout waiting for goroutines")
		}
	}
}

func TestStateChangedMeaningfully(t *testing.T) {
	tests := []struct {
		name     string
		old      *SessionState
		new      *SessionState
		expected bool
	}{
		{
			name:     "no change",
			old:      &SessionState{Locked: false, Active: true, IdleHint: false},
			new:      &SessionState{Locked: false, Active: true, IdleHint: false},
			expected: false,
		},
		{
			name:     "locked changed",
			old:      &SessionState{Locked: false, Active: true, IdleHint: false},
			new:      &SessionState{Locked: true, Active: true, IdleHint: false},
			expected: true,
		},
		{
			name:     "active changed",
			old:      &SessionState{Locked: false, Active: true, IdleHint: false},
			new:      &SessionState{Locked: false, Active: false, IdleHint: false},
			expected: true,
		},
		{
			name:     "idle hint changed",
			old:      &SessionState{Locked: false, Active: true, IdleHint: false},
			new:      &SessionState{Locked: false, Active: true, IdleHint: true},
			expected: true,
		},
		{
			name:     "locked hint changed",
			old:      &SessionState{Locked: false, Active: true, LockedHint: false},
			new:      &SessionState{Locked: false, Active: true, LockedHint: true},
			expected: true,
		},
		{
			name:     "preparing for sleep changed",
			old:      &SessionState{Locked: false, Active: true, PreparingForSleep: false},
			new:      &SessionState{Locked: false, Active: true, PreparingForSleep: true},
			expected: true,
		},
		{
			name:     "non-meaningful change (username)",
			old:      &SessionState{Locked: false, Active: true, UserName: "user1"},
			new:      &SessionState{Locked: false, Active: true, UserName: "user2"},
			expected: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := stateChangedMeaningfully(tt.old, tt.new)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestManager_SnapshotState(t *testing.T) {
	manager := &Manager{
		state: &SessionState{
			SessionID: "1",
			Locked:    false,
			Active:    true,
			UserName:  "testuser",
		},
		stateMutex: sync.RWMutex{},
	}

	snapshot := manager.snapshotState()
	assert.Equal(t, "1", snapshot.SessionID)
	assert.False(t, snapshot.Locked)
	assert.True(t, snapshot.Active)
	assert.Equal(t, "testuser", snapshot.UserName)

	// Modifying snapshot should not affect manager's state
	snapshot.Locked = true
	assert.False(t, manager.state.Locked)
}

func TestNewManager(t *testing.T) {
	// This test will fail in environments without systemd/login1 D-Bus
	// It's primarily for local testing with systemd
	t.Run("attempts to create manager", func(t *testing.T) {
		manager, err := NewManager()
		if err != nil {
			// Expected in test environments without systemd
			assert.Nil(t, manager)
		} else {
			assert.NotNil(t, manager)
			assert.NotNil(t, manager.state)
			assert.NotNil(t, manager.subscribers)
			assert.NotNil(t, manager.stopChan)

			// Clean up
			manager.Close()
		}
	})
}
