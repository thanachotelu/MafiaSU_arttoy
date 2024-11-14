import React, { createContext, useState } from 'react';

// สร้าง Context
export const CartContext = createContext();

// สร้าง Provider สำหรับการใช้ Context
export const CartProvider = ({ children }) => {
    const [cart, setCart] = useState([]);

    // ฟังก์ชันในการเพิ่มสินค้าลงตะกร้า
    const addToCart = (product) => {
        setCart((prevCart) => {
            // ตรวจสอบสินค้าที่ซ้ำกัน
            const existingProduct = prevCart.find(item => item.id === product.id);
            if (existingProduct) {
                return prevCart.map(item =>
                    item.id === product.id
                        ? { ...item, quantity: item.quantity + product.quantity }
                        : item
                );
            }
            return [...prevCart, product];
        });
    };

    return (
        <CartContext.Provider value={{ cart, addToCart }}>
            {children}
        </CartContext.Provider>
    );
};