package bluez

import (
	"context"
	"testing"
	"time"
)

func TestSubscriptionBrokerAskWait(t *testing.T) {
	promptReceived := false
	broker := NewSubscriptionBroker(func(p PairingPrompt) {
		promptReceived = true
		if p.Token == "" {
			t.Error("expected token to be non-empty")
		}
		if p.DeviceName != "TestDevice" {
			t.Errorf("expected DeviceName=TestDevice, got %s", p.DeviceName)
		}
	})

	ctx := context.Background()
	req := PromptRequest{
		DevicePath:  "/org/bluez/test",
		DeviceName:  "TestDevice",
		DeviceAddr:  "AA:BB:CC:DD:EE:FF",
		RequestType: "pin",
		Fields:      []string{"pin"},
	}

	token, err := broker.Ask(ctx, req)
	if err != nil {
		t.Fatalf("Ask failed: %v", err)
	}

	if token == "" {
		t.Fatal("expected non-empty token")
	}

	if !promptReceived {
		t.Fatal("expected prompt broadcast to be called")
	}

	go func() {
		time.Sleep(50 * time.Millisecond)
		broker.Resolve(token, PromptReply{
			Secrets: map[string]string{"pin": "1234"},
			Accept:  true,
		})
	}()

	reply, err := broker.Wait(ctx, token)
	if err != nil {
		t.Fatalf("Wait failed: %v", err)
	}

	if reply.Secrets["pin"] != "1234" {
		t.Errorf("expected pin=1234, got %s", reply.Secrets["pin"])
	}

	if !reply.Accept {
		t.Error("expected Accept=true")
	}
}

func TestSubscriptionBrokerTimeout(t *testing.T) {
	broker := NewSubscriptionBroker(nil)

	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()

	req := PromptRequest{
		DevicePath:  "/org/bluez/test",
		DeviceName:  "TestDevice",
		RequestType: "passkey",
		Fields:      []string{"passkey"},
	}

	token, err := broker.Ask(ctx, req)
	if err != nil {
		t.Fatalf("Ask failed: %v", err)
	}

	_, err = broker.Wait(ctx, token)
	if err == nil {
		t.Fatal("expected timeout error")
	}
}

func TestSubscriptionBrokerCancel(t *testing.T) {
	broker := NewSubscriptionBroker(nil)

	ctx := context.Background()
	req := PromptRequest{
		DevicePath:  "/org/bluez/test",
		DeviceName:  "TestDevice",
		RequestType: "confirm",
		Fields:      []string{"decision"},
	}

	token, err := broker.Ask(ctx, req)
	if err != nil {
		t.Fatalf("Ask failed: %v", err)
	}

	go func() {
		time.Sleep(50 * time.Millisecond)
		broker.Resolve(token, PromptReply{
			Cancel: true,
		})
	}()

	_, err = broker.Wait(ctx, token)
	if err == nil {
		t.Fatal("expected cancelled error")
	}
}

func TestSubscriptionBrokerUnknownToken(t *testing.T) {
	broker := NewSubscriptionBroker(nil)

	ctx := context.Background()
	_, err := broker.Wait(ctx, "invalid-token")
	if err == nil {
		t.Fatal("expected error for unknown token")
	}
}

func TestGenerateToken(t *testing.T) {
	token1, err := generateToken()
	if err != nil {
		t.Fatalf("generateToken failed: %v", err)
	}

	token2, err := generateToken()
	if err != nil {
		t.Fatalf("generateToken failed: %v", err)
	}

	if token1 == token2 {
		t.Error("expected unique tokens")
	}

	if len(token1) != 32 {
		t.Errorf("expected token length 32, got %d", len(token1))
	}
}

func TestSubscriptionBrokerResolveUnknownToken(t *testing.T) {
	broker := NewSubscriptionBroker(nil)

	err := broker.Resolve("unknown-token", PromptReply{
		Secrets: map[string]string{"test": "value"},
	})
	if err == nil {
		t.Fatal("expected error for unknown token")
	}
}

func TestSubscriptionBrokerMultipleRequests(t *testing.T) {
	broker := NewSubscriptionBroker(nil)
	ctx := context.Background()

	req1 := PromptRequest{
		DevicePath:  "/org/bluez/test1",
		DeviceName:  "Device1",
		RequestType: "pin",
		Fields:      []string{"pin"},
	}

	req2 := PromptRequest{
		DevicePath:  "/org/bluez/test2",
		DeviceName:  "Device2",
		RequestType: "passkey",
		Fields:      []string{"passkey"},
	}

	token1, err := broker.Ask(ctx, req1)
	if err != nil {
		t.Fatalf("Ask1 failed: %v", err)
	}

	token2, err := broker.Ask(ctx, req2)
	if err != nil {
		t.Fatalf("Ask2 failed: %v", err)
	}

	if token1 == token2 {
		t.Error("expected different tokens")
	}

	go func() {
		time.Sleep(50 * time.Millisecond)
		broker.Resolve(token1, PromptReply{
			Secrets: map[string]string{"pin": "1234"},
			Accept:  true,
		})
		broker.Resolve(token2, PromptReply{
			Secrets: map[string]string{"passkey": "567890"},
			Accept:  true,
		})
	}()

	reply1, err := broker.Wait(ctx, token1)
	if err != nil {
		t.Fatalf("Wait1 failed: %v", err)
	}

	reply2, err := broker.Wait(ctx, token2)
	if err != nil {
		t.Fatalf("Wait2 failed: %v", err)
	}

	if reply1.Secrets["pin"] != "1234" {
		t.Errorf("expected pin=1234, got %s", reply1.Secrets["pin"])
	}

	if reply2.Secrets["passkey"] != "567890" {
		t.Errorf("expected passkey=567890, got %s", reply2.Secrets["passkey"])
	}
}
