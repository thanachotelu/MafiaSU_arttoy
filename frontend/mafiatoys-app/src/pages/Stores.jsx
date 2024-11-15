import React from 'react';
import { Card, Container, Row, Col } from 'react-bootstrap';
import { Link } from 'react-router-dom';  // Import Link from react-router-dom

import TopMenu from '../components/TopMenu'; // ส่วนแสดงเมนูด้านบน
import Footer from '../components/Footer'; // ส่วนแสดง Footer
import '../index.css';  // นำเข้าไฟล์ CSS ที่เราสร้างขึ้น

const Store = () => {
    return (
        <div>
            <TopMenu />
            <Container className="mt-4">
                <h2>Our Stores</h2>
                <p></p>
                <Row>
                    {/* Hard-coded store cards */}
                    <Col sm={12} md={6} lg={4} className="mb-4">
                        <Card className="shadow-lg border-0 rounded" style={{ transition: "transform 0.3s ease-in-out" }}>
                            <Card.Img 
                                variant="top" 
                                src="/assets/images/logo_images_popmart.png" 
                                style={{ 
                                    height: '200px',
                                    objectFit: 'contain',
                                    borderRadius: '10px',
                                    width: '100%' 
                                }} 
                            />
                            <Card.Body>
                                <Card.Title className="text-center" style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>POPMART</Card.Title>
                                <Card.Text className="text-center mb-3" style={{ fontSize: '1rem', color: '#6c757d' }}>
                                    Popmart
                                </Card.Text>
                                {/* Wrap the button with Link to navigate to the store's page */}
                                <Link to="/stores/popmart" className="button-19">
                                    Visit the store
                                </Link>
                            </Card.Body>
                        </Card>
                    </Col>

                    <Col sm={12} md={6} lg={4} className="mb-4">
                        <Card className="shadow-lg border-0 rounded" style={{ transition: "transform 0.3s ease-in-out" }}>
                            <Card.Img 
                                variant="top" 
                                src="/assets/images/logo_images_gachabox.png" 
                                style={{ 
                                    height: '200px',
                                    objectFit: 'contain',
                                    borderRadius: '10px',
                                    width: '100%' 
                                }} 
                            />
                            <Card.Body>
                                <Card.Title className="text-center" style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>GACHABOX</Card.Title>
                                <Card.Text className="text-center mb-3" style={{ fontSize: '1rem', color: '#6c757d' }}>
                                    Gachabox
                                </Card.Text>
                                <Link to="/stores/gachabox" className="button-19">
                                    Visit the store
                                </Link>
                            </Card.Body>
                        </Card>
                    </Col>

                    <Col sm={12} md={6} lg={4} className="mb-4">
                        <Card className="shadow-lg border-0 rounded" style={{ transition: "transform 0.3s ease-in-out" }}>
                            <Card.Img 
                                variant="top" 
                                src="/assets/images/logo_images_Atongshopp.png" 
                                style={{ 
                                    height: '200px',
                                    objectFit: 'contain',
                                    borderRadius: '10px',
                                    width: '100%' 
                                }} 
                            />
                            <Card.Body>
                                <Card.Title className="text-center" style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>Atongshopp</Card.Title>
                                <Card.Text className="text-center mb-3" style={{ fontSize: '1rem', color: '#6c757d' }}>
                                    Atongshopp
                                </Card.Text>
                                <Link to="/stores/atongshopp" className="button-19">
                                    Visit the store
                                </Link>
                            </Card.Body>
                        </Card>
                    </Col>

                    <Col sm={12} md={6} lg={4} className="mb-4">
                        <Card className="shadow-lg border-0 rounded" style={{ transition: "transform 0.3s ease-in-out" }}>
                            <Card.Img 
                                variant="top" 
                                src="/assets/images/logo_images_arttoys.png" 
                                style={{ 
                                    height: '200px',
                                    objectFit: 'contain',
                                    borderRadius: '10px',
                                    width: '100%' 
                                }} 
                            />
                            <Card.Body>
                                <Card.Title className="text-center" style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>ART TOYS</Card.Title>
                                <Card.Text className="text-center mb-3" style={{ fontSize: '1rem', color: '#6c757d' }}>
                                    Art toys
                                </Card.Text>
                                <Link to="/stores/arttoys" className="button-19">
                                    Visit the store
                                </Link>
                            </Card.Body>
                        </Card>
                    </Col>

                    <Col sm={12} md={6} lg={4} className="mb-4">
                        <Card className="shadow-lg border-0 rounded" style={{ transition: "transform 0.3s ease-in-out" }}>
                            <Card.Img 
                                variant="top" 
                                src="/assets/images/logo_images_pieceofjoy.png" 
                                style={{ 
                                    height: '200px',
                                    objectFit: 'contain',
                                    borderRadius: '10px',
                                    width: '100%' 
                                }} 
                            />
                            <Card.Body>
                                <Card.Title className="text-center" style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>PIECE Of JOY</Card.Title>
                                <Card.Text className="text-center mb-3" style={{ fontSize: '1rem', color: '#6c757d' }}>
                                    Piece of joy
                                </Card.Text>
                                <Link to="/stores/pieceofjoy" className="button-19">
                                    Visit the store
                                </Link>
                            </Card.Body>
                        </Card>
                    </Col>
                </Row>
            </Container>
            <Footer />
        </div>
    );
};

export default Store;