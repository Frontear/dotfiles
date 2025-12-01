package wayland

import (
	"math"
	"time"
)

const (
	degToRad     = math.Pi / 180.0
	radToDeg     = 180.0 / math.Pi
	solarNoon    = 12.0
	sunriseAngle = -0.833
)

func CalculateSunTimes(lat, lon float64, date time.Time) SunTimes {
	utcDate := date.UTC()
	year, month, day := utcDate.Date()
	loc := date.Location()

	dayOfYear := utcDate.YearDay()

	gamma := 2 * math.Pi / 365 * float64(dayOfYear-1)

	eqTime := 229.18 * (0.000075 +
		0.001868*math.Cos(gamma) -
		0.032077*math.Sin(gamma) -
		0.014615*math.Cos(2*gamma) -
		0.040849*math.Sin(2*gamma))

	decl := 0.006918 -
		0.399912*math.Cos(gamma) +
		0.070257*math.Sin(gamma) -
		0.006758*math.Cos(2*gamma) +
		0.000907*math.Sin(2*gamma) -
		0.002697*math.Cos(3*gamma) +
		0.00148*math.Sin(3*gamma)

	latRad := lat * degToRad

	cosHourAngle := (math.Sin(sunriseAngle*degToRad) -
		math.Sin(latRad)*math.Sin(decl)) /
		(math.Cos(latRad) * math.Cos(decl))

	if cosHourAngle > 1 {
		return SunTimes{
			Sunrise: time.Date(year, month, day, 0, 0, 0, 0, time.UTC).In(loc),
			Sunset:  time.Date(year, month, day, 0, 0, 0, 0, time.UTC).In(loc),
		}
	}
	if cosHourAngle < -1 {
		return SunTimes{
			Sunrise: time.Date(year, month, day, 0, 0, 0, 0, time.UTC).In(loc),
			Sunset:  time.Date(year, month, day, 23, 59, 59, 0, time.UTC).In(loc),
		}
	}

	hourAngle := math.Acos(cosHourAngle) * radToDeg

	sunriseTime := solarNoon - hourAngle/15.0 - lon/15.0 - eqTime/60.0
	sunsetTime := solarNoon + hourAngle/15.0 - lon/15.0 - eqTime/60.0

	sunrise := timeOfDayToTime(sunriseTime, year, month, day, time.UTC).In(loc)
	sunset := timeOfDayToTime(sunsetTime, year, month, day, time.UTC).In(loc)

	return SunTimes{
		Sunrise: sunrise,
		Sunset:  sunset,
	}
}

func timeOfDayToTime(hours float64, year int, month time.Month, day int, loc *time.Location) time.Time {
	h := int(hours)
	m := int((hours - float64(h)) * 60)
	s := int(((hours-float64(h))*60 - float64(m)) * 60)

	if h < 0 {
		h += 24
		day--
	}
	if h >= 24 {
		h -= 24
		day++
	}

	return time.Date(year, month, day, h, m, s, 0, loc)
}
