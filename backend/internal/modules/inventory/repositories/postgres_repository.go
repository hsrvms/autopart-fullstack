package repositories

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	inventorymodels "github.com/hsrvms/autoparts/internal/modules/inventory/models"
	"github.com/hsrvms/autoparts/pkg/db"
	"github.com/jackc/pgx/v5"
)

type PostgresInventoryRepository struct {
	db *db.Database
}

func NewPostgresInventoryRepository(database *db.Database) InventoryRepository {
	return &PostgresInventoryRepository{
		db: database,
	}
}

func (r *PostgresInventoryRepository) GetItems(ctx context.Context, filter *inventorymodels.ItemFilter) ([]*inventorymodels.Item, error) {
	query := `
		SELECT 
			i.item_id,
			i.part_number,
			i.description,
			i.category_id,
			i.buy_price,
			i.sell_price,
			i.current_stock,
			i.minimum_stock,
			i.barcode,
			i.supplier_id,
			i.location_aisle,
			i.location_shelf,
			i.location_bin,
			i.weight_kg,
			i.dimensions_cm,
			i.warranty_period,
			i.image_url,
			i.is_active,
			i.notes,
			i.created_at,
			i.updated_at,
			c.name as category_name,
			s.name as supplier_name,
			m.make_name,
			mo.model_name,
			sm.submodel_name,
			i.make_id,
			i.model_id,
			i.submodel_id,
			i.oem_code
		FROM arac.items i
		LEFT JOIN arac.categories c ON i.category_id = c.category_id
		LEFT JOIN arac.suppliers s ON i.supplier_id = s.supplier_id
		LEFT JOIN arac.makes m ON i.make_id = m.make_id
		LEFT JOIN arac.models mo ON i.model_id = mo.model_id
		LEFT JOIN arac.submodels sm ON i.submodel_id = sm.submodel_id
		WHERE 1=1
	`
	args := []interface{}{}
	argPosition := 1

	if filter != nil {
		if filter.CategoryID != nil {
			query += fmt.Sprintf(" AND i.category_id = $%d", argPosition)
			args = append(args, *filter.CategoryID)
			argPosition++
		}

		if filter.SupplierID != nil {
			query += fmt.Sprintf(" AND i.supplier_id = $%d", argPosition)
			args = append(args, *filter.SupplierID)
			argPosition++
		}

		if filter.PartNumber != nil {
			query += fmt.Sprintf(" AND i.part_number ILIKE $%d", argPosition)
			args = append(args, "%"+*filter.PartNumber+"%")
			argPosition++
		}

		if filter.SearchTerm != nil {
			query += fmt.Sprintf(" AND (i.part_number ILIKE $%d OR i.description ILIKE $%d OR c.name ILIKE $%d)",
				argPosition, argPosition, argPosition)
			searchTerm := "%" + *filter.SearchTerm + "%"
			args = append(args, searchTerm)
			argPosition++
		}

		if filter.LowStock != nil && *filter.LowStock {
			query += " AND i.current_stock <= i.minimum_stock"
		}

		if filter.IsActive != nil {
			query += fmt.Sprintf(" AND i.is_active = $%d", argPosition)
			args = append(args, *filter.IsActive)
			argPosition++
		}
	}

	query += " ORDER BY i.part_number"

	rows, err := r.db.Pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []*inventorymodels.Item
	for rows.Next() {
		item := &inventorymodels.Item{}
		var categoryID sql.NullInt32
		var supplierID sql.NullInt32
		var makeID sql.NullInt32
		var modelID sql.NullInt32
		var submodelID sql.NullInt32
		var categoryName sql.NullString
		var supplierName sql.NullString
		var makeName sql.NullString
		var modelName sql.NullString
		var submodelName sql.NullString
		var oemCode sql.NullString

		err := rows.Scan(
			&item.ItemID,
			&item.PartNumber,
			&item.Description,
			&categoryID,
			&item.BuyPrice,
			&item.SellPrice,
			&item.CurrentStock,
			&item.MinimumStock,
			&item.Barcode,
			&supplierID,
			&item.LocationAisle,
			&item.LocationShelf,
			&item.LocationBin,
			&item.WeightKg,
			&item.DimensionsCm,
			&item.WarrantyPeriod,
			&item.ImageURL,
			&item.IsActive,
			&item.Notes,
			&item.CreatedAt,
			&item.UpdatedAt,
			&categoryName,
			&supplierName,
			&makeName,
			&modelName,
			&submodelName,
			&makeID,
			&modelID,
			&submodelID,
			&oemCode,
		)
		if err != nil {
			return nil, err
		}

		if categoryID.Valid {
			item.CategoryID = int(categoryID.Int32)
		}
		if supplierID.Valid {
			intVal := int(supplierID.Int32)
			item.SupplierID = &intVal
		}
		if makeID.Valid {
			item.MakeID = int(makeID.Int32)
		}
		if modelID.Valid {
			item.ModelID = int(modelID.Int32)
		}
		if submodelID.Valid {
			item.SubmodelID = int(submodelID.Int32)
		}
		if categoryName.Valid {
			item.CategoryName = &categoryName.String
		}
		if supplierName.Valid {
			item.SupplierName = &supplierName.String
		}
		if makeName.Valid {
			item.MakeName = &makeName.String
		}
		if modelName.Valid {
			item.ModelName = &modelName.String
		}
		if submodelName.Valid {
			item.SubmodelName = &submodelName.String
		}
		if oemCode.Valid {
			item.OEMCode = &oemCode.String
		}

		items = append(items, item)
	}

	return items, rows.Err()
}

