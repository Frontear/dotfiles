package network

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestIWDBackend_MarkIPConfigSeen(t *testing.T) {
	backend, _ := NewIWDBackend()

	att := &connectAttempt{
		ssid:     "TestNetwork",
		netPath:  "/net/connman/iwd/0/1/test",
		start:    time.Now(),
		deadline: time.Now().Add(15 * time.Second),
	}

	backend.attemptMutex.Lock()
	backend.curAttempt = att
	backend.attemptMutex.Unlock()

	backend.MarkIPConfigSeen()

	att.mu.Lock()
	assert.True(t, att.sawIPConfig, "sawIPConfig should be true after MarkIPConfigSeen")
	att.mu.Unlock()
}

func TestIWDBackend_MarkIPConfigSeen_NoAttempt(t *testing.T) {
	backend, _ := NewIWDBackend()

	backend.attemptMutex.Lock()
	backend.curAttempt = nil
	backend.attemptMutex.Unlock()

	backend.MarkIPConfigSeen()
}

func TestIWDBackend_OnPromptRetry(t *testing.T) {
	backend, _ := NewIWDBackend()

	att := &connectAttempt{
		ssid:     "TestNetwork",
		netPath:  "/net/connman/iwd/0/1/test",
		start:    time.Now(),
		deadline: time.Now().Add(15 * time.Second),
	}

	backend.attemptMutex.Lock()
	backend.curAttempt = att
	backend.attemptMutex.Unlock()

	backend.OnPromptRetry("TestNetwork")

	att.mu.Lock()
	assert.True(t, att.sawPromptRetry, "sawPromptRetry should be true after OnPromptRetry")
	att.mu.Unlock()
}

func TestIWDBackend_OnPromptRetry_WrongSSID(t *testing.T) {
	backend, _ := NewIWDBackend()

	att := &connectAttempt{
		ssid:     "TestNetwork",
		netPath:  "/net/connman/iwd/0/1/test",
		start:    time.Now(),
		deadline: time.Now().Add(15 * time.Second),
	}

	backend.attemptMutex.Lock()
	backend.curAttempt = att
	backend.attemptMutex.Unlock()

	backend.OnPromptRetry("DifferentNetwork")

	att.mu.Lock()
	assert.False(t, att.sawPromptRetry, "sawPromptRetry should remain false for different SSID")
	att.mu.Unlock()
}

func TestIWDBackend_ClassifyAttempt_BadCredentials_PromptRetry(t *testing.T) {
	backend, _ := NewIWDBackend()

	att := &connectAttempt{
		ssid:           "TestNetwork",
		netPath:        "/test",
		start:          time.Now().Add(-5 * time.Second),
		deadline:       time.Now().Add(10 * time.Second),
		sawPromptRetry: true,
	}

	code := backend.classifyAttempt(att)
	assert.Equal(t, "bad-credentials", code)
}

func TestIWDBackend_ClassifyAttempt_DhcpTimeout(t *testing.T) {
	backend, _ := NewIWDBackend()

	att := &connectAttempt{
		ssid:        "TestNetwork",
		netPath:     "/test",
		start:       time.Now().Add(-13 * time.Second),
		deadline:    time.Now().Add(2 * time.Second),
		sawAuthish:  true,
		sawIPConfig: false,
	}

	code := backend.classifyAttempt(att)
	assert.Equal(t, "dhcp-timeout", code)
}

func TestIWDBackend_ClassifyAttempt_AssocTimeout(t *testing.T) {
	backend, _ := NewIWDBackend()

	att := &connectAttempt{
		ssid:     "TestNetwork",
		netPath:  "/test",
		start:    time.Now().Add(-5 * time.Second),
		deadline: time.Now().Add(10 * time.Second),
	}

	backend.recentScansMu.Lock()
	backend.recentScans["TestNetwork"] = time.Now()
	backend.recentScansMu.Unlock()

	code := backend.classifyAttempt(att)
	assert.Equal(t, "assoc-timeout", code)
}

func TestIWDBackend_ClassifyAttempt_NoSuchSSID(t *testing.T) {
	backend, _ := NewIWDBackend()

	att := &connectAttempt{
		ssid:     "TestNetwork",
		netPath:  "/test",
		start:    time.Now().Add(-5 * time.Second),
		deadline: time.Now().Add(10 * time.Second),
	}

	code := backend.classifyAttempt(att)
	assert.Equal(t, "no-such-ssid", code)
}

func TestIWDBackend_MapIwdDBusError(t *testing.T) {
	backend, _ := NewIWDBackend()

	testCases := []struct {
		name     string
		expected string
	}{
		{"net.connman.iwd.Error.AlreadyConnected", "already-connected"},
		{"net.connman.iwd.Error.AuthenticationFailed", "bad-credentials"},
		{"net.connman.iwd.Error.InvalidKey", "bad-credentials"},
		{"net.connman.iwd.Error.IncorrectPassphrase", "bad-credentials"},
		{"net.connman.iwd.Error.NotFound", "no-such-ssid"},
		{"net.connman.iwd.Error.NotSupported", "connection-failed"},
		{"net.connman.iwd.Agent.Error.Canceled", "user-canceled"},
		{"net.connman.iwd.Error.Unknown", "connection-failed"},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			code := backend.mapIwdDBusError(tc.name)
			assert.Equal(t, tc.expected, code)
		})
	}
}

func TestConnectAttempt_Finalization(t *testing.T) {
	backend, _ := NewIWDBackend()
	backend.state = &BackendState{}

	att := &connectAttempt{
		ssid:     "TestNetwork",
		netPath:  "/test",
		start:    time.Now(),
		deadline: time.Now().Add(15 * time.Second),
	}

	backend.finalizeAttempt(att, "bad-credentials")

	att.mu.Lock()
	assert.True(t, att.finalized)
	att.mu.Unlock()

	backend.stateMutex.RLock()
	assert.False(t, backend.state.IsConnecting)
	assert.Empty(t, backend.state.ConnectingSSID)
	assert.Equal(t, "bad-credentials", backend.state.LastError)
	backend.stateMutex.RUnlock()
}

func TestConnectAttempt_DoubleFinalization(t *testing.T) {
	backend, _ := NewIWDBackend()
	backend.state = &BackendState{}

	att := &connectAttempt{
		ssid:     "TestNetwork",
		netPath:  "/test",
		start:    time.Now(),
		deadline: time.Now().Add(15 * time.Second),
	}

	backend.finalizeAttempt(att, "bad-credentials")
	backend.finalizeAttempt(att, "dhcp-timeout")

	backend.stateMutex.RLock()
	assert.Equal(t, "bad-credentials", backend.state.LastError)
	backend.stateMutex.RUnlock()
}
