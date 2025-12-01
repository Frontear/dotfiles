package bluez

import (
	"context"
	"crypto/rand"
	"encoding/hex"
)

type PromptBroker interface {
	Ask(ctx context.Context, req PromptRequest) (token string, err error)
	Wait(ctx context.Context, token string) (PromptReply, error)
	Resolve(token string, reply PromptReply) error
}

func generateToken() (string, error) {
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return hex.EncodeToString(bytes), nil
}
