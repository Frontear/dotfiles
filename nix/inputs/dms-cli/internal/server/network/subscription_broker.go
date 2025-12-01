package network

import (
	"context"
	"fmt"
	"sync"

	"github.com/AvengeMedia/danklinux/internal/errdefs"
	"github.com/AvengeMedia/danklinux/internal/log"
)

type SubscriptionBroker struct {
	mu                 sync.RWMutex
	pending            map[string]chan PromptReply
	requests           map[string]PromptRequest
	pathSettingToToken map[string]string
	broadcastPrompt    func(CredentialPrompt)
}

func NewSubscriptionBroker(broadcastPrompt func(CredentialPrompt)) PromptBroker {
	return &SubscriptionBroker{
		pending:            make(map[string]chan PromptReply),
		requests:           make(map[string]PromptRequest),
		pathSettingToToken: make(map[string]string),
		broadcastPrompt:    broadcastPrompt,
	}
}

func (b *SubscriptionBroker) Ask(ctx context.Context, req PromptRequest) (string, error) {
	pathSettingKey := fmt.Sprintf("%s:%s", req.ConnectionPath, req.SettingName)

	b.mu.Lock()
	existingToken, alreadyPending := b.pathSettingToToken[pathSettingKey]
	b.mu.Unlock()

	if alreadyPending {
		log.Infof("[SubscriptionBroker] Duplicate prompt for %s, returning existing token", pathSettingKey)
		return existingToken, nil
	}

	token, err := generateToken()
	if err != nil {
		return "", err
	}

	replyChan := make(chan PromptReply, 1)
	b.mu.Lock()
	b.pending[token] = replyChan
	b.requests[token] = req
	b.pathSettingToToken[pathSettingKey] = token
	b.mu.Unlock()

	if b.broadcastPrompt != nil {
		prompt := CredentialPrompt{
			Token:          token,
			Name:           req.Name,
			SSID:           req.SSID,
			ConnType:       req.ConnType,
			VpnService:     req.VpnService,
			Setting:        req.SettingName,
			Fields:         req.Fields,
			Hints:          req.Hints,
			Reason:         req.Reason,
			ConnectionId:   req.ConnectionId,
			ConnectionUuid: req.ConnectionUuid,
		}
		b.broadcastPrompt(prompt)
	}

	return token, nil
}

func (b *SubscriptionBroker) Wait(ctx context.Context, token string) (PromptReply, error) {
	b.mu.RLock()
	replyChan, exists := b.pending[token]
	b.mu.RUnlock()

	if !exists {
		return PromptReply{}, fmt.Errorf("unknown token: %s", token)
	}

	select {
	case <-ctx.Done():
		b.cleanup(token)
		return PromptReply{}, errdefs.ErrSecretPromptTimeout
	case reply := <-replyChan:
		b.cleanup(token)
		if reply.Cancel {
			return reply, errdefs.ErrSecretPromptCancelled
		}
		return reply, nil
	}
}

func (b *SubscriptionBroker) Resolve(token string, reply PromptReply) error {
	b.mu.RLock()
	replyChan, exists := b.pending[token]
	b.mu.RUnlock()

	if !exists {
		log.Warnf("[SubscriptionBroker] Resolve: unknown or expired token: %s", token)
		return fmt.Errorf("unknown or expired token: %s", token)
	}

	select {
	case replyChan <- reply:
		return nil
	default:
		log.Warnf("[SubscriptionBroker] Resolve: failed to deliver reply for token %s (channel full or closed)", token)
		return fmt.Errorf("failed to deliver reply for token: %s", token)
	}
}

func (b *SubscriptionBroker) cleanup(token string) {
	b.mu.Lock()
	defer b.mu.Unlock()

	if req, exists := b.requests[token]; exists {
		pathSettingKey := fmt.Sprintf("%s:%s", req.ConnectionPath, req.SettingName)
		delete(b.pathSettingToToken, pathSettingKey)
	}

	delete(b.pending, token)
	delete(b.requests, token)
}

func (b *SubscriptionBroker) Cancel(path string, setting string) error {
	pathSettingKey := fmt.Sprintf("%s:%s", path, setting)

	b.mu.Lock()
	token, exists := b.pathSettingToToken[pathSettingKey]
	b.mu.Unlock()

	if !exists {
		log.Infof("[SubscriptionBroker] Cancel: no pending prompt for %s", pathSettingKey)
		return nil
	}

	log.Infof("[SubscriptionBroker] Cancelling prompt for %s (token=%s)", pathSettingKey, token)

	reply := PromptReply{
		Cancel: true,
	}

	return b.Resolve(token, reply)
}
