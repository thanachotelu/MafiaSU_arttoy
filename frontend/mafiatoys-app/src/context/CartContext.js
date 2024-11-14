// CartContext.js
import React, { createContext, useState, useContext } from 'react';

const CartContext = createContext();

export const CartProvider = ({ children }) => {
    const [cartItems, setCartItems] = useState([]);

    const addToCart = (product, quantity) => {
        setCartItems(prevItems => {
            const itemIndex = prevItems.findIndex(item => item.product_id === product.product_id);

            if (itemIndex !== -1) {
                // ถ้าสินค้ามีอยู่ในตะกร้าแล้ว ให้เพิ่มจำนวน
                const updatedItems = [...prevItems];
                updatedItems[itemIndex].quantity += quantity;
                return updatedItems;
            }

            // ถ้าไม่มี ให้เพิ่มสินค้าใหม่ในตะกร้า
            return [...prevItems, { ...product, quantity }];
        });
    };

    const removeFromCart = (product_id) => {
        setCartItems(prevItems => prevItems.filter(item => item.product_id !== product_id));
    };

    const updateItemQuantity = (product_id, quantity) => {
        setCartItems(prevItems => 
            prevItems.map(item => 
                item.product_id === product_id ? { ...item, quantity } : item
            )
        );
    };

    const removeAllItems = () => {
        setCartItems([]);
    };

    return (
        <CartContext.Provider value={{ cartItems, addToCart, removeFromCart, updateItemQuantity , removeAllItems}}>
            {children}
        </CartContext.Provider>
    );
};

export const useCart = () => useContext(CartContext);
