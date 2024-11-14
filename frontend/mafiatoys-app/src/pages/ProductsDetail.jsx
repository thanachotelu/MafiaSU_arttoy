import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useParams } from 'react-router-dom';
import { Container } from 'react-bootstrap';
import TopMenu from '../components/TopMenu';
import Footer from '../components/Footer';
import { useNavigate } from 'react-router-dom';

import Button from 'react-bootstrap/Button';
import ButtonGroup from 'react-bootstrap/ButtonGroup';
import InputGroup from 'react-bootstrap/InputGroup';
import "../index.css";


const ProductDetail = ({ addToCart }) => {
    const { productId } = useParams();
    const [product, setProduct] = useState(null);
    const [mainImage, setMainImage] = useState('');
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);
    const [quantity, setQuantity] = useState(1);
    const [isFiguresOpen, setIsFiguresOpen] = useState(false);
    const [isShippingOpen, setIsShippingOpen] = useState(false);

    const [isCartPanelOpen, setIsCartPanelOpen] = useState(false); //Side panel

    const handleQuantityChange = (action) => {
        if (action === 'increase') {
            setQuantity(prev => prev + 1);
        } else if (action === 'decrease' && quantity > 1) {
            setQuantity(prev => prev - 1);
        }
    };

    const toggleCartPanel = () => {
        setIsCartPanelOpen(!isCartPanelOpen);
    };

    const navigate = useNavigate();
    useEffect(() => {
        const fetchProductDetails = async () => {
            try {
                setIsLoading(true);
                const response = await axios.get(`/api/v1/products/${productId}`);
                const productData = response.data;

                if (!productData) {
                    throw new Error('ไม่พบข้อมูลสินค้า');
                }

                setProduct(productData);
                // ตั้งค่ารูปภาพหลักจาก is_primary หรือรูปแรก
                const primaryImage = productData.images.find(img => img.is_primary)?.image_url
                    || productData.images[0]?.image_url;
                setMainImage(primaryImage);

            } catch (error) {
                console.error('Error fetching product details:', error);
                setError('ไม่สามารถโหลดข้อมูลสินค้าได้ กรุณาลองใหม่อีกครั้ง');
            } finally {
                setIsLoading(false);
            }
        };

        fetchProductDetails();
    }, [productId]);

    if (isLoading) {
        return (
            <div style={{ textAlign: 'center', padding: '2rem' }}>
                <p>กำลังโหลดข้อมูล...</p>
            </div>
        );
    }

    if (error) {
        return (
            <div style={{ textAlign: 'center', padding: '2rem', color: 'red' }}>
                <p>{error}</p>
                <button onClick={() => window.location.reload()}>ลองใหม่อีกครั้ง</button>
            </div>
        );
    }

    if (!product) {
        return (
            <div style={{ textAlign: 'center', padding: '2rem' }}>
                <p>ไม่พบข้อมูลสินค้า</p>
            </div>
        );
    }

    const totalPrice = quantity * product.price;

    const handleAddToCart = () => {
        
        addToCart({
            id: product.id,
            name: product.name,
            price: product.price,
            quantity, // ส่งค่าจำนวนที่ผู้ใช้เลือก
            imageUrl: mainImage
        });
        // นำทางไปยังหน้า CartDetail หรือแค่แจ้งเตือนว่าถูกเพิ่มสำเร็จ
        navigate('/CartDetail'); // หรือใช้ navigate('/allproducts') เพื่อกลับไปยัง AllProduct
        
    };

    return (
        <div>
            <TopMenu />
            <Container className="product-detail-container" style={{
                display: 'flex',
                padding: '20px',
                justifyContent: 'center',
                alignItems: 'flex-start',
                margin: 'auto',
                maxWidth: '3000px'
            }}>
                {/* Image Gallery */}
                <div className="image-gallery" style={{
                    display: 'flex',
                    flexDirection: 'column',
                    marginRight: '20px'
                }}>
                    {product.images.map((img) => (
                        <img
                            key={img.id}
                            src={img.image_url}
                            alt={product.name}
                            style={{
                                width: '80px',
                                height: '80px',
                                marginBottom: '10px',
                                cursor: 'pointer',
                                border: mainImage === img.image_url ? '2px solid #007bff' : '1px solid #ccc',
                                objectFit: 'cover'
                            }}
                            onClick={() => setMainImage(img.image_url)}
                        />
                    ))}
                </div>

                {/* Main Image */}
                <div style={{ marginRight: '20px' }}>
                    <img
                        src={mainImage}
                        alt={product.name}
                        style={{
                            width: '500px',
                            height: 'auto',
                            marginBottom: '20px',
                            objectFit: 'contain',
                            transition: 'transform 0.3s ease',
                        }}
                        onMouseEnter={(e) => e.target.style.transform = 'scale(1.05)'}
                        onMouseLeave={(e) => e.target.style.transform = 'scale(1)'}
                    />
                </div>

                {/* Product Info */}
                <div className="product-info" style={{ flex: 1, maxWidth: '500px', color: '#333', textAlign: 'left' }}>
                    {/* "New" Tag */}
                    <span style={{
                        display: 'inline-block',
                        backgroundColor: 'green',
                        color: 'white',
                        padding: '4px 8px',
                        borderRadius: '4px',
                        fontSize: '0.9em',
                        fontWeight: 'bold',
                        marginBottom: '5px'
                    }}>
                        New
                    </span>


                    <h1 style={{ fontSize: '1.5em', marginBottom: '20px', fontWeight: 'bold' }}>
                        {product.name}
                    </h1>

                    <p style={{ color: 'red', fontSize: '1.5em', marginBottom: '10px' }}>
                        ฿{product.price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}

                    </p>

                    <div style={{ display: 'flex', alignItems: 'center', marginBottom: '10px' }}>
                        <span style={{ marginRight: '10px' }}>จำนวน : </span>
                        <ButtonGroup className="me-2" aria-label="First group">
                            <Button variant="secondary" onClick={() => handleQuantityChange('decrease')}>-</Button>
                            <InputGroup>
                                <InputGroup.Text id="btnGroupAddon"> {quantity} </InputGroup.Text>
                            </InputGroup>
                            <Button variant="info" onClick={() => handleQuantityChange('increase')}>+</Button>
                        </ButtonGroup>
                    </div>

                    {/* Add to Cart and Buy Now buttons */}
                    <div style={{ marginTop: '20px' }}>
                        <button style={{
                            width: '200px',
                            height: '60px',
                            padding: '10px 20px',
                            backgroundColor: 'black',
                            color: 'white',
                            border: 'none',
                            marginRight: '20px',
                            cursor: 'pointer',
                            fontSize: '1em',
                        }}
                            onClick={toggleCartPanel}
                        >
                            ADD TO CART
                        </button>
                        <button style={{
                            width: '200px',
                            height: '60px',
                            padding: '10px 20px',
                            backgroundColor: 'red',
                            color: 'white',
                            border: 'none',
                            cursor: 'pointer',
                            fontSize: '1em',
                        }}
                        >
                            BUY NOW
                        </button>
                    </div>

                    <p style={{ marginTop: '20px', color: 'gray' }}><strong>สินค้าคงเหลือ: </strong>{product.inventory.quantity} ชิ้น</p>
                </div>

            </Container>

            {/* Product Details Section */}
            <Container style={{ maxWidth: '75%', margin: 'auto', padding: '20px', textAlign: 'left' }}>
                <div style={{ padding: '20px', backgroundColor: '#f9f9f9', borderRadius: '8px' }}>
                    {/* Figures Section */}
                    <div
                        onClick={() => setIsFiguresOpen(!isFiguresOpen)}
                        style={{
                            padding: '10px 0',
                            borderBottom: '1px solid #ccc',
                            display: 'flex',
                            justifyContent: 'space-between',
                            cursor: 'pointer',
                            fontWeight: 'bold'
                        }}
                    >
                        รายละเอียดสินค้า
                        <span>{isFiguresOpen ? '▲' : '▼'}</span>
                    </div>
                    {isFiguresOpen && (
                        <div style={{ padding: '10px 0', color: '#666' }}>
                            <p>{product.description}</p>

                            {/* Brand Info */}
                            {product.brand && (
                                <p><strong> แบรนด์ : </strong>{product.brand}</p>
                            )}

                            {/* Model Number */}
                            {product.model_number && (
                                <p><strong> รหัสสินค้า: </strong>{product.model_number}</p>
                            )}


                            {/* Categories */}
                            {product.categories && product.categories.length > 0 && (
                                <div style={{ marginTop: '15px' }}>
                                    <strong> หมวดหมู่ : </strong>
                                    {product.categories.map(cat => cat.name).join(', ')}
                                </div>
                            )}
                        </div>
                    )}

                    {/* Shipping and After-Sales Section */}
                    <div
                        onClick={() => setIsShippingOpen(!isShippingOpen)}
                        style={{
                            padding: '10px 0',
                            borderBottom: '1px solid #ccc',
                            display: 'flex',
                            justifyContent: 'space-between',
                            cursor: 'pointer',
                            fontWeight: 'bold',
                        }}
                    >
                        การจัดส่งและบริการหลังการขาย
                        <span>{isShippingOpen ? '▲' : '▼'}</span>
                    </div>
                    {isShippingOpen && (
                        <div style={{ padding: '10px 0', color: '#666' }}>
                            1.การจัดส่ง: <br />
                            (1) FLASH DELIVERY (1-3 วัน) <br />
                            (2) การจัดส่งแบบมาตรฐาน (7-14 วัน) <br />
                            2.ข้อบกพร่อง: <br />
                            (1) สินค้าลิมิเต็ดอิดิชั่นไม่มีบริการแลกเปลียนคืนนี้พบว่าไม่พบข้อบกพร่องที่สำคัญในสินค้าโปรดติดต่อ SU-CENTRAL@SU.AC.TH พร้อมหมายเลขเร่งด่วนที่เกี่ยวข้อง การกล่องแกะภายในห้าวัน (5) วันที่ได้รับสินค้า <br />
                            (2) เพื่อให้ทราบข้อมูลการติดตามด้วยอีเมลดังกล่าวในการสั่งซื้อคุณจะได้รับการติดต่อจากตัวแทนฝั่งจะช่วยในเรื่องนี้<br />
                            (3) เรื่องราวโต้แย้งในเรื่องคืนเงินหรือในกรณีสินค้าส่วนใหญ่ควรถ่ายวิดีโอพัสดุภายในสองวันในส่วนของพัสดุจะต้องต้องปฏิบัติตามใบส่งสินค้าตามปกติของพัสดุและข้อเพื่อตรวจสอบของสินค้าคอนโซล<br />
                            3.ค่าภาษี<br />
                            สำหรับการจัดส่งด่วนในบางครั้งต้องรับผิดชอบค่าใช้จ่ายภาษีภายนอก
                        </div>
                    )}
                </div>

            </Container>

            <Footer />

            {/* Sliding Cart Panel */}
            <div
                className={`cart-panel ${isCartPanelOpen ? 'open' : ''}`}
                style={{
                    position: 'fixed',
                    top: 0,
                    right: isCartPanelOpen ? 0 : '-400px',
                    width: '400px',
                    height: '100%',
                    backgroundColor: '#E4E0E1',
                    boxShadow: '0 0 20px rgba(0, 0, 0, 0.2)',
                    transition: 'right 0.3s ease-in-out',
                    padding: '20px',
                    overflowY: 'auto',
                    display: 'flex',
                    flexDirection: 'column'
                }}
            >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                    <h3><u>สรุปสินค้า</u></h3>
                </div>

                {/* Cart Items */}
                <div>
                    <img
                        src={mainImage}
                        alt={product.name}
                        style={{

                            width: '100px',
                            height: 'auto',
                            marginBottom: '20px',
                            objectFit: 'contain',
                            transition: 'transform 0.3s ease',
                        }}
                    />

                    <h1 style={{ fontSize: '1.5em', marginBottom: '20px', fontWeight: 'bold' }}>
                        {product.name}
                    </h1>

                    <p style={{ color: 'red', fontSize: '1.5em', marginBottom: '10px' }}>
                        ฿{totalPrice.toLocaleString('th-TH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                    </p>

                    <div style={{ display: 'flex', alignItems: 'center', marginBottom: '10px' }}>
                    <span style={{ marginRight: '10px' }}>จำนวน : </span>
                        <ButtonGroup className="me-2" aria-label="First group">
                            <Button variant="secondary" onClick={() => handleQuantityChange('decrease')}>-</Button>
                            <InputGroup>
                                <InputGroup.Text id="btnGroupAddon"> {quantity} </InputGroup.Text>
                            </InputGroup>
                            <Button variant="info" onClick={() => handleQuantityChange('increase')}>+</Button>
                        </ButtonGroup>

                    </div>
                </div>

                <div style={{ marginTop: 'auto' }}>

                    <button class="glow-on-hover1"
                        style={{
                            width: '100%',
                            height: '60px',
                            padding: '10px 20px',
                            backgroundColor: 'red',
                            border: 'none',
                            cursor: 'pointer',
                            fontSize: '1em',
                        }}
                        onClick={handleAddToCart}
                    >
                        ไปที่ตะกร้า
                    </button>

                    <button class="back-btn"
                        style={{
                            padding: '10px 20px',
                            marginTop: '5%',
                            cursor: 'pointer',
                            fontSize: '1em',
                        }}
                        onClick={toggleCartPanel}
                    >
                        กลับไปช็อป
                    </button>

                </div>
            </div>


        </div >
    );
};

export default ProductDetail;
