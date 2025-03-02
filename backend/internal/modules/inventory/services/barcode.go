package services

import (
	"bytes"
	"fmt"
	"image/png"

	"github.com/boombuler/barcode"
	"github.com/boombuler/barcode/code128"
	pkgbarcode "github.com/hsrvms/autoparts/pkg/barcode"
)

// BarcodeService handles barcode operations
type BarcodeService interface {
	GenerateBarcode(makeID, modelID, submodelID, categoryID, yearFrom, yearTo int) (string, error)
	GenerateBarcodeImage(barcode string) ([]byte, error)
}

type barcodeService struct {
	generator *pkgbarcode.Generator
}

func NewBarcodeService() BarcodeService {
	return &barcodeService{
		generator: pkgbarcode.New(),
	}
}

// GenerateBarcode creates a unique barcode for an item
func (s *barcodeService) GenerateBarcode(makeID, modelID, submodelID, categoryID, yearFrom, yearTo int) (string, error) {
	// Validate inputs
	if makeID <= 0 || modelID <= 0 || submodelID <= 0 || categoryID <= 0 {
		return "", fmt.Errorf("invalid input parameters")
	}

	if yearFrom <= 0 || yearTo <= 0 || yearFrom > yearTo {
		return "", fmt.Errorf("invalid year range")
	}

	// Generate category prefix
	categoryPrefix := fmt.Sprintf("C%d", categoryID)

	// Generate unique item ID from make, model, and submodel IDs
	itemID := makeID*1000000 + modelID*1000 + submodelID

	// Generate barcode
	barcode, err := s.generator.Generate(categoryPrefix, itemID, yearFrom, yearTo)
	if err != nil {
		return "", fmt.Errorf("failed to generate barcode: %w", err)
	}

	return barcode, nil
}

// GenerateBarcodeImage generates a PNG image of the barcode
func (s *barcodeService) GenerateBarcodeImage(barcodeText string) ([]byte, error) {
	// Validate barcode
	if !s.generator.Validate(barcodeText) {
		return nil, fmt.Errorf("invalid barcode format")
	}

	// Create barcode
	barcodeObj, err := code128.Encode(barcodeText)
	if err != nil {
		return nil, fmt.Errorf("failed to encode barcode: %w", err)
	}

	// Scale barcode to a reasonable size
	scaledBarcode, err := barcode.Scale(barcodeObj.(barcode.BarcodeIntCS), 300, 100)
	if err != nil {
		return nil, fmt.Errorf("failed to scale barcode: %w", err)
	}

	// Encode barcode as PNG
	var buf bytes.Buffer
	if err := png.Encode(&buf, scaledBarcode); err != nil {
		return nil, fmt.Errorf("failed to encode PNG: %w", err)
	}

	return buf.Bytes(), nil
}
