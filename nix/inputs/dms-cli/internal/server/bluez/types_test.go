package bluez

import (
	"encoding/json"
	"testing"
)

func TestBluetoothStateJSON(t *testing.T) {
	state := BluetoothState{
		Powered:     true,
		Discovering: false,
		Devices: []Device{
			{
				Path:      "/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF",
				Address:   "AA:BB:CC:DD:EE:FF",
				Name:      "TestDevice",
				Alias:     "My Device",
				Paired:    true,
				Trusted:   false,
				Connected: true,
				Class:     0x240418,
				Icon:      "audio-headset",
				RSSI:      -50,
			},
		},
		PairedDevices: []Device{
			{
				Path:    "/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF",
				Address: "AA:BB:CC:DD:EE:FF",
				Paired:  true,
			},
		},
		ConnectedDevices: []Device{
			{
				Path:      "/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF",
				Address:   "AA:BB:CC:DD:EE:FF",
				Connected: true,
			},
		},
	}

	data, err := json.Marshal(state)
	if err != nil {
		t.Fatalf("failed to marshal state: %v", err)
	}

	var decoded BluetoothState
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal state: %v", err)
	}

	if decoded.Powered != state.Powered {
		t.Errorf("expected Powered=%v, got %v", state.Powered, decoded.Powered)
	}

	if len(decoded.Devices) != 1 {
		t.Fatalf("expected 1 device, got %d", len(decoded.Devices))
	}

	if decoded.Devices[0].Address != "AA:BB:CC:DD:EE:FF" {
		t.Errorf("expected address AA:BB:CC:DD:EE:FF, got %s", decoded.Devices[0].Address)
	}
}

func TestDeviceJSON(t *testing.T) {
	device := Device{
		Path:          "/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF",
		Address:       "AA:BB:CC:DD:EE:FF",
		Name:          "TestDevice",
		Alias:         "My Device",
		Paired:        true,
		Trusted:       true,
		Blocked:       false,
		Connected:     true,
		Class:         0x240418,
		Icon:          "audio-headset",
		RSSI:          -50,
		LegacyPairing: false,
	}

	data, err := json.Marshal(device)
	if err != nil {
		t.Fatalf("failed to marshal device: %v", err)
	}

	var decoded Device
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal device: %v", err)
	}

	if decoded.Address != device.Address {
		t.Errorf("expected Address=%s, got %s", device.Address, decoded.Address)
	}

	if decoded.Name != device.Name {
		t.Errorf("expected Name=%s, got %s", device.Name, decoded.Name)
	}

	if decoded.Paired != device.Paired {
		t.Errorf("expected Paired=%v, got %v", device.Paired, decoded.Paired)
	}

	if decoded.RSSI != device.RSSI {
		t.Errorf("expected RSSI=%d, got %d", device.RSSI, decoded.RSSI)
	}
}

func TestPairingPromptJSON(t *testing.T) {
	passkey := uint32(123456)
	prompt := PairingPrompt{
		Token:       "test-token",
		DevicePath:  "/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF",
		DeviceName:  "TestDevice",
		DeviceAddr:  "AA:BB:CC:DD:EE:FF",
		RequestType: "confirm",
		Fields:      []string{"decision"},
		Hints:       []string{},
		Passkey:     &passkey,
	}

	data, err := json.Marshal(prompt)
	if err != nil {
		t.Fatalf("failed to marshal prompt: %v", err)
	}

	var decoded PairingPrompt
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal prompt: %v", err)
	}

	if decoded.Token != prompt.Token {
		t.Errorf("expected Token=%s, got %s", prompt.Token, decoded.Token)
	}

	if decoded.DeviceName != prompt.DeviceName {
		t.Errorf("expected DeviceName=%s, got %s", prompt.DeviceName, decoded.DeviceName)
	}

	if decoded.Passkey == nil {
		t.Fatal("expected non-nil Passkey")
	}

	if *decoded.Passkey != *prompt.Passkey {
		t.Errorf("expected Passkey=%d, got %d", *prompt.Passkey, *decoded.Passkey)
	}
}

func TestPromptReplyJSON(t *testing.T) {
	reply := PromptReply{
		Secrets: map[string]string{
			"pin":     "1234",
			"passkey": "567890",
		},
		Accept: true,
		Cancel: false,
	}

	data, err := json.Marshal(reply)
	if err != nil {
		t.Fatalf("failed to marshal reply: %v", err)
	}

	var decoded PromptReply
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal reply: %v", err)
	}

	if decoded.Secrets["pin"] != reply.Secrets["pin"] {
		t.Errorf("expected pin=%s, got %s", reply.Secrets["pin"], decoded.Secrets["pin"])
	}

	if decoded.Accept != reply.Accept {
		t.Errorf("expected Accept=%v, got %v", reply.Accept, decoded.Accept)
	}
}

func TestPromptRequestJSON(t *testing.T) {
	passkey := uint32(123456)
	req := PromptRequest{
		DevicePath:  "/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF",
		DeviceName:  "TestDevice",
		DeviceAddr:  "AA:BB:CC:DD:EE:FF",
		RequestType: "confirm",
		Fields:      []string{"decision"},
		Hints:       []string{"hint1", "hint2"},
		Passkey:     &passkey,
	}

	data, err := json.Marshal(req)
	if err != nil {
		t.Fatalf("failed to marshal request: %v", err)
	}

	var decoded PromptRequest
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal request: %v", err)
	}

	if decoded.DevicePath != req.DevicePath {
		t.Errorf("expected DevicePath=%s, got %s", req.DevicePath, decoded.DevicePath)
	}

	if decoded.RequestType != req.RequestType {
		t.Errorf("expected RequestType=%s, got %s", req.RequestType, decoded.RequestType)
	}

	if len(decoded.Fields) != len(req.Fields) {
		t.Errorf("expected %d fields, got %d", len(req.Fields), len(decoded.Fields))
	}
}
