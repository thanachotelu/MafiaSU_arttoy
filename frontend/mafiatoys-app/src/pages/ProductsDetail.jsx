import React, { useState } from 'react';
import { useParams } from 'react-router-dom';
import TopMenu from '../components/TopMenu';
import Footer from '../components/Footer';

const ProductDetail = () => {
    const { productId } = useParams();

    const product = {
        id: productId,
        name: `CRYBABY × Powerpuff Girls Series Figures`,
        price: '฿380.00',
        imageUrl: 'https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
        description: 'Series of collectible figures from Powerpuff Girls collaboration with CRYBABY.',
        shop: 'Pop Mart Store',
        imageGallery: [
            'https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
            'https://prod-eurasian-res.popmart.com/default/20240307_135857_061608__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
            'https://prod-eurasian-res.popmart.com/default/20240307_135900_754875__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
            'https://prod-eurasian-res.popmart.com/default/20240307_135904_928134__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
            'https://prod-eurasian-res.popmart.com/default/20240307_135907_345467__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp'
        ]
    };

    const [mainImage, setMainImage] = useState(product.imageUrl);
    const [isFiguresOpen, setIsFiguresOpen] = useState(false);
    const [isShippingOpen, setIsShippingOpen] = useState(false);
    const [selectedSize, setSelectedSize] = useState('กล่องเดียว'); // Initial selected size
    const [quantity, setQuantity] = useState(1); // Initial quantity

    // Function to handle size selection
    const handleSizeSelect = (size) => {
        setSelectedSize(size);
    };

    // Function to handle quantity change
    const handleQuantityChange = (operation) => {
        setQuantity((prevQuantity) => {
            if (operation === 'decrease' && prevQuantity > 1) {
                return prevQuantity - 1;
            }
            if (operation === 'increase') {
                return prevQuantity + 1;
            }
            return prevQuantity;
        });
    };

    return (
        <div>
            <TopMenu />
            <div
                className="product-detail-container"
                style={{
                    display: 'flex',
                    padding: '20px',
                    justifyContent: 'center',
                    alignItems: 'flex-start',
                    margin: 'auto',
                    maxWidth: '900px'
                }}
            >
                {/* Image Gallery */}
                <div className="image-gallery" style={{ display: 'flex', flexDirection: 'column', marginRight: '20px' }}>
                    {product.imageGallery.map((img, index) => (
                        <img
                            key={index}
                            src={img}
                            alt={`${product.name} - Gallery ${index + 1}`}
                            style={{ width: '60px', height: '60px', marginBottom: '10px', cursor: 'pointer', border: '1px solid #ccc' }}
                            onClick={() => setMainImage(img)}
                        />
                    ))}
                </div>

                {/* Main Image */}
                <div style={{ marginRight: '20px' }}>
                    <img
                        src={mainImage}
                        alt={product.name}
                        style={{ width: '300px', height: 'auto', marginBottom: '20px' }}
                    />
                </div>

                {/* Product Info */}
                <div className="product-info" style={{ flex: 1, maxWidth: '300px', color: '#333' }}>
                    <h1 style={{ fontSize: '1.5em', marginBottom: '10px', fontWeight: 'bold' }}>{product.name}</h1>
                    <p style={{ color: 'red', fontWeight: 'bold', fontSize: '1.5em', marginBottom: '10px' }}>{product.price}</p>

                    {/* ขนาด Section */}
                    <div style={{ marginBottom: '20px' }}>
                        <span style={{ display: 'block', fontWeight: 'bold', marginBottom: '5px' }}>ขนาด</span>

                        <button
                            style={{
                                padding: 'calc(.875rem - 1px) calc(1.5rem - 1px)',
                                border: '1px solid rgba(0, 0, 0, 0.1)',
                                borderRadius: '.25rem',
                                backgroundColor: selectedSize === 'กล่องเดียว' ? '#e0e0e0' : '#f8f8f8', // Set background color based on selectedSize
                                boxShadow: 'rgba(0, 0, 0, 0.02) 0 1px 3px 0',
                                color: 'rgba(0, 0, 0, 0.85)',
                                cursor: 'pointer',
                                display: 'inline-flex',
                                fontFamily: 'system-ui, -apple-system, system-ui, "Helvetica Neue", Helvetica, Arial, sans-serif',
                                fontSize: '16px',
                                fontWeight: '600',
                                justifyContent: 'center',
                                lineHeight: '1.25',
                                minHeight: '3rem',
                                textDecoration: 'none',
                                transition: 'all 250ms',
                                userSelect: 'none',
                                verticalAlign: 'baseline',
                                marginRight: '10px',
                            }}
                            onClick={() => handleSizeSelect('กล่องเดียว')}
                        >
                            กล่องเดียว
                        </button>

                        <button
                            style={{
                                padding: 'calc(.875rem - 1px) calc(1.5rem - 1px)',
                                border: '1px solid rgba(0, 0, 0, 0.1)',
                                borderRadius: '.25rem',
                                backgroundColor: selectedSize === 'ทั้งชุด' ? '#e0e0e0' : '#f8f8f8', // Set background color based on selectedSize
                                boxShadow: 'rgba(0, 0, 0, 0.02) 0 1px 3px 0',
                                color: 'rgba(0, 0, 0, 0.85)',
                                cursor: 'pointer',
                                display: 'inline-flex',
                                fontFamily: 'system-ui, -apple-system, system-ui, "Helvetica Neue", Helvetica, Arial, sans-serif',
                                fontSize: '16px',
                                fontWeight: '600',
                                justifyContent: 'center',
                                lineHeight: '1.25',
                                minHeight: '3rem',
                                textDecoration: 'none',
                                transition: 'all 250ms',
                                userSelect: 'none',
                                verticalAlign: 'baseline',
                            }}
                            onClick={() => handleSizeSelect('ทั้งชุด')}
                        >
                            ทั้งชุด
                        </button>
                    </div>

                    {/* จำนวน Section */}
                    <div style={{ display: 'flex', alignItems: 'center', marginBottom: '20px' }}>
                        <span style={{ fontWeight: 'bold', marginRight: '10px' }}>จำนวน:</span>
                        <button
                            style={{ padding: '8px', height: '40px', border: '1px solid #ccc', cursor: 'pointer' }}
                            onClick={() => handleQuantityChange('decrease')}
                        >
                            -
                        </button>
                        <input
                            type="text"
                            value={quantity}
                            readOnly
                            style={{ width: '50px', height: '40px', textAlign: 'center', margin: '0 5px', border: '1px solid #ccc' }}
                        />
                        <button
                            style={{ padding: '5px', height: '40px', border: '1px solid #ccc', cursor: 'pointer' }}
                            onClick={() => handleQuantityChange('increase')}
                        >
                            +
                        </button>
                    </div>

                    {/* ปุ่มเพิ่มไปยังตะกร้า และ ซื้อเลย */}
                    <button style={{
                        padding: '10px 20px',
                        backgroundColor: 'black',
                        color: 'white',
                        border: 'none',
                        marginRight: '10px',
                        cursor: 'pointer',
                        fontWeight: 'bold',
                        fontSize: '1em'
                    }}>เพิ่มไปยังตะกร้า</button>
                    <button style={{
                        padding: '10px 20px',
                        backgroundColor: 'red',
                        color: 'white',
                        border: 'none',
                        cursor: 'pointer',
                        fontWeight: 'bold',
                        fontSize: '1em'
                    }}>ซื้อเลย</button>
                </div>
            </div>

            {/* Accordion Sections */}
            <div style={{ maxWidth: '900px', margin: 'auto', padding: '20px' }}>
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
                    ฟิกเกอร์ทั้งหมด
                    <span>{isFiguresOpen ? '▲' : '▼'}</span>
                </div>
                {isFiguresOpen && (
                    <div style={{ padding: '10px 0', color: '#666' }}>
                        <p>{product.description}</p>
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
                        fontWeight: 'bold'
                    }}
                >
                    การจัดส่งและบริการหลังการขาย
                    <span>{isShippingOpen ? '▲' : '▼'}</span>
                </div>
                {isShippingOpen && (
                    <div style={{ padding: '10px 0', color: '#666' }}>
                        ข้อมูลการจัดส่งและบริการหลังการขาย...
                    </div>
                )}
            </div>

            <Footer />
        </div>
    );
};

export default ProductDetail;
