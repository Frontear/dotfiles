package wayland

import (
	"math"

	"github.com/AvengeMedia/danklinux/internal/utils"
)

type GammaRamp struct {
	Red   []uint16
	Green []uint16
	Blue  []uint16
}

func GenerateGammaRamp(size uint32, temp int, gamma float64) GammaRamp {
	ramp := GammaRamp{
		Red:   make([]uint16, size),
		Green: make([]uint16, size),
		Blue:  make([]uint16, size),
	}

	for i := uint32(0); i < size; i++ {
		val := float64(i) / float64(size-1)

		valGamma := math.Pow(val, 1.0/gamma)

		r, g, b := temperatureToRGB(temp)

		ramp.Red[i] = uint16(utils.Clamp(valGamma*r*65535.0, 0, 65535))
		ramp.Green[i] = uint16(utils.Clamp(valGamma*g*65535.0, 0, 65535))
		ramp.Blue[i] = uint16(utils.Clamp(valGamma*b*65535.0, 0, 65535))
	}

	return ramp
}

func GenerateIdentityRamp(size uint32) GammaRamp {
	ramp := GammaRamp{
		Red:   make([]uint16, size),
		Green: make([]uint16, size),
		Blue:  make([]uint16, size),
	}

	for i := uint32(0); i < size; i++ {
		val := uint16((float64(i) / float64(size-1)) * 65535.0)
		ramp.Red[i] = val
		ramp.Green[i] = val
		ramp.Blue[i] = val
	}

	return ramp
}

func temperatureToRGB(temp int) (float64, float64, float64) {
	tempK := float64(temp) / 100.0

	var r, g, b float64

	if tempK <= 66 {
		r = 1.0
	} else {
		r = tempK - 60
		r = 329.698727446 * math.Pow(r, -0.1332047592)
		r = utils.Clamp(r, 0, 255) / 255.0
	}

	if tempK <= 66 {
		g = tempK
		g = 99.4708025861*math.Log(g) - 161.1195681661
		g = utils.Clamp(g, 0, 255) / 255.0
	} else {
		g = tempK - 60
		g = 288.1221695283 * math.Pow(g, -0.0755148492)
		g = utils.Clamp(g, 0, 255) / 255.0
	}

	if tempK >= 66 {
		b = 1.0
	} else if tempK <= 19 {
		b = 0.0
	} else {
		b = tempK - 10
		b = 138.5177312231*math.Log(b) - 305.0447927307
		b = utils.Clamp(b, 0, 255) / 255.0
	}

	return r, g, b
}
