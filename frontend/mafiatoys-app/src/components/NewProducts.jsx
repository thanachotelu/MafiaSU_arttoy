import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Card, Container, Row, Col } from 'react-bootstrap';
import { Link } from 'react-router-dom';

const NewProducts = () => {
  const [products, setProducts] = useState([]);
  const placeholderImage = '../assets/images/placeholder.jpg';

  useEffect(() => {
    axios
      .get('/api/v1/products?sort=created_at&order=desc&limit=3')
      .then((response) => {
        setProducts(response.data.items);
      })
      .catch((error) => {
        console.error('Error fetching the products:', error);
      });
  }, []);

  return (
    <Container className="my-5">
      <h2 className="text-center mb-4" style={{ fontWeight: 'bold', color: 'red' }}>สินค้ามาใหม่</h2>
      <Row>
        {products.length > 0 ? (
          products.map((product) => {
            const primaryImage = product.images.find((img) => img.is_primary)?.image_url;

            return (
              <Col md={4} key={product.product_id}>
                <Link to={`/products/${product.product_id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                  <Card className="mb-4" style={{ cursor: 'pointer' , height: '100%'}}>
                    <Card.Img
                      variant="top"
                      src={primaryImage || placeholderImage}
                      alt={product.name}
                      onError={(e) => {
                        e.target.onerror = null;
                        e.target.src = placeholderImage;
                      }}
                    />
                    <Card.Body>
                      <Card.Title>{product.name}</Card.Title>
                      <Card.Text style={{color: 'red', fontWeight: 'none'}}>
                        <strong>฿{product.price.toLocaleString('th-TH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</strong>
                      </Card.Text>
                    </Card.Body>
                  </Card>
                </Link>
              </Col>
            );
          })
        ) : (
          <p className="text-center">ไม่พบสินค้าที่ค้นหา</p>
        )}
      </Row>
    </Container>
  );
};

export default NewProducts;
