package handlers

import (
	"encoding/json"
	"math"
	"os"
	"strconv"
)

type Ward struct {
	Ward    string      `json:"ward"`
	Polygon [][]float64 `json:"polygon"`
}

var wards []Ward

func LoadWards() {
	file, err := os.ReadFile("resources/wards_extracted.json")
	if err != nil {
		println("⚠️ Warning: Could not load wards.json:", err.Error())
		return
	}
	if err := json.Unmarshal(file, &wards); err != nil {
		println("⚠️ Warning: Could not parse wards.json:", err.Error())
	}

}

func isPointInPolygon(lng, lat float64, polygon [][]float64) bool {
	inside := false
	j := len(polygon) - 1
	for i := 0; i < len(polygon); i++ {
		xi, yi := polygon[i][0], polygon[i][1]
		xj, yj := polygon[j][0], polygon[j][1]

		intersect := ((yi > lat) != (yj > lat)) && (lng < (xj-xi)*(lat-yi)/(yj-yi)+xi)
		if intersect {
			inside = !inside
		}
		j = i
	}
	return inside
}

func findClosestWard(lat, lng float64) int {
	minDist := math.MaxFloat64
	closestWard := 1

	for _, w := range wards {
		wardNum, _ := strconv.Atoi(w.Ward)
		for _, pt := range w.Polygon {
			dist := math.Hypot(pt[0]-lng, pt[1]-lat)
			if dist < minDist {
				minDist = dist
				closestWard = wardNum
			}
		}
	}
	return closestWard
}

func FindWardByLocation(lat, lng float64) int {
	for _, w := range wards {
		if isPointInPolygon(lng, lat, w.Polygon) {
			wardNum, _ := strconv.Atoi(w.Ward)
			return wardNum
		}
	}
	return findClosestWard(lat, lng)
}