import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Card, Container, Row, Col } from 'react-bootstrap';
import { Link } from 'react-router-dom';

const NewProduct = () => {
  const [products, setProducts] = useState([]);
  const placeholderImage = '../assets/images/placeholder.jpg';

  useEffect(() => {
    axios
      .get('/api/v1/products?sort=created_at&order=desc&limit=20')
      .then((response) => {
        const allProducts = response.data.items;

        const uniqueProducts = [];
        const seenSellers = new Set();

        for (const product of allProducts) {
          if (product.sellers && product.sellers[0] && !seenSellers.has(product.sellers[0].id)) {
            uniqueProducts.push(product);
            seenSellers.add(product.sellers[0].id);
          }
          if (uniqueProducts.length === 5) break; // หยุดเมื่อครบ 5 ชิ้น
        }

        setProducts(uniqueProducts);
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
                      <Card.Title align="left" style={{color: 'gray'}}>{product.sellers[0]?.name || "Unknown Shop"}</Card.Title>
                      <Card.Subtitle align="left">{product.name}</Card.Subtitle>
                      <Card.Text align="left"style={{color: 'red', fontSize: '1.1em'}}>
                        ฿{product.price.toLocaleString()}.00
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

export default NewProduct;
