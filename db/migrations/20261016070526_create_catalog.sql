-- migrate:up
CREATE EXTENSION IF NOT EXISTS pg_trgm;   -- fuzzy text search, used in Lesson 7

CREATE TABLE brands (
  id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE categories (
  id        bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  parent_id bigint REFERENCES categories(id),   -- self-reference = a tree
  name      text NOT NULL,
  slug      text NOT NULL UNIQUE
);

CREATE TABLE products (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  brand_id    bigint NOT NULL REFERENCES brands(id),
  category_id bigint NOT NULL REFERENCES categories(id),
  name        text NOT NULL,
  specs       jsonb NOT NULL DEFAULT '{}',      -- tool specs vary wildly by type
  is_active   boolean NOT NULL DEFAULT true,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE skus (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id   bigint NOT NULL REFERENCES products(id),
  sku_code     text NOT NULL UNIQUE,
  variant_name text NOT NULL,                     -- "Skin only", "Kit 5.0Ah"
  price_cents  bigint NOT NULL CHECK (price_cents >= 0),
  is_active    boolean NOT NULL DEFAULT true
);

-- Postgres does NOT index foreign keys automatically. Joins and deletes need these.
CREATE INDEX products_brand_id_idx    ON products (brand_id);
CREATE INDEX products_category_id_idx ON products (category_id);
CREATE INDEX skus_product_id_idx      ON skus (product_id);

-- migrate:down
DROP TABLE skus;
DROP TABLE products;
DROP TABLE categories;
DROP TABLE brands;