func (r *PostgresInventoryRepository) GetItemByID(ctx context.Context, id int) (*inventorymodels.Item, error) {
	query := `
		SELECT i.*, c.name as category_name, s.name as supplier_name
		FROM arac.items i
		LEFT JOIN arac.categories c ON i.category_id = c.category_id
		LEFT JOIN arac.suppliers s ON i.supplier_id = s.supplier_id
		WHERE i.item_id = $1
	`

	item := &inventorymodels.Item{}
	err := r.db.Pool.QueryRow(ctx, query, id).Scan(
		&item.ItemID, &item.PartNumber, &item.Description, &item.CategoryID,
		&item.BuyPrice, &item.SellPrice, &item.CurrentStock, &item.MinimumStock,
		&item.Barcode, &item.SupplierID, &item.LocationAisle, &item.LocationShelf,
		&item.LocationBin, &item.WeightKg, &item.DimensionsCm, &item.WarrantyPeriod,
		&item.ImageURL, &item.IsActive, &item.Notes, &item.CreatedAt, &item.UpdatedAt,
		&item.CategoryName, &item.SupplierName,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return item, nil
}

func (r *PostgresInventoryRepository) GetItemByPartNumber(ctx context.Context, partNumber string) (*inventorymodels.Item, error) {
	query := `
		SELECT i.*, c.name as category_name, s.name as supplier_name
		FROM arac.items i
		LEFT JOIN arac.categories c ON i.category_id = c.category_id
		LEFT JOIN arac.suppliers s ON i.supplier_id = s.supplier_id
		WHERE i.part_number = $1
	`

	item := &inventorymodels.Item{}
	err := r.db.Pool.QueryRow(ctx, query, partNumber).Scan(
		&item.ItemID, &item.PartNumber, &item.Description, &item.CategoryID,
		&item.BuyPrice, &item.SellPrice, &item.CurrentStock, &item.MinimumStock,
		&item.Barcode, &item.SupplierID, &item.LocationAisle, &item.LocationShelf,
		&item.LocationBin, &item.WeightKg, &item.DimensionsCm, &item.WarrantyPeriod,
		&item.ImageURL, &item.IsActive, &item.Notes, &item.CreatedAt, &item.UpdatedAt,
		&item.CategoryName, &item.SupplierName,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return item, nil
}

func (r *PostgresInventoryRepository) GetItemByBarcode(ctx context.Context, barcode string) (*inventorymodels.Item, error) {
	query := `
		SELECT i.*, c.name as category_name, s.name as supplier_name
		FROM arac.items i
		LEFT JOIN arac.categories c ON i.category_id = c.category_id
		LEFT JOIN arac.suppliers s ON i.supplier_id = s.supplier_id
		WHERE i.barcode = $1
	`

	item := &inventorymodels.Item{}
	err := r.db.Pool.QueryRow(ctx, query, barcode).Scan(
		&item.ItemID, &item.PartNumber, &item.Description, &item.CategoryID,
		&item.BuyPrice, &item.SellPrice, &item.CurrentStock, &item.MinimumStock,
		&item.Barcode, &item.SupplierID, &item.LocationAisle, &item.LocationShelf,
		&item.LocationBin, &item.WeightKg, &item.DimensionsCm, &item.WarrantyPeriod,
		&item.ImageURL, &item.IsActive, &item.Notes, &item.CreatedAt, &item.UpdatedAt,
		&item.CategoryName, &item.SupplierName,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return item, nil
}

func (r *PostgresInventoryRepository) CreateItem(ctx context.Context, item *inventorymodels.Item) (int, error) {
	query := `
		INSERT INTO arac.items (
			part_number, description, category_id, buy_price, sell_price,
			current_stock, minimum_stock, barcode, supplier_id,
			location_aisle, location_shelf, location_bin,
			weight_kg, dimensions_cm, warranty_period,
			image_url, is_active, notes, make_id, model_id, submodel_id, oem_code,
			year_from, year_to
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9,
			$10, $11, $12, $13, $14, $15, $16, $17, $18,
			$19, $20, $21, $22, $23, $24
		) RETURNING item_id
	`

	var id int
	err := r.db.Pool.QueryRow(
		ctx, query,
		item.PartNumber, item.Description, item.CategoryID, item.BuyPrice,
		item.SellPrice, item.CurrentStock, item.MinimumStock, item.Barcode,
		item.SupplierID, item.LocationAisle, item.LocationShelf, item.LocationBin,
		item.WeightKg, item.DimensionsCm, item.WarrantyPeriod, item.ImageURL,
		item.IsActive, item.Notes, item.MakeID, item.ModelID, item.SubmodelID,
		item.OEMCode, item.YearFrom, item.YearTo,
	).Scan(&id)

	if err != nil {
		return 0, err
	}

	return id, nil
}

func (r *PostgresInventoryRepository) UpdateItem(ctx context.Context, item *inventorymodels.Item) error {
	query := `
		UPDATE arac.items SET
			part_number = $2, description = $3, category_id = $4,
			buy_price = $5, sell_price = $6, current_stock = $7,
			minimum_stock = $8, barcode = $9, supplier_id = $10,
			location_aisle = $11, location_shelf = $12, location_bin = $13,
			weight_kg = $14, dimensions_cm = $15, warranty_period = $16,
			image_url = $17, is_active = $18, notes = $19, make_id = $20,
			model_id = $21, submodel_id = $22, oem_code = $23,
			year_from = $24, year_to = $25
		WHERE item_id = $1
	`

	result, err := r.db.Pool.Exec(
		ctx, query,
		item.ItemID, item.PartNumber, item.Description, item.CategoryID,
		item.BuyPrice, item.SellPrice, item.CurrentStock, item.MinimumStock,
		item.Barcode, item.SupplierID, item.LocationAisle, item.LocationShelf,
		item.LocationBin, item.WeightKg, item.DimensionsCm, item.WarrantyPeriod,
		item.ImageURL, item.IsActive, item.Notes, item.MakeID, item.ModelID,
		item.SubmodelID, item.OEMCode, item.YearFrom, item.YearTo,
	)

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return errors.New("item not found")
	}

	return nil
}

func (r *PostgresInventoryRepository) DeleteItem(ctx context.Context, id int) error {
	query := `DELETE FROM arac.items WHERE item_id = $1`

	result, err := r.db.Pool.Exec(ctx, query, id)
	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return errors.New("item not found")
	}

	return nil
}

func (r *PostgresInventoryRepository) GetCompatibilities(ctx context.Context, itemID int) ([]*inventorymodels.Compatibility, error) {
	query := `
        SELECT
            c.compat_id, c.item_id, c.submodel_id, c.notes, c.created_at,
            m.model_name, mk.make_name, s.submodel_name
        FROM compatibility c
        JOIN vehicle_submodels s ON c.submodel_id = s.submodel_id
        JOIN vehicle_models m ON s.model_id = m.model_id
        JOIN makes mk ON m.make_id = mk.make_id
        WHERE c.item_id = $1
        ORDER BY mk.make_name, m.model_name, s.submodel_name
    `

	rows, err := r.db.Pool.Query(ctx, query, itemID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var compatibilities []*inventorymodels.Compatibility
	for rows.Next() {
		compatibility := &inventorymodels.Compatibility{}
		err := rows.Scan(
			&compatibility.CompatID,
			&compatibility.ItemID,
			&compatibility.SubmodelID,
			&compatibility.Notes,
			&compatibility.CreatedAt,
			&compatibility.ModelName,
			&compatibility.MakeName,
			&compatibility.SubmodelName,
		)
		if err != nil {
			return nil, err
		}
		compatibilities = append(compatibilities, compatibility)
	}

	return compatibilities, rows.Err()
}

func (r *PostgresInventoryRepository) AddCompatibility(ctx context.Context, compatibility *inventorymodels.Compatibility) (int, error) {
	query := `
        INSERT INTO compatibility (item_id, submodel_id, notes)
        VALUES ($1, $2, $3)
        RETURNING compat_id
    `

	var id int
	err := r.db.Pool.QueryRow(
		ctx, query,
		compatibility.ItemID,
		compatibility.SubmodelID,
		compatibility.Notes,
	).Scan(&id)

	if err != nil {
		return 0, err
	}

	return id, nil
}

func (r *PostgresInventoryRepository) RemoveCompatibility(ctx context.Context, itemID, submodelID int) error {
	query := `
        DELETE FROM compatibility
        WHERE item_id = $1 AND submodel_id = $2
    `

	result, err := r.db.Pool.Exec(ctx, query, itemID, submodelID)
	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return errors.New("compatibility not found")
	}

	return nil
}

func (r *PostgresInventoryRepository) GetCompatibleItems(ctx context.Context, submodelID int) ([]*inventorymodels.Item, error) {
	query := `
		SELECT i.*, c.name as category_name, s.name as supplier_name
		FROM arac.items i
		LEFT JOIN arac.categories c ON i.category_id = c.category_id
		LEFT JOIN arac.suppliers s ON i.supplier_id = s.supplier_id
		JOIN arac.compatibility comp ON i.item_id = comp.item_id
		WHERE comp.submodel_id = $1 AND i.is_active = true
		ORDER BY i.part_number
	`

	rows, err := r.db.Pool.Query(ctx, query, submodelID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []*inventorymodels.Item
	for rows.Next() {
		item := &inventorymodels.Item{}
		err := rows.Scan(
			&item.ItemID, &item.PartNumber, &item.Description, &item.CategoryID,
			&item.BuyPrice, &item.SellPrice, &item.CurrentStock, &item.MinimumStock,
			&item.Barcode, &item.SupplierID, &item.LocationAisle, &item.LocationShelf,
			&item.LocationBin, &item.WeightKg, &item.DimensionsCm, &item.WarrantyPeriod,
			&item.ImageURL, &item.IsActive, &item.Notes, &item.CreatedAt, &item.UpdatedAt,
			&item.CategoryName, &item.SupplierName,
		)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}

	return items, rows.Err()
}

func (r *PostgresInventoryRepository) GetLowStockItems(ctx context.Context) ([]*inventorymodels.Item, error) {
	query := `
		SELECT i.*, c.name as category_name, s.name as supplier_name
		FROM arac.items i
		LEFT JOIN arac.categories c ON i.category_id = c.category_id
		LEFT JOIN arac.suppliers s ON i.supplier_id = s.supplier_id
		WHERE i.current_stock <= i.minimum_stock AND i.is_active = true
		ORDER BY i.current_stock ASC, i.part_number
	`

	rows, err := r.db.Pool.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []*inventorymodels.Item
	for rows.Next() {
		item := &inventorymodels.Item{}
		err := rows.Scan(
			&item.ItemID, &item.PartNumber, &item.Description, &item.CategoryID,
			&item.BuyPrice, &item.SellPrice, &item.CurrentStock, &item.MinimumStock,
			&item.Barcode, &item.SupplierID, &item.LocationAisle, &item.LocationShelf,
			&item.LocationBin, &item.WeightKg, &item.DimensionsCm, &item.WarrantyPeriod,
			&item.ImageURL, &item.IsActive, &item.Notes, &item.CreatedAt, &item.UpdatedAt,
			&item.CategoryName, &item.SupplierName,
		)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}

	return items, rows.Err()
}
