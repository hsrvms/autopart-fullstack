-- Şema oluşturma
CREATE SCHEMA IF NOT EXISTS arac;

-- Markalar tablosu
CREATE TABLE IF NOT EXISTS arac.makes (
    make_id SERIAL PRIMARY KEY,
    make_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Modeller tablosu
CREATE TABLE IF NOT EXISTS arac.models (
    model_id SERIAL PRIMARY KEY,
    make_id INTEGER REFERENCES arac.makes(make_id) ON DELETE CASCADE,
    model_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(make_id, model_name)
);

-- Alt modeller tablosu
CREATE TABLE IF NOT EXISTS arac.submodels (
    submodel_id SERIAL PRIMARY KEY,
    model_id INTEGER REFERENCES arac.models(model_id) ON DELETE CASCADE,
    submodel_name VARCHAR(100) NOT NULL,
    engine_type VARCHAR(100),
    year_from INTEGER,
    year_to INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(model_id, submodel_name)
);

-- Kategoriler tablosu
CREATE TABLE IF NOT EXISTS arac.categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    parent_id INTEGER REFERENCES arac.categories(category_id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Parçalar tablosu
CREATE TABLE IF NOT EXISTS arac.parts (
    part_id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES arac.categories(category_id) ON DELETE SET NULL,
    part_name VARCHAR(200) NOT NULL,
    part_number VARCHAR(100) UNIQUE,
    description TEXT,
    price DECIMAL(10,2),
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Parça-Model uyumluluk tablosu
CREATE TABLE IF NOT EXISTS arac.part_model_compatibility (
    compatibility_id SERIAL PRIMARY KEY,
    part_id INTEGER REFERENCES arac.parts(part_id) ON DELETE CASCADE,
    make_id INTEGER REFERENCES arac.makes(make_id) ON DELETE CASCADE,
    model_id INTEGER REFERENCES arac.models(model_id) ON DELETE CASCADE,
    submodel_id INTEGER REFERENCES arac.submodels(submodel_id) ON DELETE CASCADE NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(part_id, make_id, model_id, submodel_id)
);

-- Kullanıcılar tablosu
CREATE TABLE IF NOT EXISTS arac.users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Siparişler tablosu
CREATE TABLE IF NOT EXISTS arac.orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES arac.users(user_id) ON DELETE SET NULL,
    order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(10,2),
    shipping_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sipariş detayları tablosu
CREATE TABLE IF NOT EXISTS arac.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES arac.orders(order_id) ON DELETE CASCADE,
    part_id INTEGER REFERENCES arac.parts(part_id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Stok hareketleri tablosu
CREATE TABLE IF NOT EXISTS arac.stock_movements (
    movement_id SERIAL PRIMARY KEY,
    part_id INTEGER REFERENCES arac.parts(part_id) ON DELETE CASCADE,
    movement_type VARCHAR(20) NOT NULL, -- 'in' veya 'out'
    quantity INTEGER NOT NULL,
    reference_id INTEGER, -- Sipariş ID veya diğer referanslar
    reference_type VARCHAR(20), -- 'order', 'adjustment' vb.
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Trigger fonksiyonu - updated_at güncelleme
CREATE OR REPLACE FUNCTION arac.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger'ları oluştur
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

CREATE TRIGGER update_parts_updated_at
    BEFORE UPDATE ON arac.parts
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_part_model_compatibility_updated_at
    BEFORE UPDATE ON arac.part_model_compatibility
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON arac.users
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON arac.orders
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_order_items_updated_at
    BEFORE UPDATE ON arac.order_items
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();

CREATE TRIGGER update_stock_movements_updated_at
    BEFORE UPDATE ON arac.stock_movements
    FOR EACH ROW
    EXECUTE FUNCTION arac.update_updated_at_column();