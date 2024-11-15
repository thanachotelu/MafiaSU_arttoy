import React, { useState } from 'react';
import { Container, Row, Col, Form, Button, Card, ListGroup } from 'react-bootstrap';
import TopMenu from '../components/TopMenu'; // ส่วนแสดงเมนูด้านบน
import Footer from '../components/Footer'; // ส่วนแสดง Footer
import { useCart } from '../context/CartContext';
import axios from 'axios';

const Checkout = () => {
const { cartItems, removeFromCart, updateItemQuantity, removeAllItems  } = useCart();
const [formData, setFormData] = useState({
    fullName: '',
    address: '',
    district: '',
    subDistrict: '',
    province: '',
    postcode: '',
});

const [totalPrice, setTotalPrice] = useState(
    cartItems.reduce((acc, item) => acc + item.price * item.quantity, 0)
);

// ฟังก์ชันสำหรับการเปลี่ยนแปลงข้อมูลในฟอร์ม
const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
};

// ฟังก์ชันสำหรับยืนยันคำสั่งซื้อ
const handleConfirmOrder = async () => {
    // ตรวจสอบว่ามีสินค้าที่จะสั่งซื้อหรือไม่
    if (cartItems.length === 0) {
      alert('Your cart is empty');
      return;
    }

    // จัดเตรียมข้อมูลที่จะส่งไปยัง backend
    const orderItems = cartItems.map((item) => ({
      product_id: item.product_id,
      quantity: item.quantity,
    }));

    try {
      // ส่งข้อมูลรายการสินค้าไปยัง backend
      const response = await axios.put('/api/v1/products/orders', { items: orderItems });
      alert('สั่งซื้อสินค้าสำเร็จ!');
      console.log('Order response:', response.data);

      // ล้างข้อมูลใน cart หลังจากสั่งซื้อสำเร็จ
      removeAllItems();
    } catch (error) {
      console.error('Error placing order:', error);
      alert('ผิดพลาดในการสั่งซื้อ');
    }
  };

  // ฟังก์ชันสำหรับอัพเดตจำนวนสินค้าในตะกร้า
  const handleQuantityChange = (product_id, newQuantity) => {
    if (newQuantity < 1) {
      removeFromCart(product_id);
    } else {
      updateItemQuantity(product_id, newQuantity);
    }
    const newTotal = cartItems.reduce(
      (acc, item) => acc + item.price * (item.product_id === product_id ? newQuantity : item.quantity),
      0
    );
    setTotalPrice(newTotal);
  };

  return (
    <div>
    <TopMenu />
    <Container className="my-5">
      <h2 className="text-center mb-4" style={{ fontWeight: 'bold' }}>ทำการสั่งซื้อ</h2>
      <Row>
        {/* ฟอร์มกรอกข้อมูลการจัดส่ง */}
        <Col md={6}>
          <h4>ข้อมูลการจัดส่ง</h4>
          <Form>
            <Form.Group controlId="fullName" className="mb-3">
              <Form.Label className="text-start" style={{ display: 'block' }}>ชื่อ-นามสกุล</Form.Label>
              <Form.Control
                type="text"
                name="fullName"
                placeholder="กรอกชื่อ-นามสกุล"
                value={formData.fullName}
                onChange={handleChange}
              />
            </Form.Group>

            <Form.Group controlId="address" className="mb-3">
              <Form.Label className="text-start" style={{ display: 'block' }}>ที่อยู่</Form.Label>
              <Form.Control
                type="text"
                name="address"
                placeholder="กรอกที่อยู่"
                value={formData.address}
                onChange={handleChange}
              />
            </Form.Group>

            <Form.Group controlId="district" className="mb-3">
              <Form.Label className="text-start" style={{ display: 'block' }}>ตำบล</Form.Label>
              <Form.Control
                type="text"
                name="district"
                placeholder="กรอกตำบล"
                value={formData.district}
                onChange={handleChange}
              />
            </Form.Group>

            <Form.Group controlId="subDistrict" className="mb-3">
              <Form.Label className="text-start" style={{ display: 'block' }}>อำเภอ</Form.Label>
              <Form.Control
                type="text"
                name="subDistrict"
                placeholder="กรอกอำเภอ"
                value={formData.subDistrict}
                onChange={handleChange}
              />
            </Form.Group>

            <Form.Group controlId="province" className="mb-3">
              <Form.Label className="text-start" style={{ display: 'block' }}>จังหวัด</Form.Label>
              <Form.Control
                type="text"
                name="province"
                placeholder="กรอกจังหวัด"
                value={formData.province}
                onChange={handleChange}
              />
            </Form.Group>

            <Form.Group controlId="postcode" className="mb-3">
              <Form.Label className="text-start" style={{ display: 'block' }}>รหัสไปรษณีย์</Form.Label>
              <Form.Control
                type="text"
                name="postcode"
                placeholder="กรอกรหัสไปรษณีย์"
                value={formData.postcode}
                onChange={handleChange}
              />
            </Form.Group>
          </Form>
        </Col>

        {/* สรุปรายการสินค้า */}
        <Col md={6}>
          <h4>สรุปรายการสินค้า</h4>
          <Card>
            <Card.Body>
                <ListGroup variant="flush" style={{ maxHeight: '400px', overflowY: 'auto' }}>
                {cartItems.map((item) => (
                    <ListGroup.Item key={item.product_id}>
                    <Row>
                        <Col xs={4}>
                        <img
                            src={item.images ? item.images[0]?.image_url : 'https://via.placeholder.com/100'}
                            alt={item.name}
                            style={{ width: '100%', height: 'auto', borderRadius: '8px' }}
                            onError={(e) => { e.target.src = 'https://via.placeholder.com/100'; }}
                        />
                        </Col>
                        <Col xs={8}>
                        <h5>{item.name}</h5>
                        <p>จำนวน: {item.quantity}</p>
                        <p style={{ color: 'red' }}>
                            ฿{(item.price * item.quantity).toLocaleString()}
                        </p>
                        </Col>
                    </Row>
                    </ListGroup.Item>
                ))}
                {cartItems.length > 2 && (
                    <ListGroup.Item>
                    <Row>
                        <Col className="text-center">
                        <small>มีสินค้าทั้งหมด {cartItems.length} รายการ</small>
                        </Col>
                    </Row>
                    </ListGroup.Item>
                )}
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
    <Footer />
    </div>
  );
};

export default Checkout;
