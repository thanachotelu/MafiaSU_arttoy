import React from 'react';
import { Card, Container, Row, Col } from 'react-bootstrap';

import TopMenu from '../components/TopMenu'; // ส่วนแสดงเมนูด้านบน
import Footer from '../components/Footer'; // ส่วนแสดง Footer
import '../index.css';  // นำเข้าไฟล์ CSS ที่เราสร้างขึ้น

const stores = [
    { id: 1, name: "POPMART", description: "รายละเอียดร้านค้า 1", image: "/assets/images/logo_images_popmart.png" },
    { id: 2, name: "GACHABOX", description: "รายละเอียดร้านค้า 2", image: "/assets/images/logo_images_gachabox.png" },
    { id: 3, name: "Atongshopp", description: "รายละเอียดร้านค้า 3", image: "/assets/images/logo_images_Atongshopp.png" },
    { id: 4, name: "ART TOYS", description: "รายละเอียดร้านค้า 4", image: "/assets/images/logo_images_arttoys.png" },
    { id: 5, name: "PIECE Of JOY", description: "รายละเอียดร้านค้า 5", image: "/assets/images/logo_images_pieceofjoy.png" },
];

const Store = () => {
    return (
        <div>
            <TopMenu />
            <Container className="mt-4">
                <h2>Our Stores</h2>
                <p></p>
                <Row>
                    {stores.map(store => (
                        <Col key={store.id} sm={12} md={6} lg={4} className="mb-4">
                            <Card className="shadow-lg border-0 rounded" style={{ transition: "transform 0.3s ease-in-out" }}>
                                <Card.Img 
                                    variant="top" 
                                    src={store.image} 
                                    style={{ 
                                        height: '200px',  // ปรับความสูงของรูป
                                        objectFit: 'contain', // ทำให้รูปไม่เบียดกัน
                                        borderRadius: '10px', // ปรับขอบมนให้รูปดูสวยงาม
                                        width: '100%' // ทำให้รูปมีความกว้าง 100% ของการ์ด
                                    }} 
                                />
                                <Card.Body>
                                    
                                    <Card.Title className="text-center" style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>{store.name}</Card.Title>
                                    <Card.Text className="text-center mb-3" style={{ fontSize: '1rem', color: '#6c757d' }}>
                                        {store.description}
                                    </Card.Text>
                                    <button className="button-19">Visit the store</button>
                                </Card.Body>
                            </Card>
                        </Col>
                    ))}
                </Row>
            </Container>
            <Footer />
        </div>
    );
};

export default Store;
