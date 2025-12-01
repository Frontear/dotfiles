package bluez

import (
	"context"
	"testing"
	"time"
)

func TestBrokerIntegration(t *testing.T) {
	broker := NewSubscriptionBroker(nil)
	ctx := context.Background()

	req := PromptRequest{
		DevicePath:  "/org/bluez/test",
		DeviceName:  "TestDevice",
		RequestType: "pin",
		Fields:      []string{"pin"},
	}

	token, err := broker.Ask(ctx, req)
	if err != nil {
		t.Fatalf("Ask failed: %v", err)
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
}
