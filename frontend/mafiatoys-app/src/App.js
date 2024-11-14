import React, { useState } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { GoogleOAuthProvider } from "@react-oauth/google"; // เพิ่ม GoogleOAuthProvider
import Home from "./pages/Home";
import SearchResults from "./pages/SearchResults"; // ตรวจสอบการ import ตรงนี้
import ProductDetail from "./pages/ProductsDetail";

import Stores from "./pages/Stores"; // เพิ่มการนำเข้า Store
import AllProducts from "./pages/AllProducts";
import Profile from "./pages/Profile"; // นำเข้า Profile page
import CartDetail from './pages/CartDetail';

import Atongshopp from "./pages/Stores/Atongshopp";
import Arttoys from "./pages/Stores/Arttoys";
import Gachabox from "./pages/Stores/Gachabox";
import Popmart from "./pages/Stores/Popmart";
import Pieceofjoy from "./pages/Stores/Pieceofjoy";

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
      <Router>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/search" element={<SearchResults />} />
          <Route path="/stores" element={<Stores />} />
          <Route path="/allproducts" element={<AllProducts />} />

          <Route path="/products/:productId" element={<ProductDetail addToCart={addToCart} />} />
          <Route path="/CartDetail" element={<CartDetail cartItems={cartItems} setCartItems={setCartItems} />} />
        <Route path="/Stores" element={<Stores />} />

          <Route path="/Storepages/Atongshopp" element={<Atongshopp />} />
          <Route path="/Storepages/Arttoys" element={<Arttoys />} />
          <Route path="/Storepages/Gachabox" element={<Gachabox />} />
          <Route path="/Storepages/Popmart" element={<Popmart />} />
          <Route path="/Storepages/Pieceofjoy" element={<Pieceofjoy />} />
        </Routes>
      </Router>
    </GoogleOAuthProvider>
  );
}

export default App;
