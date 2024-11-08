// ecommerce.go
package product

import (
	"context"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	_ "github.com/lib/pq"
)

type Product struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Brand       string    `json:"brand"`
	ModelNumber string    `json:"model_number"`
	SKU         string    `json:"sku"`
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
	SKU         string  `json:"sku"`
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
	Categories []Category      `json:"categories"`
	Inventory  Inventory       `json:"inventory"`
	Images     []ProductImage  `json:"images"`
	Options    []ProductOption `json:"options"`
}

type Category struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type Inventory struct {
	Quantity  int       `json:"quantity"`
	UpdatedAt time.Time `json:"updated_at"`
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
	GetProductImages(ctx context.Context, productID string) ([]ProductImage, error)
	AddProductImage(ctx context.Context, productID string, image NewProductImage) (ProductImage, error)
	UpdateProductImage(ctx context.Context, productID, imageID string, update UpdateProductImage) (ProductImage, error)
	DeleteProductImage(ctx context.Context, productID, imageID string) error
	Close() error
	Ping() error
	Reconnect(connStr string) error
}

type PostgresDatabase struct {
	db *sql.DB
}

func NewPostgresDatabase(connStr string) (*PostgresDatabase, error) {
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %v", err)
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(5 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %v", err)
	}

	return &PostgresDatabase{db: db}, nil
}

