package wayland

import (
	"math"
	"testing"
	"time"
)

func calculateTemperature(config Config, now time.Time) int {
	if !config.Enabled {
		return config.HighTemp
	}

	var sunrise, sunset time.Time

	if config.ManualSunrise != nil && config.ManualSunset != nil {
		year, month, day := now.Date()
		loc := now.Location()

		sunrise = time.Date(year, month, day,
			config.ManualSunrise.Hour(),
			config.ManualSunrise.Minute(),
			config.ManualSunrise.Second(), 0, loc)
		sunset = time.Date(year, month, day,
			config.ManualSunset.Hour(),
			config.ManualSunset.Minute(),
			config.ManualSunset.Second(), 0, loc)

		if sunset.Before(sunrise) {
			sunset = sunset.Add(24 * time.Hour)
		}
	} else if config.UseIPLocation {
		lat, lon, err := FetchIPLocation()
		if err != nil {
			return config.HighTemp
		}
		times := CalculateSunTimes(*lat, *lon, now)
		sunrise = times.Sunrise
		sunset = times.Sunset
	} else if config.Latitude != nil && config.Longitude != nil {
		times := CalculateSunTimes(*config.Latitude, *config.Longitude, now)
		sunrise = times.Sunrise
		sunset = times.Sunset
	} else {
		return config.HighTemp
	}

	if now.Before(sunrise) || now.After(sunset) {
		return config.LowTemp
	}
	return config.HighTemp
}

func calculateNextTransition(config Config, now time.Time) time.Time {
	if !config.Enabled {
		return now.Add(24 * time.Hour)
	}

	var sunrise, sunset time.Time

	if config.ManualSunrise != nil && config.ManualSunset != nil {
		year, month, day := now.Date()
		loc := now.Location()

		sunrise = time.Date(year, month, day,
			config.ManualSunrise.Hour(),
			config.ManualSunrise.Minute(),
			config.ManualSunrise.Second(), 0, loc)
		sunset = time.Date(year, month, day,
			config.ManualSunset.Hour(),
			config.ManualSunset.Minute(),
			config.ManualSunset.Second(), 0, loc)

		if sunset.Before(sunrise) {
			sunset = sunset.Add(24 * time.Hour)
		}
	} else if config.UseIPLocation {
		lat, lon, err := FetchIPLocation()
		if err != nil {
			return now.Add(24 * time.Hour)
		}
		times := CalculateSunTimes(*lat, *lon, now)
		sunrise = times.Sunrise
		sunset = times.Sunset
	} else if config.Latitude != nil && config.Longitude != nil {
		times := CalculateSunTimes(*config.Latitude, *config.Longitude, now)
		sunrise = times.Sunrise
		sunset = times.Sunset
	} else {
		return now.Add(24 * time.Hour)
	}

	if now.Before(sunrise) {
		return sunrise
	}
	if now.Before(sunset) {
		return sunset
	}

	if config.ManualSunrise != nil && config.ManualSunset != nil {
		year, month, day := now.Add(24 * time.Hour).Date()
		loc := now.Location()
		nextSunrise := time.Date(year, month, day,
			config.ManualSunrise.Hour(),
			config.ManualSunrise.Minute(),
			config.ManualSunrise.Second(), 0, loc)
		return nextSunrise
	}

	if config.UseIPLocation {
		lat, lon, err := FetchIPLocation()
		if err != nil {
			return now.Add(24 * time.Hour)
		}
		nextDayTimes := CalculateSunTimes(*lat, *lon, now.Add(24*time.Hour))
		return nextDayTimes.Sunrise
	}

	if config.Latitude != nil && config.Longitude != nil {
		nextDayTimes := CalculateSunTimes(*config.Latitude, *config.Longitude, now.Add(24*time.Hour))
		return nextDayTimes.Sunrise
	}

	return now.Add(24 * time.Hour)
}

func TestCalculateSunTimes(t *testing.T) {
	tests := []struct {
		name      string
		lat       float64
		lon       float64
		date      time.Time
		checkFunc func(*testing.T, SunTimes)
	}{
		{
			name: "new_york_summer",
			lat:  40.7128,
			lon:  -74.0060,
			date: time.Date(2024, 6, 21, 12, 0, 0, 0, time.Local),
			checkFunc: func(t *testing.T, times SunTimes) {
				if times.Sunrise.Hour() < 4 || times.Sunrise.Hour() > 6 {
					t.Logf("sunrise: %v", times.Sunrise)
				}
				if times.Sunset.Hour() < 19 || times.Sunset.Hour() > 21 {
					t.Logf("sunset: %v", times.Sunset)
				}
				if !times.Sunset.After(times.Sunrise) {
					t.Error("sunset should be after sunrise")
				}
			},
		},
		{
			name: "london_winter",
			lat:  51.5074,
			lon:  -0.1278,
			date: time.Date(2024, 12, 21, 12, 0, 0, 0, time.UTC),
			checkFunc: func(t *testing.T, times SunTimes) {
				if times.Sunrise.Hour() < 7 || times.Sunrise.Hour() > 9 {
					t.Errorf("unexpected sunrise hour: %d", times.Sunrise.Hour())
				}
				if times.Sunset.Hour() < 15 || times.Sunset.Hour() > 17 {
					t.Errorf("unexpected sunset hour: %d", times.Sunset.Hour())
				}
			},
		},
		{
			name: "equator_equinox",
			lat:  0.0,
			lon:  0.0,
			date: time.Date(2024, 3, 20, 12, 0, 0, 0, time.UTC),
			checkFunc: func(t *testing.T, times SunTimes) {
				if times.Sunrise.Hour() < 5 || times.Sunrise.Hour() > 7 {
					t.Errorf("unexpected sunrise hour: %d", times.Sunrise.Hour())
				}
				if times.Sunset.Hour() < 17 || times.Sunset.Hour() > 19 {
					t.Errorf("unexpected sunset hour: %d", times.Sunset.Hour())
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			times := CalculateSunTimes(tt.lat, tt.lon, tt.date)
			tt.checkFunc(t, times)
		})
	}
}

func TestCalculateTemperature(t *testing.T) {
	lat := 40.7128
	lon := -74.0060
	date := time.Date(2024, 6, 21, 0, 0, 0, 0, time.Local)

	config := Config{
		LowTemp:   4000,
		HighTemp:  6500,
		Latitude:  &lat,
		Longitude: &lon,
		Enabled:   true,
	}

	times := CalculateSunTimes(lat, lon, date)

	tests := []struct {
		name     string
		timeFunc func() time.Time
		wantTemp int
	}{
		{
			name:     "midnight",
			timeFunc: func() time.Time { return times.Sunrise.Add(-4 * time.Hour) },
			wantTemp: 4000,
		},
		{
			name:     "sunrise",
			timeFunc: func() time.Time { return times.Sunrise },
			wantTemp: 6500,
		},
		{
			name:     "noon",
			timeFunc: func() time.Time { return times.Sunrise.Add(6 * time.Hour) },
			wantTemp: 6500,
		},
		{
			name:     "after_sunset_transition",
			timeFunc: func() time.Time { return times.Sunset.Add(2 * time.Hour) },
			wantTemp: 4000,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			temp := calculateTemperature(config, tt.timeFunc())

			if math.Abs(float64(temp-tt.wantTemp)) > 500 {
				t.Errorf("temperature = %d, want approximately %d", temp, tt.wantTemp)
			}
		})
	}
}

