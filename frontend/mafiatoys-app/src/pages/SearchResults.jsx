import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useSearchParams, Link } from 'react-router-dom';
import { Container, Row, Col, Card, Button } from 'react-bootstrap';
import TopMenu from '../components/TopMenu';
import Footer from '../components/Footer';

const placeholderImage = '../assets/images/placeholder.jpg';

const SearchResults = () => {
  const [products, setProducts] = useState([]);
  const [sortedProducts, setSortedProducts] = useState([]);
  const [searchParams] = useSearchParams();
  const [sortOption, setSortOption] = useState('');
  const [error, setError] = useState(null); // ใช้สำหรับเก็บข้อผิดพลาด

  const searchQuery = searchParams.get('q');

  const handleSortChange = (e) => {
    setSortOption(e.target.value);
};

const sortProducts = (products, option) => {
  let sorted = [...products];
  if (option === 'price-asc') {
    sorted.sort((a, b) => a.price - b.price); // เรียงจากราคาต่ำไปสูง
  } else if (option === 'price-desc') {
    sorted.sort((a, b) => b.price - a.price); // เรียงจากราคาสูงไปต่ำ
  }
  return sorted;
};

  // ฟังก์ชันดึงข้อมูลสินค้าจาก API
  const fetchProducts = (query) => {
    if (query) {
      axios
        .get(`/api/v1/products?search=${query}&limit=20`)
        .then((response) => {
          if (response.data.items) {
            setProducts(response.data.items); // ตั้งค่า products ด้วยข้อมูลจาก API
            setSortedProducts(sortProducts(response.data.items, sortOption)); // จัดเรียงสินค้าเมื่อได้รับข้อมูล
            setError(null); // ล้าง error หากมีข้อมูล
          } else if (response.data.error) {
            setError(response.data.error); // เก็บข้อความข้อผิดพลาด
            setProducts([]); // ล้างรายการ products
          }
        })
        .catch((error) => {
          console.error('Error fetching the products:', error);
          setError('ไม่สามารถดึงข้อมูลสินค้ามาได้'); // เก็บข้อความข้อผิดพลาด
        });
    } else {
      setProducts([]);
    }
  };

  useEffect(() => {
    fetchProducts(searchQuery);
  }, [searchQuery]);

  useEffect(() => {
    setSortedProducts(sortProducts(products, sortOption));
  }, [sortOption, products]);

  return (
    <div>
      <TopMenu />

      <Container className="my-5">
      <div className="sort-container-right">
        <h2 className="text-center mb-4">ผลการค้นหาสำหรับ "{searchQuery}"</h2>
            <label>Sort by: </label>
            <select onChange={handleSortChange} value={sortOption}>
                <option value="">None</option>
                <option value="price-asc">Price: Low to High</option>
                <option value="price-desc">Price: High to Low</option>
            </select>
        </div>   
        <Row>
          {error ? (
            <p className="text-center">{error}</p> // แสดงข้อความข้อผิดพลาด
          ) : sortedProducts.length > 0 ? (
            sortedProducts.map((product) => {
              const primaryImage = product.images.find((img) => img.is_primary)?.image_url || placeholderImage;

              return (
                <Col md={12} key={product.id}>
                  <Card className="mb-4 p-3" style={{ border: '1px solid #e5e5e5' }}>
                    <Row>
                      <Col md={3}>
                        <Card.Img
                          src={primaryImage}
                          onError={(e) => {
                            e.target.onerror = null;
                            e.target.src = placeholderImage;
                          }}
                          style={{ maxHeight: '150px', objectFit: 'contain' }}
                        />
                      </Col>
                      <Col md={6}>
                        <Card.Body>
                          <Card.Title style={{ fontSize: '1.5rem', color: '#007bff' }}>
                            {product.name}
                          </Card.Title>
                          <div style={{ fontSize: '1.2rem', color: '#ff6600' }}>
                            <strong>{product.price ? `฿${product.price}` : 'ราคาไม่ระบุ'}</strong>
                          </div>
                          <Card.Text>
                            {product.description ? product.description : 'ไม่มีคำอธิบายสินค้า'}
                          </Card.Text>
                          <div className="d-flex align-items-center">
                            <span className="badge bg-success me-2">New</span>
                            {product.price && (
                              <span className="badge bg-danger me-2">Hot</span>
                            )}
                          </div>
                        </Card.Body>
                      </Col>
                      <Col md={3} className="d-flex align-items-center justify-content-center">
                        <div>
                          <Button variant="primary" className="me-2">
                            เพิ่มลงในตะกร้า
                          </Button>
                          <Link to={`/product/${product.id}`}>
                            <Button variant="outline-secondary">
                              ดูรายละเอียด
                            </Button>
                          </Link>
                        </div>
                      </Col>
                    </Row>
                  </Card>
                </Col>
              );
            })
          ) : (
            <p className="text-center">ไม่พบสินค้าที่ค้นหา</p>
          )}
        </Row>
      </Container>
      <Footer />
    </div>
  );
};

export default SearchResults;