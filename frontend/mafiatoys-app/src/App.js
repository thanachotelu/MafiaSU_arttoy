import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { GoogleOAuthProvider } from "@react-oauth/google"; // เพิ่ม GoogleOAuthProvider
import Home from "./pages/Home";
import SearchResults from "./pages/SearchResults"; // ตรวจสอบการ import ตรงนี้
import ProductDetail from "./pages/ProductsDetail";

import { CartProvider } from "./pages/CartContext";

import Stores from "./pages/Stores"; // เพิ่มการนำเข้า Store
import AllProducts from "./pages/AllProducts";
import CartDetail from "./pages/CartDetail";

import Atongshopp from "./pages/Stores/Atongshopp";
import Arttoys from "./pages/Stores/Arttoys";
import Gachabox from "./pages/Stores/Gachabox";
import Popmart from "./pages/Stores/Popmart";
import Pieceofjoy from "./pages/Stores/Pieceofjoy";

function App() {

  return (
    <GoogleOAuthProvider clientId="599564993457-c1fefiejk9akhmbl1642q105hjpbu0tk.apps.googleusercontent.com">
      <CartProvider>
        <Router>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/search" element={<SearchResults />} />
            <Route path="/stores" element={<Stores />} />
            <Route path="/allproducts" element={<AllProducts />} />

            <Route path="/products/:productId" element={<ProductDetail />} />
            <Route path="/CartDetail"element={<CartDetail />}/>
            <Route path="/Stores" element={<Stores />} />
            <Route path="/Storepages/Atongshopp" element={<Atongshopp />} />
            <Route path="/Storepages/Arttoys" element={<Arttoys />} />
            <Route path="/Storepages/Gachabox" element={<Gachabox />} />
            <Route path="/Storepages/Popmart" element={<Popmart />} />
            <Route path="/Storepages/Pieceofjoy" element={<Pieceofjoy />} />
          </Routes>
        </Router>
      </CartProvider>
    </GoogleOAuthProvider>
  );
}

export default App;
