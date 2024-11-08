// src/components/Footer.jsx
import React from 'react';
import { Container, Row, Col } from 'react-bootstrap';

const Footer = () => {
  return (
    <footer className="bg-dark text-white py-4">
      <Container>
        <Row>
          <Col md={4}>
            <h5>MAFIA TOYS</h5>
            <p>is your go-to destination for unique art toys, crafted for collectors and art lovers alike. Discover a curated selection of designer toys that blend art with creativity, offering one-of-a-kind pieces to express your style and passion.</p>
          </Col>
          <Col md={2}>
            <h5>About Us</h5>
            <ul className="list-unstyled">
              <li>Careers</li>
              <li>Our Stores</li>
              <li>Terms & Conditions</li>
              <li>Privacy Policy</li>
            </ul>
          </Col>
          <Col md={2}>
            <h5>Customer Care</h5>
            <ul className="list-unstyled">
              <li>Help Center</li>
              <li>How to Buy</li>
              <li>Track Your Order</li>
              <li>Returns & Refunds</li>
            </ul>
          </Col>
          <Col md={4}>
            <h5>Contact Us</h5>
            <p>
              6 Ratchamarga in Phra Pathom Chedi Subdistrict, Mueang Nakhon Pathom District, Nakhon Pathom 73000 <br/>
              Email: <a href="mailto:SU-CENTRAL@SU.AC.TH" className="text-white">SU-CENTRAL@SU.AC.TH</a> <br/>
              Phone: +1 1123 456 780
            </p>
          </Col>
        </Row>
      </Container>
    </footer>
  );
};

export default Footer;
