package network

// NewTestManager creates a Manager for testing with a provided backend
func NewTestManager(backend Backend, state *NetworkState) *Manager {
	if state == nil {
		state = &NetworkState{}
	}
	return &Manager{
		backend:     backend,
		state:       state,
		subscribers: make(map[string]chan NetworkState),
		stopChan:    make(chan struct{}),
		dirty:       make(chan struct{}, 1),
	}
}
