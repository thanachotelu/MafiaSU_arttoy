import React, { useState } from "react";
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { GoogleOAuthProvider } from '@react-oauth/google';
import Home from './pages/Home';
import SearchResults from './pages/SearchResults';
import ProductDetail from './pages/ProductsDetail';
import Stores from './pages/Stores';
import AllProducts from './pages/AllProducts';
import Popmart from './pages/Popmart';
import Gachabox from './pages/Gachabox';
import Atongshopp from './pages/Atongshopp';
import Arttoys from './pages/Arttoys';
import Pieceofjoy from './pages/Pieceofjoy';
import Cart from './pages/Cart';
import { CartProvider } from './context/CartContext';

function App() {
  const [cartItems, setCartItems] = useState([]);
  const addToCart = (product) => {
    setCartItems((prevItems) => {
      // ตรวจสอบว่าสินค้ามีอยู่ในตะกร้าแล้วหรือไม่
      const existingItem = prevItems.find((item) => item.id === product.id);
      if (existingItem) {
        // ถ้าสินค้าซ้ำในตะกร้า ให้เพิ่มจำนวน
        return prevItems.map((item) =>
          item.id === product.id
            ? { ...item, quantity: item.quantity + product.quantity }
            : item
        );
      } else {
        // ถ้าสินค้าไม่ซ้ำ ให้เพิ่มสินค้าใหม่
        return [...prevItems, product];
      }
    });
  };
  return (
    <GoogleOAuthProvider clientId="599564993457-c1fefiejk9akhmbl1642q105hjpbu0tk.apps.googleusercontent.com">
      <CartProvider>
        <Router>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/search" element={<SearchResults />} />
            <Route path="/stores" element={<Stores />} />
            <Route path="/cart" element={<Cart cartItems={cartItems} setCartItems={setCartItems}/>} />       
            <Route path="/allproducts" element={<AllProducts />} />
            <Route path="/products/:productId" element={<ProductDetail addToCart={addToCart}/>} />
            <Route path="/stores/popmart" element={<Popmart />} />         
            <Route path="/stores/gachabox" element={<Gachabox />} />       
            <Route path="/stores/atongshopp" element={<Atongshopp />} />   
            <Route path="/stores/arttoys" element={<Arttoys />} />         
            <Route path="/stores/pieceofjoy" element={<Pieceofjoy />} />
          </Routes>
        </Router>
      </CartProvider>
    </GoogleOAuthProvider>
  );
}

export default App;