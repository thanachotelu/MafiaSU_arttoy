import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Card, Container, Row, Col } from 'react-bootstrap';

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
      <h2 className="text-center mb-4" style={{fontWeight: 'bold', color: 'red'}}>สินค้ามาใหม่</h2>
      <Row className="row-cols-1 row-cols-md-3 g-4">
        {products.length > 0 ? (
          products.map((product) => {
            const primaryImage = product.images.find((img) => img.is_primary)?.image_url;

            return (
              <Col key={product.id} className="d-flex">
                <Card className="w-100">
                  <div className="position-relative" style={{ paddingTop: '75%' }}>
                    <Card.Img 
                      variant="top" 
                      src={primaryImage || placeholderImage} 
                      alt={product.name}
                      className="position-absolute top-0 start-0 w-100 h-100 object-fit-cover"
                      onError={(e) => {
                        e.target.onerror = null;
                        e.target.src = placeholderImage;
                      }} 
                    />
                  </div>
                  <Card.Body className="d-flex flex-column">
                    <Card.Title className="h5 mb-2">{product.name}</Card.Title>
                    <Card.Text className="mt-auto">
                      <strong>Price: ฿{product.price}</strong>
                    </Card.Text>
                  </Card.Body>
                </Card>
              </Col>
            );
          })
        ) : (
          <Col>
            <p className="text-center">ไม่พบสินค้าที่ค้นหา</p>
          </Col>
        )}
      </Row>
    </Container>
  );
};

export default NewProducts;