// CartContext.js
import React, { createContext, useState, useContext } from 'react';

const CartContext = createContext();

export const CartProvider = ({ children }) => {
    const [cartItems, setCartItems] = useState([]);

    const addToCart = (product, quantity) => {
        setCartItems(prevItems => [...prevItems, { ...product, quantity }]);
    };

    return (
        <CartContext.Provider value={{ cartItems, addToCart , setCartItems}}>
            {children}
        </CartContext.Provider>
    );
};

export const useCart = () => useContext(CartContext);
