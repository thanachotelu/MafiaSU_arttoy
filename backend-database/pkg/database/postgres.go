package database

import (
	"context"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

type Product struct {
	ID          string    `json:"product_id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Brand       string    `json:"brand"`
	ModelNumber string    `json:"model_number"`
	Price       float64   `json:"price"`
	Status      string    `json:"status"`
	SellerID    string    `json:"seller_id"`
	ProductType string    `json:"product_type"`
	CategoryID  int       `json:"category_id"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type NewProduct struct {
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Brand       string  `json:"brand"`
	ModelNumber string  `json:"model_number"`
	Price       float64 `json:"price"`
	Status      string  `json:"status"`
	SellerID    string  `json:"seller_id"`
	ProductType string  `json:"product_type"`
	CategoryID  int     `json:"category_id"`
}

type UpdateProduct struct {
	Price  float64 `json:"price"`
	Status string  `json:"status"`
}

type ProductImage struct {
	ID        string    `json:"id"`
	ProductID string    `json:"product_id"`
	ImageURL  string    `json:"image_url"`
	IsPrimary bool      `json:"is_primary"`
	SortOrder int       `json:"sort_order"`
	CreatedAt time.Time `json:"created_at"`
}

type NewProductImage struct {
	ImageURL  string `json:"image_url"`
	IsPrimary bool   `json:"is_primary"`
	SortOrder int    `json:"sort_order"`
}

type UpdateProductImage struct {
	IsPrimary bool `json:"is_primary"`
	SortOrder int  `json:"sort_order"`
}

type ProductQueryParams struct {
	Cursor      string `json:"cursor"`
	Limit       int    `json:"limit"`
	Search      string `json:"search"`
	CategoryID  int    `json:"category_id"`
	SellerID    string `json:"seller_id"`
	Status      string `json:"status"`
	ProductType string `json:"product_type"`
	Sort        string `json:"sort"`
	Order       string `json:"order"`
}

type ProductResponse struct {
	Items      []ProductItem `json:"items"`
	NextCursor string        `json:"next_cursor"`
	Limit      int           `json:"limit"`
}

type ProductItem struct {
	Product
	Categories []Category     `json:"categories"`
	Inventory  Inventory      `json:"inventory"`
	Images     []ProductImage `json:"images"`
	Sellers    []Seller       `json:"sellers"`
}

type Category struct {
	ID          int    `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

type Inventory struct {
	Quantity  int       `json:"quantity"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Seller struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	Contact string `json:"contact"`
}

type ProductOption struct {
	ID     string          `json:"id"`
	Name   string          `json:"name"`
	Values json.RawMessage `json:"values"`
}

type EcommerceDatabase interface {
	GetProduct(ctx context.Context, id string) (ProductItem, error)
	AddProduct(ctx context.Context, product NewProduct) (Product, error)
	UpdateProduct(ctx context.Context, id string, update UpdateProduct) (Product, error)
	DeleteProduct(ctx context.Context, id string) error
	GetProducts(ctx context.Context, params ProductQueryParams) (*ProductResponse, error)
	GetRecommendProduct(ctx context.Context, params ProductQueryParams) (*ProductResponse, error)
	GetProductImages(ctx context.Context, productID string) ([]ProductImage, error)
	AddProductImage(ctx context.Context, productID string, image NewProductImage) (ProductImage, error)
	UpdateProductImage(ctx context.Context, productID, imageID string, update UpdateProductImage) (ProductImage, error)
	DeleteProductImage(ctx context.Context, productID, imageID string) error
	UpdateOrderInventory(ctx context.Context, productID string, quantity int) (Inventory, error)
	Close() error
	Ping() error
}

type PostgresDB struct {
	*sqlx.DB
	dsn string
}

func NewPostgresDB(dataSourceName string) (*PostgresDB, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	db, err := sqlx.ConnectContext(ctx, "postgres", dataSourceName)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// กำหนดค่า connection pool
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(5 * time.Minute)

	// ทดสอบการเชื่อมต่อ
	if err = db.PingContext(ctx); err != nil {
		db.Close() // ปิดการเชื่อมต่อถ้าไม่สามารถ ping ได้
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return &PostgresDB{
		DB:  db,
		dsn: dataSourceName,
	}, nil
}

func (db *PostgresDB) Reconnect() error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	newDB, err := sqlx.ConnectContext(ctx, "postgres", db.dsn)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	// ตั้งค่า connection pool
	newDB.SetMaxOpenConns(25)
	newDB.SetMaxIdleConns(10)
	newDB.SetConnMaxLifetime(5 * time.Minute)

	// ทดสอบการเชื่อมต่อ
	if err = newDB.PingContext(ctx); err != nil {
		newDB.Close() // ปิดการเชื่อมต่อใหม่ถ้าไม่สามารถ ping ได้
		return fmt.Errorf("failed to ping database: %w", err)
	}

	// ปิดการเชื่อมต่อเดิม (ถ้ามี) และกำหนดการเชื่อมต่อใหม่
	if db.DB != nil {
		db.DB.Close()
	}
	db.DB = newDB

	return nil
}

func (db *PostgresDB) Close() error {
	return db.DB.Close()
}

func (pdb *PostgresDB) GetProduct(ctx context.Context, id string) (ProductItem, error) {
	var product ProductItem
	var category Category

	// ดึงข้อมูลหลักของสินค้าและหมวดหมู่
	err := pdb.DB.QueryRowContext(ctx, `
		SELECT p.product_id, p.name, p.description, p.brand, p.model_number, p.price, 
		       p.status, p.seller_id, p.product_type, p.created_at, p.updated_at,
		       c.category_id, c.name as category_name
		FROM products p
		LEFT JOIN categories c ON p.category_id = c.category_id
		WHERE p.product_id = $1
	`, id).Scan(
		&product.ID, &product.Name, &product.Description, &product.Brand,
		&product.ModelNumber, &product.Price, &product.Status,
		&product.SellerID, &product.ProductType, &product.CreatedAt, &product.UpdatedAt,
		&category.ID, &category.Name)

	if err != nil {
		if err == sql.ErrNoRows {
			return ProductItem{}, fmt.Errorf("product not found")
		}
		return ProductItem{}, fmt.Errorf("failed to get product: %v", err)
	}

	product.Categories = []Category{category}

	// ดึงข้อมูล inventory
	err = pdb.DB.QueryRowContext(ctx, `
		SELECT quantity, updated_at
		FROM inventory
		WHERE product_id = $1
	`, id).Scan(&product.Inventory.Quantity, &product.Inventory.UpdatedAt)

	if err != nil && err != sql.ErrNoRows {
		return ProductItem{}, fmt.Errorf("failed to get inventory: %v", err)
	}

	// ดึงข้อมูลรูปภาพ
	product.Images, err = pdb.GetProductImages(ctx, id)
	if err != nil {
		return ProductItem{}, fmt.Errorf("failed to get product images: %v", err)
	}

	return product, nil
}

func (pdb *PostgresDB) AddProduct(ctx context.Context, product NewProduct) (Product, error) {
	var createdProduct Product
	err := pdb.DB.QueryRowContext(ctx, `
		INSERT INTO products (name, description, brand, model_number, price, status, seller_id, product_type, category_id) 
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
		RETURNING product_id, name, description, brand, model_number, price, status, seller_id, product_type, category_id, created_at, updated_at
	`,
		product.Name, product.Description, product.Brand, product.ModelNumber, product.Price, product.Status, product.SellerID, product.ProductType, product.CategoryID,
	).Scan(
		&createdProduct.ID, &createdProduct.Name, &createdProduct.Description, &createdProduct.Brand,
		&createdProduct.ModelNumber, &createdProduct.Price, &createdProduct.Status,
		&createdProduct.SellerID, &createdProduct.ProductType, &createdProduct.CategoryID,
		&createdProduct.CreatedAt, &createdProduct.UpdatedAt)
	if err != nil {
		return Product{}, fmt.Errorf("failed to add product: %v", err)
	}
	return createdProduct, nil
}

func (pdb *PostgresDB) UpdateProduct(ctx context.Context, id string, update UpdateProduct) (Product, error) {
	var updatedProduct Product
	err := pdb.DB.QueryRowContext(ctx, `
		UPDATE products 
		SET price = $1, status = $2, updated_at = NOW() 
		WHERE product_id = $3 
		RETURNING product_id, name, description, brand, model_number, price, status, seller_id, product_type, category_id, created_at, updated_at
	`,
		update.Price, update.Status, id,
	).Scan(
		&updatedProduct.ID, &updatedProduct.Name, &updatedProduct.Description, &updatedProduct.Brand,
		&updatedProduct.ModelNumber, &updatedProduct.Price, &updatedProduct.Status,
		&updatedProduct.SellerID, &updatedProduct.ProductType, &updatedProduct.CategoryID,
		&updatedProduct.CreatedAt, &updatedProduct.UpdatedAt)
	if err != nil {
		return Product{}, fmt.Errorf("failed to update product: %v", err)
	}
	return updatedProduct, nil
}

func (pdb *PostgresDB) DeleteProduct(ctx context.Context, id string) error {
	result, err := pdb.DB.ExecContext(ctx, "DELETE FROM products WHERE product_id = $1", id)
	if err != nil {
		return fmt.Errorf("failed to delete product: %v", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %v", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("product not found")
	}

	return nil
}

func (pdb *PostgresDB) GetProducts(ctx context.Context, params ProductQueryParams) (*ProductResponse, error) {
	query := `
        SELECT p.product_id, p.name, p.description, p.brand, p.model_number, p.price, 
               p.status, p.product_type, p.created_at, p.updated_at,
			   s.seller_id, s.name as seller_name,
               c.category_id, c.name as category_name,
               i.quantity, i.updated_at as inventory_updated_at
        FROM products p
		LEFT JOIN sellers s ON p.seller_id = s.seller_id
        LEFT JOIN categories c ON p.category_id = c.category_id
        LEFT JOIN inventory i ON p.product_id = i.product_id
        WHERE 1=1`

	args := []interface{}{}
	placeholderCount := 1

	// การจัดการพารามิเตอร์ cursor
	if params.Cursor != "" {
		cursor, err := decodeCursor(params.Cursor)
		if err != nil {
			return nil, fmt.Errorf("invalid cursor: %v", err)
		}
		query += fmt.Sprintf(" AND (p.created_at, p.product_id) > ($%d, $%d)", placeholderCount, placeholderCount+1)
		args = append(args, cursor.CreatedAt, cursor.ProductID)
		placeholderCount += 2
	}

	// การจัดการพารามิเตอร์ search
	if params.Search != "" {
		query += fmt.Sprintf(" AND (p.name ILIKE $%d OR p.description ILIKE $%d)", placeholderCount, placeholderCount+1)
		args = append(args, "%"+params.Search+"%", "%"+params.Search+"%")
		placeholderCount += 2
	}

	// การจัดการพารามิเตอร์ category_id
	if params.CategoryID != 0 {
		query += fmt.Sprintf(" AND p.category_id = $%d", placeholderCount)
		args = append(args, params.CategoryID)
		placeholderCount++
	}

	// การจัดการพารามิเตอร์ seller_id
	if params.SellerID != "" {
		query += fmt.Sprintf(" AND p.seller_id = $%d", placeholderCount)
		args = append(args, params.SellerID)
		placeholderCount++
	}

	// การจัดการพารามิเตอร์ status
	if params.Status != "" {
		query += fmt.Sprintf(" AND p.status = $%d", placeholderCount)
		args = append(args, params.Status)
		placeholderCount++
	}

	// การจัดการพารามิเตอร์ product_type
	if params.ProductType != "" {
		query += fmt.Sprintf(" AND p.product_type = $%d", placeholderCount)
		args = append(args, params.ProductType)
		placeholderCount++
	}

	// การจัดการ ORDER BY ด้วย sort และ order
	sortFields := map[string]string{
		"name":       "p.name",
		"price":      "p.price",
		"created_at": "p.created_at",
	}

	orderDirections := map[string]string{
		"asc":  "ASC",
		"desc": "DESC",
	}

	sortColumn, ok := sortFields[params.Sort]
	if !ok {
		// กำหนดค่า default หาก sort ไม่ถูกต้องหรือไม่ได้ระบุ
		sortColumn = "p.created_at"
	}

	orderDirection, ok := orderDirections[strings.ToLower(params.Order)]
	if !ok {
		// กำหนดค่า default หาก order ไม่ถูกต้องหรือไม่ได้ระบุ
		orderDirection = "ASC"
	}

	query += fmt.Sprintf(" ORDER BY %s %s, p.product_id ASC", sortColumn, orderDirection)

	// การกำหนดค่า limit
	limit := 3
	if params.Limit > 0 && params.Limit <= 100 {
		limit = params.Limit
	}
	query += fmt.Sprintf(" LIMIT $%d", placeholderCount)
	args = append(args, limit+1)
	placeholderCount++

	// log.Printf("Query: %s", query)
	// log.Printf("Args: %v", args)

	// ดำเนินการ query และประมวลผลผลลัพธ์
	rows, err := pdb.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to get products: %v", err)
	}
	defer rows.Close()

	var products []ProductItem
	for rows.Next() {
		var product ProductItem
		var category Category
		var inventory Inventory
		var seller Seller
		if err := rows.Scan(
			&product.ID, &product.Name, &product.Description, &product.Brand,
			&product.ModelNumber, &product.Price, &product.Status,
			&product.ProductType, &product.CreatedAt, &product.UpdatedAt,
			&seller.ID, &seller.Name,
			&category.ID, &category.Name,
			&inventory.Quantity, &inventory.UpdatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan product: %v", err)
		}
		product.Categories = []Category{category}
		product.Inventory = inventory
		product.Sellers = []Seller{seller}

		// การดึงข้อมูลรูปภาพและตัวเลือกของผลิตภัณฑ์
		product.Images, err = pdb.GetProductImages(ctx, product.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product images: %v", err)
		}

		products = append(products, product)
		if len(products) == limit+1 {
			break
		}
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate over products: %v", err)
	}

	response := &ProductResponse{
		Items: products[:min(len(products), limit)],
		Limit: limit,
	}

	if len(products) > limit {
		lastProduct := products[limit-1]
		response.NextCursor = encodeCursor(Cursor{CreatedAt: lastProduct.CreatedAt, ProductID: lastProduct.ID})
	} else {
		response.NextCursor = ""
	}

	return response, nil
}

func (pdb *PostgresDB) UpdateOrderInventory(ctx context.Context, productID string, quantity int) (Inventory, error) {
	var inventory Inventory

	err := pdb.QueryRowContext(ctx, "SELECT quantity FROM inventory WHERE product_id = $1", productID).Scan(&inventory.Quantity)
	if err != nil {
		return Inventory{}, err
	}

	if inventory.Quantity+quantity < 0 {
		return Inventory{}, fmt.Errorf("insufficient inventory: cannot reduce quantity below zero")
	}

	_, err = pdb.ExecContext(ctx, "UPDATE inventory SET quantity = quantity - $1, updated_at = CURRENT_DATE WHERE product_id = $2", quantity, productID)
	if err != nil {
		return Inventory{}, err
	}

	err = pdb.QueryRowContext(ctx, "SELECT quantity, updated_at FROM inventory WHERE product_id = $1", productID).Scan(&inventory.Quantity, &inventory.UpdatedAt)
	if err != nil {
		return Inventory{}, err
	}

	return inventory, nil
}

// GetRecommended
func (pdb *PostgresDB) GetRecommendProduct(ctx context.Context, params ProductQueryParams) (*ProductResponse, error) {
	query := `
        SELECT p.product_id, p.name, p.description, p.brand, p.model_number, p.price, 
               p.status, p.product_type, p.created_at, p.updated_at,
			   s.seller_id, s.name as seller_name,
               c.category_id, c.name as category_name,
               i.quantity, i.updated_at as inventory_updated_at
        FROM products p
		LEFT JOIN sellers s ON p.seller_id = s.seller_id
        LEFT JOIN categories c ON p.category_id = c.category_id
        LEFT JOIN inventory i ON p.product_id = i.product_id
        WHERE 1=1`

	args := []interface{}{}
	placeholderCount := 1

	// การจัดการพารามิเตอร์ cursor
	if params.Cursor != "" {
		cursor, err := decodeCursor(params.Cursor)
		if err != nil {
			return nil, fmt.Errorf("invalid cursor: %v", err)
		}
		query += fmt.Sprintf(" AND (p.created_at, p.product_id) > ($%d, $%d)", placeholderCount, placeholderCount+1)
		args = append(args, cursor.CreatedAt, cursor.ProductID)
		placeholderCount += 2
	}

	// การจัดการพารามิเตอร์ search
	if params.Search != "" {
		query += fmt.Sprintf(" AND (p.name ILIKE $%d OR p.description ILIKE $%d)", placeholderCount, placeholderCount+1)
		args = append(args, "%"+params.Search+"%", "%"+params.Search+"%")
		placeholderCount += 2
	}

	// การจัดการพารามิเตอร์ category_id
	if params.CategoryID != 0 {
		query += fmt.Sprintf(" AND p.category_id = $%d", placeholderCount)
		args = append(args, params.CategoryID)
		placeholderCount++
	}

	// การจัดการพารามิเตอร์ seller_id
	if params.SellerID != "" {
		query += fmt.Sprintf(" AND p.seller_id = $%d", placeholderCount)
		args = append(args, params.SellerID)
		placeholderCount++
	}

	// การจัดการพารามิเตอร์ status
	if params.Status != "" {
		query += fmt.Sprintf(" AND p.status = $%d", placeholderCount)
		args = append(args, params.Status)
		placeholderCount++
	}

	// การจัดการพารามิเตอร์ product_type
	if params.ProductType != "" {
		query += fmt.Sprintf(" AND p.product_type = $%d", placeholderCount)
		args = append(args, params.ProductType)
		placeholderCount++
	}

	// การจัดการ ORDER BY ด้วย sort และ order
	sortFields := map[string]string{
		"name":       "p.name",
		"price":      "p.price",
		"created_at": "p.created_at",
	}

	orderDirections := map[string]string{
		"asc":  "ASC",
		"desc": "DESC",
	}

	sortColumn, ok := sortFields[params.Sort]
	if !ok {
		// กำหนดค่า default หาก sort ไม่ถูกต้องหรือไม่ได้ระบุ
		sortColumn = "p.created_at"
	}

	orderDirection, ok := orderDirections[strings.ToLower(params.Order)]
	if !ok {
		// กำหนดค่า default หาก order ไม่ถูกต้องหรือไม่ได้ระบุ
		orderDirection = "ASC"
	}

	query += fmt.Sprintf(" ORDER BY RANDOM(),%s %s, p.product_id ASC", sortColumn, orderDirection)

	// การกำหนดค่า limit
	limit := 20
	if params.Limit > 0 && params.Limit <= 100 {
		limit = params.Limit
	}
	query += fmt.Sprintf(" LIMIT $%d", placeholderCount)
	args = append(args, limit+1)
	placeholderCount++

	// log.Printf("Query: %s", query)
	// log.Printf("Args: %v", args)

	// ดำเนินการ query และประมวลผลผลลัพธ์
	rows, err := pdb.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to get products: %v", err)
	}
	defer rows.Close()

	var products []ProductItem
	for rows.Next() {
		var product ProductItem
		var category Category
		var inventory Inventory
		var seller Seller
		if err := rows.Scan(
			&product.ID, &product.Name, &product.Description, &product.Brand,
			&product.ModelNumber, &product.Price, &product.Status,
			&product.ProductType, &product.CreatedAt, &product.UpdatedAt,
			&seller.ID, &seller.Name,
			&category.ID, &category.Name,
			&inventory.Quantity, &inventory.UpdatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan product: %v", err)
		}
		product.Categories = []Category{category}
		product.Inventory = inventory
		product.Sellers = []Seller{seller}

		// การดึงข้อมูลรูปภาพและตัวเลือกของผลิตภัณฑ์
		product.Images, err = pdb.GetProductImages(ctx, product.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product images: %v", err)
		}

		products = append(products, product)
		if len(products) == limit+1 {
			break
		}
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate over products: %v", err)
	}

	response := &ProductResponse{
		Items: products[:min(len(products), limit)],
		Limit: limit,
	}

	if len(products) > limit {
		lastProduct := products[limit-1]
		response.NextCursor = encodeCursor(Cursor{CreatedAt: lastProduct.CreatedAt, ProductID: lastProduct.ID})
	} else {
		response.NextCursor = ""
	}

	return response, nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

type Cursor struct {
	CreatedAt time.Time
	ProductID string
}

func (pdb *PostgresDB) GetProductImages(ctx context.Context, productID string) ([]ProductImage, error) {
	rows, err := pdb.DB.QueryContext(ctx, `
		SELECT image_id, product_id, image_url, is_primary, sort_order, created_at 
		FROM product_images 
		WHERE product_id = $1 
		ORDER BY sort_order ASC
	`, productID)
	if err != nil {
		return nil, fmt.Errorf("failed to get product images: %v", err)
	}
	defer rows.Close()

	var images []ProductImage
	for rows.Next() {
		var image ProductImage
		if err := rows.Scan(
			&image.ID, &image.ProductID, &image.ImageURL, &image.IsPrimary,
			&image.SortOrder, &image.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan product image: %v", err)
		}
		images = append(images, image)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate over product images: %v", err)
	}

	return images, nil
}

func (pdb *PostgresDB) AddProductImage(ctx context.Context, productID string, image NewProductImage) (ProductImage, error) {
	var createdImage ProductImage
	err := pdb.DB.QueryRowContext(ctx, `
		INSERT INTO product_images (product_id, image_url, is_primary, sort_order) 
		VALUES ($1, $2, $3, $4) 
		RETURNING image_id, product_id, image_url, is_primary, sort_order, created_at
	`,
		productID, image.ImageURL, image.IsPrimary, image.SortOrder,
	).Scan(
		&createdImage.ID, &createdImage.ProductID, &createdImage.ImageURL,
		&createdImage.IsPrimary, &createdImage.SortOrder, &createdImage.CreatedAt)
	if err != nil {
		return ProductImage{}, fmt.Errorf("failed to add product image: %v", err)
	}
	return createdImage, nil
}

func (pdb *PostgresDB) UpdateProductImage(ctx context.Context, productID string, imageID string, update UpdateProductImage) (ProductImage, error) {
	var updatedImage ProductImage
	err := pdb.DB.QueryRowContext(ctx, `
		UPDATE product_images 
		SET is_primary = $1, sort_order = $2, updated_at = NOW() 
		WHERE product_id = $3 AND image_id = $4 
		RETURNING image_id, product_id, image_url, is_primary, sort_order, created_at
	`,
		update.IsPrimary, update.SortOrder, productID, imageID,
	).Scan(
		&updatedImage.ID, &updatedImage.ProductID, &updatedImage.ImageURL,
		&updatedImage.IsPrimary, &updatedImage.SortOrder, &updatedImage.CreatedAt)
	if err != nil {
		return ProductImage{}, fmt.Errorf("failed to update product image: %v", err)
	}
	return updatedImage, nil
}

func (pdb *PostgresDB) DeleteProductImage(ctx context.Context, productID string, imageID string) error {
	result, err := pdb.DB.ExecContext(ctx, `
		DELETE FROM product_images 
		WHERE product_id = $1 AND image_id = $2
	`, productID, imageID)
	if err != nil {
		return fmt.Errorf("failed to delete product image: %v", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %v", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("product image not found")
	}

	return nil
}

func (pdb *PostgresDB) Ping() error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	return pdb.DB.PingContext(ctx)
}

func encodeCursor(c Cursor) string {
	return base64.StdEncoding.EncodeToString([]byte(fmt.Sprintf("%s,%s", c.CreatedAt.Format(time.RFC3339Nano), c.ProductID)))
}

func decodeCursor(s string) (Cursor, error) {
	b, err := base64.StdEncoding.DecodeString(s)
	if err != nil {
		return Cursor{}, err
	}
	parts := strings.Split(string(b), ",")
	if len(parts) != 2 {
		return Cursor{}, fmt.Errorf("invalid cursor format")
	}
	createdAt, err := time.Parse(time.RFC3339Nano, parts[0])
	if err != nil {
		return Cursor{}, err
	}
	return Cursor{CreatedAt: createdAt, ProductID: parts[1]}, nil
}

type Store struct {
	db EcommerceDatabase
}

func NewStore(db EcommerceDatabase) *Store {
	return &Store{db: db}
}

func (s *Store) GetProduct(ctx context.Context, id string) (ProductItem, error) {
	return s.db.GetProduct(ctx, id)
}

func (s *Store) AddProduct(ctx context.Context, product NewProduct) (Product, error) {
	return s.db.AddProduct(ctx, product)
}

func (s *Store) UpdateProduct(ctx context.Context, id string, update UpdateProduct) (Product, error) {
	return s.db.UpdateProduct(ctx, id, update)
}

func (s *Store) DeleteProduct(ctx context.Context, id string) error {
	return s.db.DeleteProduct(ctx, id)
}

func (s *Store) GetProducts(ctx context.Context, params ProductQueryParams) (*ProductResponse, error) {
	return s.db.GetProducts(ctx, params)
}

func (s *Store) GetRecommendProduct(ctx context.Context, params ProductQueryParams) (*ProductResponse, error) {
	return s.db.GetRecommendProduct(ctx, params)
}

func (s *Store) GetProductImages(ctx context.Context, productID string) ([]ProductImage, error) {
	return s.db.GetProductImages(ctx, productID)
}

func (s *Store) UpdateOrderInventory(ctx context.Context, productID string, quantity int) (Inventory, error) {
	return s.db.UpdateOrderInventory(ctx, productID, quantity)
}

func (s *Store) AddProductImage(ctx context.Context, productID string, image NewProductImage) (ProductImage, error) {
	return s.db.AddProductImage(ctx, productID, image)
}

func (s *Store) UpdateProductImage(ctx context.Context, productID string, imageID string, update UpdateProductImage) (ProductImage, error) {
	return s.db.UpdateProductImage(ctx, productID, imageID, update)
}

func (s *Store) DeleteProductImage(ctx context.Context, productID string, imageID string) error {
	return s.db.DeleteProductImage(ctx, productID, imageID)
}

func (s *Store) Close() error {
	return s.db.Close()
}

func (s *Store) Ping() error {
	if s.db == nil {
		return fmt.Errorf("database connection is not initialized")
	}
	return s.db.Ping()
}