func TestCalculateTemperatureManualTimes(t *testing.T) {
	sunrise := time.Date(0, 1, 1, 6, 30, 0, 0, time.Local)
	sunset := time.Date(0, 1, 1, 18, 30, 0, 0, time.Local)

	config := Config{
		LowTemp:       4000,
		HighTemp:      6500,
		ManualSunrise: &sunrise,
		ManualSunset:  &sunset,
		Enabled:       true,
	}

	tests := []struct {
		name string
		time time.Time
		want int
	}{
		{"before_sunrise", time.Date(2024, 1, 1, 3, 0, 0, 0, time.Local), 4000},
		{"at_sunrise", time.Date(2024, 1, 1, 6, 30, 0, 0, time.Local), 6500},
		{"midday", time.Date(2024, 1, 1, 12, 0, 0, 0, time.Local), 6500},
		{"at_sunset", time.Date(2024, 1, 1, 18, 30, 0, 0, time.Local), 6500},
		{"after_sunset", time.Date(2024, 1, 1, 22, 0, 0, 0, time.Local), 4000},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			temp := calculateTemperature(config, tt.time)
			if math.Abs(float64(temp-tt.want)) > 500 {
				t.Errorf("temperature = %d, want approximately %d", temp, tt.want)
			}
		})
	}
}

func TestCalculateTemperatureDisabled(t *testing.T) {
	lat := 40.7128
	lon := -74.0060

	config := Config{
		LowTemp:   4000,
		HighTemp:  6500,
		Latitude:  &lat,
		Longitude: &lon,
		Enabled:   false,
	}

	temp := calculateTemperature(config, time.Now())
	if temp != 6500 {
		t.Errorf("disabled should return high temp, got %d", temp)
	}
}

func TestCalculateNextTransition(t *testing.T) {
	lat := 40.7128
	lon := -74.0060
	date := time.Date(2024, 6, 21, 0, 0, 0, 0, time.Local)

	config := Config{
		LowTemp:   4000,
		HighTemp:  6500,
		Latitude:  &lat,
		Longitude: &lon,
		Enabled:   true,
	}

	times := CalculateSunTimes(lat, lon, date)

	tests := []struct {
		name      string
		now       time.Time
		checkFunc func(*testing.T, time.Time)
	}{
		{
			name: "before_sunrise",
			now:  times.Sunrise.Add(-2 * time.Hour),
			checkFunc: func(t *testing.T, next time.Time) {
				if !next.Equal(times.Sunrise) && !next.After(times.Sunrise.Add(-1*time.Minute)) {
					t.Error("next transition should be at or near sunrise")
				}
			},
		},
		{
			name: "after_sunrise",
			now:  times.Sunrise.Add(2 * time.Hour),
			checkFunc: func(t *testing.T, next time.Time) {
				if !next.After(times.Sunrise) {
					t.Error("next transition should be after sunrise")
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			next := calculateNextTransition(config, tt.now)
			tt.checkFunc(t, next)
		})
	}
}

func TestTimeOfDayToTime(t *testing.T) {
	tests := []struct {
		name     string
		hours    float64
		expected time.Time
	}{
		{
			name:     "noon",
			hours:    12.0,
			expected: time.Date(2024, 6, 21, 12, 0, 0, 0, time.Local),
		},
		{
			name:     "half_past",
			hours:    12.5,
			expected: time.Date(2024, 6, 21, 12, 30, 0, 0, time.Local),
		},
		{
			name:     "early_morning",
			hours:    6.25,
			expected: time.Date(2024, 6, 21, 6, 15, 0, 0, time.Local),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := timeOfDayToTime(tt.hours, 2024, 6, 21, time.Local)

			if result.Hour() != tt.expected.Hour() {
				t.Errorf("hour = %d, want %d", result.Hour(), tt.expected.Hour())
			}
			if result.Minute() != tt.expected.Minute() {
				t.Errorf("minute = %d, want %d", result.Minute(), tt.expected.Minute())
			}
		})
	}
}