func (pdb *PostgresDatabase) GetProduct(ctx context.Context, id string) (ProductItem, error) {
	var product ProductItem
	var category Category

	// ดึงข้อมูลหลักของสินค้าและหมวดหมู่
	err := pdb.db.QueryRowContext(ctx, `
		SELECT p.product_id, p.name, p.description, p.brand, p.model_number, p.sku, p.price, 
		       p.status, p.seller_id, p.product_type, p.created_at, p.updated_at,
		       c.category_id, c.name as category_name
		FROM products p
		LEFT JOIN categories c ON p.category_id = c.category_id
		WHERE p.product_id = $1
	`, id).Scan(
		&product.ID, &product.Name, &product.Description, &product.Brand,
		&product.ModelNumber, &product.SKU, &product.Price, &product.Status,
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
	err = pdb.db.QueryRowContext(ctx, `
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

	// ดึงข้อมูลตัวเลือก
	product.Options, err = pdb.getProductOptions(ctx, id)
	if err != nil {
		return ProductItem{}, fmt.Errorf("failed to get product options: %v", err)
	}

	return product, nil
}

func (pdb *PostgresDatabase) AddProduct(ctx context.Context, product NewProduct) (Product, error) {
	var createdProduct Product
	err := pdb.db.QueryRowContext(ctx, `
		INSERT INTO products (name, description, brand, model_number, sku, price, status, seller_id, product_type, category_id) 
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) 
		RETURNING product_id, name, description, brand, model_number, sku, price, status, seller_id, product_type, category_id, created_at, updated_at
	`,
		product.Name, product.Description, product.Brand, product.ModelNumber, product.SKU, product.Price, product.Status, product.SellerID, product.ProductType, product.CategoryID,
	).Scan(
		&createdProduct.ID, &createdProduct.Name, &createdProduct.Description, &createdProduct.Brand,
		&createdProduct.ModelNumber, &createdProduct.SKU, &createdProduct.Price, &createdProduct.Status,
		&createdProduct.SellerID, &createdProduct.ProductType, &createdProduct.CategoryID,
		&createdProduct.CreatedAt, &createdProduct.UpdatedAt)
	if err != nil {
		return Product{}, fmt.Errorf("failed to add product: %v", err)
	}
	return createdProduct, nil
}

func (pdb *PostgresDatabase) UpdateProduct(ctx context.Context, id string, update UpdateProduct) (Product, error) {
	var updatedProduct Product
	err := pdb.db.QueryRowContext(ctx, `
		UPDATE products 
		SET price = $1, status = $2, updated_at = NOW() 
		WHERE product_id = $3 
		RETURNING product_id, name, description, brand, model_number, sku, price, status, seller_id, product_type, category_id, created_at, updated_at
	`,
		update.Price, update.Status, id,
	).Scan(
		&updatedProduct.ID, &updatedProduct.Name, &updatedProduct.Description, &updatedProduct.Brand,
		&updatedProduct.ModelNumber, &updatedProduct.SKU, &updatedProduct.Price, &updatedProduct.Status,
		&updatedProduct.SellerID, &updatedProduct.ProductType, &updatedProduct.CategoryID,
		&updatedProduct.CreatedAt, &updatedProduct.UpdatedAt)
	if err != nil {
		return Product{}, fmt.Errorf("failed to update product: %v", err)
	}
	return updatedProduct, nil
}

func (pdb *PostgresDatabase) DeleteProduct(ctx context.Context, id string) error {
	result, err := pdb.db.ExecContext(ctx, "DELETE FROM products WHERE product_id = $1", id)
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

func (pdb *PostgresDatabase) GetProducts(ctx context.Context, params ProductQueryParams) (*ProductResponse, error) {
	query := `
        SELECT p.product_id, p.name, p.description, p.brand, p.model_number, p.sku, p.price, 
               p.status, p.seller_id, p.product_type, p.created_at, p.updated_at,
               c.category_id, c.name as category_name,
               i.quantity, i.updated_at as inventory_updated_at
        FROM products p
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
	rows, err := pdb.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to get products: %v", err)
	}
	defer rows.Close()

	var products []ProductItem
	for rows.Next() {
		var product ProductItem
		var category Category
		var inventory Inventory
		if err := rows.Scan(
			&product.ID, &product.Name, &product.Description, &product.Brand,
			&product.ModelNumber, &product.SKU, &product.Price, &product.Status,
			&product.SellerID, &product.ProductType, &product.CreatedAt, &product.UpdatedAt,
			&category.ID, &category.Name,
			&inventory.Quantity, &inventory.UpdatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan product: %v", err)
		}
		product.Categories = []Category{category}
		product.Inventory = inventory

		// การดึงข้อมูลรูปภาพและตัวเลือกของผลิตภัณฑ์
		product.Images, err = pdb.GetProductImages(ctx, product.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product images: %v", err)
		}
		product.Options, err = pdb.getProductOptions(ctx, product.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product options: %v", err)
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

func (pdb *PostgresDatabase) GetProductImages(ctx context.Context, productID string) ([]ProductImage, error) {
	rows, err := pdb.db.QueryContext(ctx, `
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

func (pdb *PostgresDatabase) AddProductImage(ctx context.Context, productID string, image NewProductImage) (ProductImage, error) {
	var createdImage ProductImage
	err := pdb.db.QueryRowContext(ctx, `
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

func (pdb *PostgresDatabase) UpdateProductImage(ctx context.Context, productID string, imageID string, update UpdateProductImage) (ProductImage, error) {
	var updatedImage ProductImage
	err := pdb.db.QueryRowContext(ctx, `
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

func (pdb *PostgresDatabase) DeleteProductImage(ctx context.Context, productID string, imageID string) error {
	result, err := pdb.db.ExecContext(ctx, `
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

func (pdb *PostgresDatabase) Close() error {
	return pdb.db.Close()
}

func (pdb *PostgresDatabase) Ping() error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	return pdb.db.PingContext(ctx)
}

func (pdb *PostgresDatabase) getProductOptions(ctx context.Context, productID string) ([]ProductOption, error) {
	rows, err := pdb.db.QueryContext(ctx, `
        SELECT option_id, name, values
        FROM product_options
        WHERE product_id = $1
    `, productID)
	if err != nil {
		return nil, fmt.Errorf("failed to get product options: %v", err)
	}
	defer rows.Close()

	var options []ProductOption
	for rows.Next() {
		var option ProductOption
		if err := rows.Scan(&option.ID, &option.Name, &option.Values); err != nil {
			return nil, fmt.Errorf("failed to scan product option: %v", err)
		}
		options = append(options, option)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate over product options: %v", err)
	}

	return options, nil
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

func (pdb *PostgresDatabase) Reconnect(connStr string) error {
	if pdb.db != nil {
		pdb.db.Close()
	}

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %v", err)
	}

	// ตั้งค่า connection pool
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(5 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		return fmt.Errorf("failed to ping database: %v", err)
	}

	pdb.db = db
	return nil
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

func (s *Store) GetProductImages(ctx context.Context, productID string) ([]ProductImage, error) {
	return s.db.GetProductImages(ctx, productID)
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

func (s *Store) Reconnect(connStr string) error {
	return s.db.Reconnect(connStr)
}
