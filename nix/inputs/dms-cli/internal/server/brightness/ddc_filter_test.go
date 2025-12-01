package brightness

import (
	"testing"
)

func TestIsIgnorableI2CDeviceName(t *testing.T) {
	tests := []struct {
		name       string
		deviceName string
		driver     string
		want       bool
	}{
		{
			name:       "AMDGPU SMU should be ignored",
			deviceName: "AMDGPU SMU",
			driver:     "amdgpu",
			want:       true,
		},
		{
			name:       "SMBus should be ignored",
			deviceName: "SMBus I801 adapter",
			driver:     "",
			want:       true,
		},
		{
			name:       "Synopsys DesignWare should be ignored",
			deviceName: "Synopsys DesignWare I2C adapter",
			driver:     "",
			want:       true,
		},
		{
			name:       "smu prefix should be ignored (Mac G5)",
			deviceName: "smu-i2c-controller",
			driver:     "",
			want:       true,
		},
		{
			name:       "Regular NVIDIA DDC should not be ignored",
			deviceName: "NVIDIA i2c adapter 1",
			driver:     "nvidia",
			want:       false,
		},
		{
			name:       "nouveau nvkm bus should not be ignored",
			deviceName: "nvkm-0000:01:00.0-bus-0000",
			driver:     "nouveau",
			want:       false,
		},
		{
			name:       "nouveau non-nvkm bus should be ignored",
			deviceName: "nouveau-other-bus",
			driver:     "nouveau",
			want:       true,
		},
		{
			name:       "Regular AMD display adapter should not be ignored",
			deviceName: "AMDGPU DM i2c hw bus 0",
			driver:     "amdgpu",
			want:       false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := isIgnorableI2CDeviceName(tt.deviceName, tt.driver)
			if got != tt.want {
				t.Errorf("isIgnorableI2CDeviceName(%q, %q) = %v, want %v",
					tt.deviceName, tt.driver, got, tt.want)
			}
		})
	}
}

func TestClassFiltering(t *testing.T) {
	tests := []struct {
		name  string
		class uint32
		want  bool
	}{
		{
			name:  "Display adapter class should not be ignored",
			class: 0x030000,
			want:  false,
		},
		{
			name:  "Docking station class should not be ignored",
			class: 0x0a0000,
			want:  false,
		},
		{
			name:  "Display adapter with subclass should not be ignored",
			class: 0x030001,
			want:  false,
		},
		{
			name:  "SMBus class should be ignored",
			class: 0x0c0500,
			want:  true,
		},
		{
			name:  "Bridge class should be ignored",
			class: 0x060400,
			want:  true,
		},
		{
			name:  "Generic system peripheral should be ignored",
			class: 0x088000,
			want:  true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Test the class filtering logic directly
			classHigh := tt.class & 0xFFFF0000
			ignorable := (classHigh != 0x030000 && classHigh != 0x0A0000)
			if ignorable != tt.want {
				t.Errorf("class 0x%08x: ignorable = %v, want %v", tt.class, ignorable, tt.want)
			}
		})
	}
}
