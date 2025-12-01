package wayland

import (
	"testing"

	"github.com/AvengeMedia/danklinux/internal/utils"
)

func TestGenerateGammaRamp(t *testing.T) {
	tests := []struct {
		name  string
		size  uint32
		temp  int
		gamma float64
	}{
		{"small_warm", 16, 6500, 1.0},
		{"small_cool", 16, 4000, 1.0},
		{"large_warm", 256, 6500, 1.0},
		{"large_cool", 256, 4000, 1.0},
		{"custom_gamma", 64, 5500, 1.2},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			ramp := GenerateGammaRamp(tt.size, tt.temp, tt.gamma)

			if len(ramp.Red) != int(tt.size) {
				t.Errorf("expected %d red values, got %d", tt.size, len(ramp.Red))
			}
			if len(ramp.Green) != int(tt.size) {
				t.Errorf("expected %d green values, got %d", tt.size, len(ramp.Green))
			}
			if len(ramp.Blue) != int(tt.size) {
				t.Errorf("expected %d blue values, got %d", tt.size, len(ramp.Blue))
			}

			if ramp.Red[0] != 0 || ramp.Green[0] != 0 || ramp.Blue[0] != 0 {
				t.Errorf("first values should be 0, got R:%d G:%d B:%d",
					ramp.Red[0], ramp.Green[0], ramp.Blue[0])
			}

			lastIdx := tt.size - 1
			if ramp.Red[lastIdx] == 0 || ramp.Green[lastIdx] == 0 || ramp.Blue[lastIdx] == 0 {
				t.Errorf("last values should be non-zero, got R:%d G:%d B:%d",
					ramp.Red[lastIdx], ramp.Green[lastIdx], ramp.Blue[lastIdx])
			}

			for i := uint32(1); i < tt.size; i++ {
				if ramp.Red[i] < ramp.Red[i-1] {
					t.Errorf("red ramp not monotonic at index %d", i)
				}
			}
		})
	}
}

func TestTemperatureToRGB(t *testing.T) {
	tests := []struct {
		name string
		temp int
	}{
		{"very_warm", 6500},
		{"neutral", 5500},
		{"cool", 4000},
		{"very_cool", 3000},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r, g, b := temperatureToRGB(tt.temp)

			if r < 0 || r > 1 {
				t.Errorf("red out of range: %f", r)
			}
			if g < 0 || g > 1 {
				t.Errorf("green out of range: %f", g)
			}
			if b < 0 || b > 1 {
				t.Errorf("blue out of range: %f", b)
			}
		})
	}
}

func TestTemperatureProgression(t *testing.T) {
	temps := []int{3000, 4000, 5000, 6000, 6500}

	var prevBlue float64
	for i, temp := range temps {
		_, _, b := temperatureToRGB(temp)
		if i > 0 && b < prevBlue {
			t.Errorf("blue should increase with temperature, %d->%d: %f->%f",
				temps[i-1], temp, prevBlue, b)
		}
		prevBlue = b
	}
}

func TestClamp(t *testing.T) {
	tests := []struct {
		val      float64
		min      float64
		max      float64
		expected float64
	}{
		{5, 0, 10, 5},
		{-5, 0, 10, 0},
		{15, 0, 10, 10},
		{0, 0, 10, 0},
		{10, 0, 10, 10},
	}

	for _, tt := range tests {
		result := utils.Clamp(tt.val, tt.min, tt.max)
		if result != tt.expected {
			t.Errorf("clamp(%f, %f, %f) = %f, want %f",
				tt.val, tt.min, tt.max, result, tt.expected)
		}
	}
}
