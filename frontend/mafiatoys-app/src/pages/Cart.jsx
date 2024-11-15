// Cart.js
import React from 'react';
import { useCart } from '../context/CartContext';
import TopMenu from '../components/TopMenu';
import Footer from '../components/Footer';
import { useNavigate } from 'react-router-dom';

const Cart = () => {
    const { cartItems, updateItemQuantity, removeFromCart } = useCart();
    const navigate = useNavigate();

    const calculateSubtotal = () => {
        return cartItems.reduce((total, item) => total + item.price * item.quantity, 0);
    };

    const handleCheckout = () => {
        navigate('/checkout');
    };

    const styles = {
        cartContainer: { display: 'flex', justifyContent: 'center', padding: '20px', minHeight: 'calc(100vh - 80px)' },
        contentContainer: { display: 'flex', maxWidth: '2000px', width: '100%' },
        cartContent: { flex: 3, paddingRight: '20px' },
        orderSummary: { flex: 1, border: '1px solid #ccc', padding: '20px', borderRadius: '5px', backgroundColor: '#f9f9f9', alignSelf: 'flex-start' },
        cartItem: { display: 'flex', alignItems: 'center', borderBottom: '1px solid #ccc', padding: '10px 0' },
        itemImage: { width: '150px', height: '150px', marginRight: '20px', borderRadius: '8px' },
        itemDetails: { flex: 1, marginLeft: '10px' },
        price: { discounted: { color: 'red', fontWeight: 'bold', fontSize: '18px' } },
        itemTotalPrice: { fontWeight: 'bold', fontSize: '18px' },
        quantityContainer: { display: 'flex', alignItems: 'center' },
        quantityButton: { width: '30px', height: '30px', border: '1px solid #ccc', backgroundColor: 'white', cursor: 'pointer', fontSize: '18px', textAlign: 'center', lineHeight: '30px' },
        quantityInput: { width: '40px', textAlign: 'center', border: '1px solid #ccc', borderLeft: 'none', borderRight: 'none', fontSize: '16px' },
        deleteBtn: { backgroundColor: 'transparent', border: 'none', cursor: 'pointer', color: 'red', fontSize: '18px' },
        summaryRow: { display: 'flex', justifyContent: 'space-between', marginBottom: '10px' },
        summaryTotal: { display: 'flex', justifyContent: 'space-between', fontWeight: 'bold', fontSize: '18px', marginTop: '10px' },
        checkoutBtn: { width: '100%', padding: '10px', backgroundColor: 'green', color: 'white', border: 'none', borderRadius: '5px', cursor: 'pointer', fontSize: '18px' },
        footer: { position: 'fixed', bottom: 0, left: 0, width: '100%' }
    };

    return (
        <div>
            <TopMenu cartItemCount={cartItems.length}/>
            <div style={styles.cartContainer}>
                <div style={styles.contentContainer}>
                    <div style={styles.cartContent}>
                        <h2>My Cart</h2>
                        {cartItems.map((item) => (
                            <div key={item.product_id} style={styles.cartItem}>
                                <img
                                    src={item.images ? item.images[0]?.image_url : 'https://via.placeholder.com/150'}
                                    alt={item.name}
                                    style={styles.itemImage}
                                    onError={(e) => { e.target.src = 'https://via.placeholder.com/150'; }}
                                />
                                <div style={styles.itemDetails}>
                                    <h4>{item.name}</h4>
                                    <p style={styles.price.discounted}>฿{item.price.toFixed(2)}</p>
                                    <div style={styles.quantityContainer}>
                                        <span style={{ marginRight: '10px' }}>จำนวน</span>
                                        <button
                                            style={styles.quantityButton}
                                            onClick={() => updateItemQuantity(item.product_id, item.quantity - 1)}
                                            disabled={item.quantity === 1}
                                        >
                                            -
                                        </button>
                                        <input
                                            type="text"
                                            value={item.quantity}
                                            readOnly
                                            style={styles.quantityInput}
                                        />
                                        <button
                                            style={styles.quantityButton}
                                            onClick={() => updateItemQuantity(item.product_id, item.quantity + 1)}
                                        >
                                            +
                                        </button>
                                    </div>
                                </div>
                                <div style={{ display: 'flex', alignItems: 'center' }}>
                                    <div style={styles.itemTotalPrice}>
                                        ฿{(item.price * item.quantity).toLocaleString('th-TH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                                    </div>
                                    <button style={styles.deleteBtn} onClick={() => removeFromCart(item.product_id)}>🗑️</button>
                                </div>
                            </div>
                        ))}
                    </div>

                    <div style={styles.orderSummary}>
                        <h3>Order Summary</h3>
                        <div style={styles.summaryRow}>
                            <span>Subtotal</span>
                            <span>฿{calculateSubtotal().toLocaleString('th-TH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</span>
                        </div>
                        <div style={styles.summaryRow}>
                            <span>Delivery</span>
                            <span>FREE</span>
                        </div>
                        <div style={styles.summaryTotal}>
                            <h4>Total</h4>
                            <h4>฿{calculateSubtotal().toLocaleString('th-TH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</h4>
                        </div>
                        <button style={styles.checkoutBtn} onClick={handleCheckout}>Checkout</button>
                    </div>
                </div>
            </div>
            <Footer style={styles.footer} />
        </div>
    );
};

export default Cart;
