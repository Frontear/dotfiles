package network

import (
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestManager_GetState(t *testing.T) {
	state := &NetworkState{
		NetworkStatus: StatusWiFi,
		WiFiSSID:      "TestNetwork",
		WiFiConnected: true,
	}

	manager := &Manager{
		state:      state,
		stateMutex: sync.RWMutex{},
	}

	result := manager.GetState()
	assert.Equal(t, StatusWiFi, result.NetworkStatus)
	assert.Equal(t, "TestNetwork", result.WiFiSSID)
	assert.True(t, result.WiFiConnected)
}

func TestManager_NotifySubscribers(t *testing.T) {
	manager := &Manager{
		state: &NetworkState{
			NetworkStatus: StatusWiFi,
		},
		stateMutex:  sync.RWMutex{},
		subscribers: make(map[string]chan NetworkState),
		subMutex:    sync.RWMutex{},
		stopChan:    make(chan struct{}),
		dirty:       make(chan struct{}, 1),
	}
	manager.notifierWg.Add(1)
	go manager.notifier()

	// Subscribe a client
	ch := make(chan NetworkState, 10)
	manager.subMutex.Lock()
	manager.subscribers["test-client"] = ch
	manager.subMutex.Unlock()

	// Notify subscribers
	manager.notifySubscribers()

	// Check that state was sent (wait for debounce timer + some slack)
	select {
	case state := <-ch:
		assert.Equal(t, StatusWiFi, state.NetworkStatus)
	case <-time.After(200 * time.Millisecond):
		t.Fatal("did not receive state update")
	}

	close(manager.stopChan)
	manager.notifierWg.Wait()
}

func TestManager_NotifySubscribers_Debounce(t *testing.T) {
	manager := &Manager{
		state: &NetworkState{
			NetworkStatus: StatusWiFi,
		},
		stateMutex:  sync.RWMutex{},
		subscribers: make(map[string]chan NetworkState),
		subMutex:    sync.RWMutex{},
		stopChan:    make(chan struct{}),
		dirty:       make(chan struct{}, 1),
	}
	manager.notifierWg.Add(1)
	go manager.notifier()

	// Subscribe a client
	ch := make(chan NetworkState, 10)
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
		state:       &NetworkState{},
		stateMutex:  sync.RWMutex{},
		subscribers: make(map[string]chan NetworkState),
		subMutex:    sync.RWMutex{},
		stopChan:    make(chan struct{}),
	}

	// Add subscribers
	ch1 := make(chan NetworkState, 1)
	ch2 := make(chan NetworkState, 1)
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

func TestManager_Subscribe(t *testing.T) {
	manager := &Manager{
		state:       &NetworkState{},
		subscribers: make(map[string]chan NetworkState),
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
		state:       &NetworkState{},
		subscribers: make(map[string]chan NetworkState),
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

func TestNewManager(t *testing.T) {
	// This test will fail in environments without NetworkManager D-Bus
	// It's primarily for local testing
	t.Run("attempts to create manager", func(t *testing.T) {
		manager, err := NewManager()
		if err != nil {
			// Expected in test environments
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

func TestManager_GetState_ThreadSafe(t *testing.T) {
	manager := &Manager{
		state: &NetworkState{
			NetworkStatus: StatusWiFi,
			WiFiSSID:      "TestNetwork",
		},
		stateMutex: sync.RWMutex{},
	}

	// Test concurrent reads
	done := make(chan bool)
	for i := 0; i < 10; i++ {
		go func() {
			state := manager.GetState()
			assert.Equal(t, StatusWiFi, state.NetworkStatus)
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
