import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Form, Button, Card, ListGroup } from 'react-bootstrap';
import axios from 'axios';

const Checkout = () => {
  // สถานะสำหรับข้อมูลฟอร์ม
  const [formData, setFormData] = useState({
    fullName: '',
    address: '',
    district: '',
    subDistrict: '',
    province: '',
  });

  // สถานะสำหรับรายการสินค้า
  const [cartItems, setCartItems] = useState([]);
  const [totalPrice, setTotalPrice] = useState(0);

  // ดึงข้อมูลรายการสินค้า (สมมติว่ามี API ที่ดึงรายการสินค้าในตะกร้า)
  useEffect(() => {
    axios
      .get('/api/v1/cart') // แก้ URL ให้ตรงกับ API ของคุณ
      .then((response) => {
        setCartItems(response.data.items);
        const total = response.data.items.reduce((acc, item) => acc + item.price * item.quantity, 0);
        setTotalPrice(total);
      })
      .catch((error) => {
        console.error('Error fetching cart items:', error);
      });
  }, []);

  // ฟังก์ชันจัดการการเปลี่ยนแปลงข้อมูลในฟอร์ม
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  // ฟังก์ชันสำหรับการยืนยันคำสั่งซื้อ
  const handleConfirmOrder = () => {
    const orderData = {
      ...formData,
      items: cartItems,
      totalPrice,
    };

    // ส่งข้อมูลไปยัง backend
    axios
      .post('/api/v1/orders', orderData) // แก้ URL ให้ตรงกับ API ของคุณ
      .then((response) => {
        alert('Order placed successfully!');
      })
      .catch((error) => {
        console.error('Error placing order:', error);
        alert('Failed to place order');
      });
  };

  return (
    <Container className="my-5">
      <h2 className="text-center mb-4" style={{ fontWeight: 'bold' }}>Checkout</h2>
      
      {/* ส่วนกรอกข้อมูลที่อยู่ */}
      <Row>
        <Col md={6}>
          <h4>ข้อมูลการจัดส่ง</h4>
          <Form>
            <Form.Group controlId="fullName" className="mb-3">
              <Form.Label>ชื่อ-นามสกุล</Form.Label>
              <Form.Control
                type="text"
                name="fullName"
                placeholder="กรอกชื่อ-นามสกุล"
                value={formData.fullName}
                onChange={handleChange}
              />
            </Form.Group>

            <Form.Group controlId="address" className="mb-3">
              <Form.Label>ที่อยู่</Form.Label>
              <Form.Control
                type="text"
                name="address"
                placeholder="กรอกที่อยู่"
                value={formData.address}
                onChange={handleChange}
              />
            </Form.Group>

            <Form.Group controlId="district" className="mb-3">
              <Form.Label>ตำบล</Form.Label>
              <Form.Control
                type="text"
                name="district"
                placeholder="กรอกตำบล"
                value={formData.district}
                onChange={handleChange}
              />
            </Form.Group>

            <Form.Group controlId="subDistrict" className="mb-3">
              <Form.Label>อำเภอ</Form.Label>
              <Form.Control
                type="text"
                name="subDistrict"
                placeholder="กรอกอำเภอ"
                value={formData.subDistrict}
                onChange={handleChange}
              />
            </Form.Group>

            <Form.Group controlId="province" className="mb-3">
              <Form.Label>จังหวัด</Form.Label>
              <Form.Control
                type="text"
                name="province"
                placeholder="กรอกจังหวัด"
                value={formData.province}
                onChange={handleChange}
              />
            </Form.Group>
          </Form>
        </Col>

        {/* ส่วนสรุปรายการสินค้า */}
        <Col md={6}>
          <h4>สรุปรายการสินค้า</h4>
          <Card>
            <Card.Body>
              <ListGroup variant="flush">
                {cartItems.map((item) => (
                  <ListGroup.Item key={item.product_id}>
                    <Row>
                      <Col>{item.name}</Col>
                      <Col>จำนวน: {item.quantity}</Col>
                      <Col>฿{(item.price * item.quantity).toLocaleString()}.00</Col>
                    </Row>
                  </ListGroup.Item>
                ))}
              </ListGroup>
              <hr />
              <h5>ยอดรวม: ฿{totalPrice.toLocaleString()}.00</h5>
            </Card.Body>
          </Card>
        </Col>
      </Row>

      {/* ปุ่มยืนยันการสั่งซื้อ */}
      <div className="text-center mt-4">
        <Button variant="success" onClick={handleConfirmOrder}>
          ยืนยันสั่งซื้อ
        </Button>
      </div>
    </Container>
  );
};

export default Checkout;
