package barcode

import (
	"fmt"
	"regexp"
	"strings"
)

// Generator handles barcode generation
type Generator struct{}

// New creates a new barcode generator
func New() *Generator {
	return &Generator{}
}

// Generate creates a new barcode for an item
// Format: XXnnnnnnYYZZv where:
// XX: Category prefix (2 letters)
// nnnnnn: Item ID (6 digits, zero-padded)
// YY: Start year (last 2 digits)
// ZZ: End year (last 2 digits)
// v: Validation digit
func (g *Generator) Generate(categoryName string, itemID int, yearFrom, yearTo int) (string, error) {
	// Get category prefix (first 2 letters, uppercase)
	prefix := strings.ToUpper(categoryName)
	if len(prefix) < 2 {
		return "", fmt.Errorf("category name too short")
	}
	prefix = prefix[:2]

	// Format item ID to 6 digits
	itemNum := fmt.Sprintf("%06d", itemID)

	// Get year suffixes (last 2 digits of each year)
	yearFromSuffix := fmt.Sprintf("%02d", yearFrom%100)
	yearToSuffix := fmt.Sprintf("%02d", yearTo%100)

	// Create base code
	baseCode := fmt.Sprintf("%s%s%s%s", prefix, itemNum, yearFromSuffix, yearToSuffix)

	// Calculate check digit
	checkDigit := g.calculateCheckDigit(baseCode)

	// Return complete barcode
	return fmt.Sprintf("%s%d", baseCode, checkDigit), nil
}

// Validate checks if a barcode is valid
func (g *Generator) Validate(barcode string) bool {
	// Check format: 12 characters + 1 check digit
	if len(barcode) != 13 {
		return false
	}

	// Check format with regex
	match, _ := regexp.MatchString(`^[A-Z]{2}\d{6}\d{2}\d{2}\d{1}$`, barcode)
	if !match {
		return false
	}

	// Validate check digit
	baseCode := barcode[:12]
	checkDigit := int(barcode[12] - '0')
	return g.calculateCheckDigit(baseCode) == checkDigit
}

// calculateCheckDigit calculates the check digit for a barcode
func (g *Generator) calculateCheckDigit(baseCode string) int {
	sum := 0
	for i, r := range baseCode {
		// Alternate between multiplying by 3 and 1
		if i%2 == 0 {
			sum += int(r) * 3
		} else {
			sum += int(r)
		}
	}
	return (10 - (sum % 10)) % 10
}
