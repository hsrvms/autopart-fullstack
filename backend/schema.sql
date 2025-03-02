-- Şema oluşturma
CREATE SCHEMA IF NOT EXISTS arac;

-- Marka tablosu
CREATE TABLE IF NOT EXISTS arac.makes (
    make_id SERIAL PRIMARY KEY,
    make_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Model tablosu
CREATE TABLE IF NOT EXISTS arac.models (
    model_id SERIAL PRIMARY KEY,
    make_id INTEGER NOT NULL REFERENCES arac.makes(make_id),
    model_name VARCHAR(100) NOT NULL,
    body_style VARCHAR(50),
    vehicle_type VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(make_id, model_name)
);

-- Alt model tablosu
CREATE TABLE IF NOT EXISTS arac.submodels (
    submodel_id SERIAL PRIMARY KEY,
    model_id INTEGER REFERENCES arac.models(model_id),
    submodel_name VARCHAR(100) NOT NULL,
    year_from INTEGER NOT NULL,
    year_to INTEGER,
    engine_type VARCHAR(50),
    engine_displacement DECIMAL(4,1),
    fuel_type VARCHAR(50),
    transmission_type VARCHAR(50),
    body_type VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Kategori tablosu
CREATE TABLE IF NOT EXISTS arac.categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INTEGER REFERENCES arac.categories(category_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tedarikçi tablosu
CREATE TABLE IF NOT EXISTS arac.suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    tax_number VARCHAR(20),
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Ürün tablosu
CREATE TABLE IF NOT EXISTS arac.items (
    item_id SERIAL PRIMARY KEY,
    part_number VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    category_id INTEGER REFERENCES arac.categories(category_id),
    buy_price DECIMAL(10,2) NOT NULL,
    sell_price DECIMAL(10,2) NOT NULL,
    current_stock INTEGER NOT NULL DEFAULT 0,
    minimum_stock INTEGER NOT NULL DEFAULT 0,
    barcode VARCHAR(100) UNIQUE,
    supplier_id INTEGER REFERENCES arac.suppliers(supplier_id),
    location_aisle VARCHAR(50),
    location_shelf VARCHAR(50),
    location_bin VARCHAR(50),
    weight_kg DECIMAL(10,2),
    dimensions_cm VARCHAR(50),
    warranty_period VARCHAR(50),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    oem_code VARCHAR(100),
    make_id INTEGER REFERENCES arac.makes(make_id),
    model_id INTEGER REFERENCES arac.models(model_id),
    submodel_id INTEGER REFERENCES arac.submodels(submodel_id),
    year_from INTEGER,
    year_to INTEGER,
    CONSTRAINT items_barcode_key UNIQUE (barcode),
    CONSTRAINT items_part_number_key UNIQUE (part_number),
    CONSTRAINT items_category_id_fkey FOREIGN KEY (category_id) REFERENCES arac.categories(category_id),
    CONSTRAINT items_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES arac.suppliers(supplier_id),
    CONSTRAINT items_year_check CHECK (year_to >= year_from)
);

-- Ürün-Araç Uyumluluk tablosu
CREATE TABLE IF NOT EXISTS arac.compatibilities (
    compat_id SERIAL PRIMARY KEY,
    item_id INTEGER REFERENCES arac.items(item_id),
    submodel_id INTEGER REFERENCES arac.submodels(submodel_id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(item_id, submodel_id)
);

-- Satış tablosu
CREATE TABLE IF NOT EXISTS arac.sales (
    sale_id SERIAL PRIMARY KEY,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    item_id INTEGER REFERENCES arac.items(item_id),
    quantity INTEGER NOT NULL,
    price_per_unit DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    transaction_number VARCHAR(100) UNIQUE,
    customer_name VARCHAR(100),
    customer_phone VARCHAR(20),
    customer_email VARCHAR(100),
    sold_by VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Satın alma tablosu
CREATE TABLE IF NOT EXISTS arac.purchases (
    purchase_id SERIAL PRIMARY KEY,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    supplier_id INTEGER REFERENCES arac.suppliers(supplier_id),
    item_id INTEGER REFERENCES arac.items(item_id),
    quantity INTEGER NOT NULL,
    cost_per_unit DECIMAL(10,2) NOT NULL,
    total_cost DECIMAL(10,2) NOT NULL,
    invoice_number VARCHAR(100),
    received_by VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Güncelleme tetikleyicileri için fonksiyon
CREATE OR REPLACE FUNCTION arac.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Her tablo için güncelleme tetikleyicisi
CREATE TRIGGER update_makes_updated_at
    BEFORE UPDATE ON arac.makes
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_models_updated_at
    BEFORE UPDATE ON arac.models
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_submodels_updated_at
    BEFORE UPDATE ON arac.submodels
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON arac.categories
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_suppliers_updated_at
    BEFORE UPDATE ON arac.suppliers
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_items_updated_at
    BEFORE UPDATE ON arac.items
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_compatibilities_updated_at
    BEFORE UPDATE ON arac.compatibilities
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_sales_updated_at
    BEFORE UPDATE ON arac.sales
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_purchases_updated_at
    BEFORE UPDATE ON arac.purchases
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

-- Örnek marka verileri
INSERT INTO arac.makes (make_name) VALUES
    ('Acura'),
    ('Alfa Romeo'),
    ('Audi'),
    ('BMW'),
    ('Chevrolet'),
    ('Dodge'),
    ('Ferrari'),
    ('Ford'),
    ('Honda'),
    ('Hyundai'),
    ('Jaguar'),
    ('Jeep'),
    ('Kia'),
    ('Lamborghini'),
    ('Land Rover'),
    ('Lexus'),
    ('Maserati'),
    ('Mazda'),
    ('Mercedes-Benz'),
    ('MINI'),
    ('Mitsubishi'),
    ('Nissan'),
    ('Porsche'),
    ('Subaru'),
    ('Tesla'),
    ('Toyota'),
    ('Volkswagen'),
    ('Volvo')
ON CONFLICT (make_name) DO NOTHING; 









-- -- Önce şemayı oluştur
-- CREATE SCHEMA IF NOT EXISTS arac;

-- -- Kategoriler tablosu
-- CREATE TABLE arac.categories (
--     category_id SERIAL PRIMARY KEY,
--     name VARCHAR(100) NOT NULL,
--     description TEXT,
--     parent_category_id INTEGER REFERENCES arac.categories(category_id),
--     created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
-- );

-- -- Tedarikçiler tablosu
-- CREATE TABLE arac.suppliers (
--     supplier_id SERIAL PRIMARY KEY,
--     name VARCHAR(100) NOT NULL,
--     contact_person VARCHAR(100),
--     phone VARCHAR(20),
--     email VARCHAR(100),
--     address TEXT,
--     tax_number VARCHAR(20),
--     notes TEXT,
--     is_active BOOLEAN DEFAULT true,
--     created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
-- );

-- -- Markalar tablosu
-- CREATE TABLE arac.makes (
--     make_id SERIAL PRIMARY KEY,
--     make_name VARCHAR(100) NOT NULL,
--     country VARCHAR(100),
--     created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
-- );

-- -- Modeller tablosu
-- CREATE TABLE arac.models (
--     model_id SERIAL PRIMARY KEY,
--     make_id INTEGER NOT NULL REFERENCES arac.makes(make_id),
--     model_name VARCHAR(100) NOT NULL,
--     created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
-- );

-- -- Alt modeller tablosu
-- CREATE TABLE arac.submodels (
--     submodel_id SERIAL PRIMARY KEY,
--     model_id INTEGER NOT NULL REFERENCES arac.models(model_id),
--     submodel_name VARCHAR(100) NOT NULL,
--     year_from INTEGER NOT NULL,
--     year_to INTEGER,
--     engine_type VARCHAR(50) NOT NULL,
--     engine_displacement NUMERIC(4,1) NOT NULL,
--     fuel_type VARCHAR(50) NOT NULL,
--     transmission_type VARCHAR(50) NOT NULL,
--     body_type VARCHAR(50) NOT NULL,
--     created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
-- );

-- -- Parçalar tablosu
-- CREATE TABLE arac.items (
--     item_id SERIAL PRIMARY KEY,
--     part_number VARCHAR(100) NOT NULL UNIQUE,
--     description TEXT NOT NULL,
--     category_id INTEGER REFERENCES arac.categories(category_id),
--     make_id INTEGER REFERENCES arac.makes(make_id),
--     model_id INTEGER REFERENCES arac.models(model_id),
--     submodel_id INTEGER REFERENCES arac.submodels(submodel_id),
--     oem_code VARCHAR(100),
--     buy_price NUMERIC(10,2) NOT NULL,
--     sell_price NUMERIC(10,2) NOT NULL,
--     current_stock INTEGER NOT NULL DEFAULT 0,
--     minimum_stock INTEGER NOT NULL DEFAULT 0,
--     barcode VARCHAR(100) UNIQUE,
--     supplier_id INTEGER REFERENCES arac.suppliers(supplier_id),
--     location_aisle VARCHAR(50),
--     location_shelf VARCHAR(50),
--     location_bin VARCHAR(50),
--     weight_kg NUMERIC(10,2),
--     dimensions_cm VARCHAR(50),
--     warranty_period VARCHAR(50),
--     image_url TEXT,
--     is_active BOOLEAN DEFAULT true,
--     notes TEXT,
--     created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
-- );

-- -- Uyumluluk tablosu
-- CREATE TABLE arac.compatibility (
--     compat_id SERIAL PRIMARY KEY,
--     item_id INTEGER NOT NULL REFERENCES arac.items(item_id),
--     submodel_id INTEGER NOT NULL REFERENCES arac.submodels(submodel_id),
--     notes TEXT,
--     created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
--     UNIQUE(item_id, submodel_id)
-- );

-- -- Updated_at kolonlarını otomatik güncellemek için trigger fonksiyonu
-- CREATE OR REPLACE FUNCTION arac.update_updated_at_column()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.updated_at = CURRENT_TIMESTAMP;
--     RETURN NEW;
-- END;
-- $$ language 'plpgsql';

-- -- Her tablo için update trigger'ı
-- CREATE TRIGGER update_categories_updated_at
--     BEFORE UPDATE ON arac.categories
--     FOR EACH ROW
--     EXECUTE FUNCTION arac.update_updated_at_column();

-- CREATE TRIGGER update_suppliers_updated_at
--     BEFORE UPDATE ON arac.suppliers
--     FOR EACH ROW
--     EXECUTE FUNCTION arac.update_updated_at_column();

-- CREATE TRIGGER update_makes_updated_at
--     BEFORE UPDATE ON arac.makes
--     FOR EACH ROW
--     EXECUTE FUNCTION arac.update_updated_at_column();

-- CREATE TRIGGER update_models_updated_at
--     BEFORE UPDATE ON arac.models
--     FOR EACH ROW
--     EXECUTE FUNCTION arac.update_updated_at_column();

-- CREATE TRIGGER update_submodels_updated_at
--     BEFORE UPDATE ON arac.submodels
--     FOR EACH ROW
--     EXECUTE FUNCTION arac.update_updated_at_column();

-- CREATE TRIGGER update_items_updated_at
--     BEFORE UPDATE ON arac.items
--     FOR EACH ROW
--     EXECUTE FUNCTION arac.update_updated_at_column();