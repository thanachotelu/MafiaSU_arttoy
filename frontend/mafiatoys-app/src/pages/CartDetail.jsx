import React, { useState } from 'react';
import TopMenu from '../components/TopMenu';
import Footer from '../components/Footer';

const CartDetail = ({ cartItems, setCartItems }) => {
    const [purchaseSuccess, setPurchaseSuccess] = useState(false);

    const styles = {
        cartContainer: { display: 'flex', justifyContent: 'space-between', padding: '20px' },
        cartContent: { flex: 2, paddingRight: '20px', marginLeft: '20px' },
        orderSummary: { flex: 1, border: '1px solid #ccc', padding: '20px', maxWidth: '300px' },
        cartItem: { display: 'flex', alignItems: 'center', borderBottom: '1px solid #ccc', padding: '15px 0' },
        itemImage: { width: '250px', marginRight: '30px' },
        itemDetails: { flex: 2 },
        price: { discounted: { color: 'red', fontWeight: 'bold' } },
        itemQuantity: { display: 'flex', alignItems: 'center' },
        quantityBtn: { border: '1px solid #ccc', padding: '5px', margin: '0 5px', cursor: 'pointer' },
        itemTotalPrice: { marginLeft: '20px', fontWeight: 'bold' },
        deleteBtn: { background: 'none', border: 'none', cursor: 'pointer' },
        summaryRow: { display: 'flex', justifyContent: 'space-between', margin: '10px 0' },
        summaryTotal: { display: 'flex', justifyContent: 'space-between', marginTop: '20px', fontWeight: 'bold' },
        checkoutBtn: { backgroundColor: 'green', color: 'white', border: 'none', padding: '10px 20px', cursor: 'pointer', width: '100%', marginTop: '10px' },
        successMessage: { textAlign: 'center', marginTop: '20px', color: 'green', fontSize: '18px' }
    };

    const handleQuantityChange = (id, action) => {
        setCartItems((prevItems) =>
            prevItems.map((item) =>
                item.id === id
                    ? { ...item, quantity: action === 'increase' ? item.quantity + 1 : Math.max(1, item.quantity - 1) }
                    : item
            )
        );
    };

    const handleDelete = (id) => {
        setCartItems((prevItems) => prevItems.filter((item) => item.id !== id));
    };

    // Calculate subtotal
    const calculateSubtotal = () => {
        return cartItems.reduce((total, item) => total + item.price * item.quantity, 0);
    };

    const handleCheckout = () => {
        setCartItems([]); // Clear the cart
        setPurchaseSuccess(true); // Show success message
    };

    return (
        <div>
            <TopMenu />
            <div style={styles.cartContainer}>
                {purchaseSuccess ? (
                    <div style={styles.successMessage}>
                        <p>Purchase Successful</p>
                    </div>
                ) : (
                    <div style={styles.cartContent}>
                        <h2>My cart</h2>
                        {cartItems.map((item) => (
                            <div key={item.id} style={styles.cartItem}>
                                <img src={item.imageUrl} alt={item.name} style={styles.itemImage} />
                                <div style={styles.itemDetails}>
                                    <h4>{item.name}</h4>
                                    <p style={styles.price.discounted}>฿{item.price.toFixed(2)}</p>
                                </div>
                                <div style={{ display: 'flex', alignItems: 'center', marginBottom: '20px' }}>
                                    <span style={{ fontWeight: 'bold', marginRight: '10px' }}>จำนวน</span>
                                    <button
                                        style={{
                                            width: '40px',
                                            height: '40px',
                                            border: '1px solid #ccc',
                                            backgroundColor: 'white',
                                            cursor: 'pointer',
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                            fontSize: '18px'
                                        }}
                                        onClick={() => handleQuantityChange(item.id, 'decrease')}
                                        disabled={item.quantity === 1}
                                    >
                                        -
                                    </button>
                                    <input
                                        type="text"
                                        value={item.quantity}
                                        readOnly
                                        style={{
                                            width: '40px',
                                            height: '40px',
                                            textAlign: 'center',
                                            border: '1px solid #ccc',
                                            borderLeft: 'none',
                                            borderRight: 'none',
                                            padding: '0',
                                            fontSize: '16px'
                                        }}
                                    />
                                    <button
                                        style={{
                                            width: '40px',
                                            height: '40px',
                                            border: '1px solid #ccc',
                                            backgroundColor: 'white',
                                            cursor: 'pointer',
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                            fontSize: '18px'
                                        }}
                                        onClick={() => handleQuantityChange(item.id, 'increase')}
                                    >
                                        +
                                    </button>
                                </div>
                                <div style={styles.itemTotalPrice}>฿{(item.price * item.quantity).toFixed(2)}</div>
                                <button style={styles.deleteBtn} onClick={() => handleDelete(item.id)}>🗑️</button>
                            </div>
                        ))}
                    </div>
                )}

                {cartItems.length > 0 && !purchaseSuccess && (
                    <div style={styles.orderSummary}>
                        <h3>Order summary</h3>
                        <div style={styles.summaryRow}>
                            <span>Subtotal</span>
                            <span>฿{calculateSubtotal().toFixed(2)}</span>
                        </div>
                        <div style={styles.summaryRow}>
                            <span>Delivery</span>
                            <span>FREE</span>
                        </div>
                        <p>Bangkok, Thailand</p>
                        <div style={styles.summaryTotal}>
                            <h4>Total</h4>
                            <h4>฿{calculateSubtotal().toFixed(2)}</h4>
                        </div>
                        <button style={styles.checkoutBtn} onClick={handleCheckout}>Buy</button>
                    </div>
                )}
            </div>
            <Footer />
        </div>
    );
};

export default CartDetail;