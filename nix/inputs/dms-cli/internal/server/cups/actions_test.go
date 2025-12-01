package cups

import (
	"errors"
	"testing"
	"time"

	mocks_cups "github.com/AvengeMedia/danklinux/internal/mocks/cups"
	"github.com/AvengeMedia/danklinux/pkg/ipp"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func TestManager_GetPrinters(t *testing.T) {
	tests := []struct {
		name    string
		mockRet map[string]ipp.Attributes
		mockErr error
		want    int
		wantErr bool
	}{
		{
			name: "success",
			mockRet: map[string]ipp.Attributes{
				"printer1": {
					ipp.AttributePrinterName:            []ipp.Attribute{{Value: "printer1"}},
					ipp.AttributePrinterUriSupported:    []ipp.Attribute{{Value: "ipp://localhost/printers/printer1"}},
					ipp.AttributePrinterState:           []ipp.Attribute{{Value: 3}},
					ipp.AttributePrinterStateReasons:    []ipp.Attribute{{Value: "none"}},
					ipp.AttributePrinterLocation:        []ipp.Attribute{{Value: "Office"}},
					ipp.AttributePrinterInfo:            []ipp.Attribute{{Value: "Test Printer"}},
					ipp.AttributePrinterMakeAndModel:    []ipp.Attribute{{Value: "Generic"}},
					ipp.AttributePrinterIsAcceptingJobs: []ipp.Attribute{{Value: true}},
				},
			},
			mockErr: nil,
			want:    1,
			wantErr: false,
		},
		{
			name:    "error",
			mockRet: nil,
			mockErr: errors.New("test error"),
			want:    0,
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockClient := mocks_cups.NewMockCUPSClientInterface(t)
			mockClient.EXPECT().GetPrinters(mock.Anything).Return(tt.mockRet, tt.mockErr)

			m := &Manager{
				client: mockClient,
			}

			got, err := m.GetPrinters()
			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
				assert.Equal(t, tt.want, len(got))
				if len(got) > 0 {
					assert.Equal(t, "printer1", got[0].Name)
					assert.Equal(t, "idle", got[0].State)
					assert.Equal(t, "Office", got[0].Location)
					assert.True(t, got[0].Accepting)
				}
			}
		})
	}
}

func TestManager_GetJobs(t *testing.T) {
	tests := []struct {
		name    string
		mockRet map[int]ipp.Attributes
		mockErr error
		want    int
		wantErr bool
	}{
		{
			name: "success",
			mockRet: map[int]ipp.Attributes{
				1: {
					ipp.AttributeJobID:                  []ipp.Attribute{{Value: 1}},
					ipp.AttributeJobName:                []ipp.Attribute{{Value: "test-job"}},
					ipp.AttributeJobState:               []ipp.Attribute{{Value: 5}},
					ipp.AttributeJobPrinterURI:          []ipp.Attribute{{Value: "ipp://localhost/printers/printer1"}},
					ipp.AttributeJobOriginatingUserName: []ipp.Attribute{{Value: "testuser"}},
					ipp.AttributeJobKilobyteOctets:      []ipp.Attribute{{Value: 10}},
					"time-at-creation":                  []ipp.Attribute{{Value: 1609459200}},
				},
			},
			mockErr: nil,
			want:    1,
			wantErr: false,
		},
		{
			name:    "error",
			mockRet: nil,
			mockErr: errors.New("test error"),
			want:    0,
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockClient := mocks_cups.NewMockCUPSClientInterface(t)
			mockClient.EXPECT().GetJobs("printer1", "", "not-completed", false, 0, 0, mock.Anything).
				Return(tt.mockRet, tt.mockErr)

			m := &Manager{
				client: mockClient,
			}

			got, err := m.GetJobs("printer1", "not-completed")
			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
				assert.Equal(t, tt.want, len(got))
				if len(got) > 0 {
					assert.Equal(t, 1, got[0].ID)
					assert.Equal(t, "test-job", got[0].Name)
					assert.Equal(t, "processing", got[0].State)
					assert.Equal(t, "testuser", got[0].User)
					assert.Equal(t, "printer1", got[0].Printer)
					assert.Equal(t, 10240, got[0].Size)
					assert.Equal(t, time.Unix(1609459200, 0), got[0].TimeCreated)
				}
			}
		})
	}
}

func TestManager_CancelJob(t *testing.T) {
	tests := []struct {
		name    string
		mockErr error
		wantErr bool
	}{
		{
			name:    "success",
			mockErr: nil,
			wantErr: false,
		},
		{
			name:    "error",
			mockErr: errors.New("test error"),
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockClient := mocks_cups.NewMockCUPSClientInterface(t)
			mockClient.EXPECT().CancelJob(1, false).Return(tt.mockErr)

			m := &Manager{
				client: mockClient,
			}

			err := m.CancelJob(1)
			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestManager_PausePrinter(t *testing.T) {
	tests := []struct {
		name    string
		mockErr error
		wantErr bool
	}{
		{
			name:    "success",
			mockErr: nil,
			wantErr: false,
		},
		{
			name:    "error",
			mockErr: errors.New("test error"),
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockClient := mocks_cups.NewMockCUPSClientInterface(t)
			mockClient.EXPECT().PausePrinter("printer1").Return(tt.mockErr)

			m := &Manager{
				client: mockClient,
			}

			err := m.PausePrinter("printer1")
			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestManager_ResumePrinter(t *testing.T) {
	tests := []struct {
		name    string
		mockErr error
		wantErr bool
	}{
		{
			name:    "success",
			mockErr: nil,
			wantErr: false,
		},
		{
			name:    "error",
			mockErr: errors.New("test error"),
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockClient := mocks_cups.NewMockCUPSClientInterface(t)
			mockClient.EXPECT().ResumePrinter("printer1").Return(tt.mockErr)

			m := &Manager{
				client: mockClient,
			}

			err := m.ResumePrinter("printer1")
			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestManager_PurgeJobs(t *testing.T) {
	tests := []struct {
		name    string
		mockErr error
		wantErr bool
	}{
		{
			name:    "success",
			mockErr: nil,
			wantErr: false,
		},
		{
			name:    "error",
			mockErr: errors.New("test error"),
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockClient := mocks_cups.NewMockCUPSClientInterface(t)
			mockClient.EXPECT().CancelAllJob("printer1", true).Return(tt.mockErr)

			m := &Manager{
				client: mockClient,
			}

			err := m.PurgeJobs("printer1")
			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}
