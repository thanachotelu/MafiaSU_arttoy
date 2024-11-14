import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { GoogleOAuthProvider } from '@react-oauth/google'; // เพิ่ม GoogleOAuthProvider
import Home from './pages/Home';
import SearchResults from './pages/SearchResults';  // ตรวจสอบการ import ตรงนี้
import ProductDetail from './pages/ProductsDetail';
import Checkout from './pages/Checkout';
import Stores from './pages/Stores'; // เพิ่มการนำเข้า Store
import AllProducts from './pages/AllProducts';
import Profile from './pages/Profile'; // นำเข้า Profile page

import Popmart from './pages/Popmart';
import Gachabox from './pages/Gachabox';
import Atongshopp from './pages/Atongshopp';
import Arttoys from './pages/Arttoys';
import Pieceofjoy from './pages/Pieceofjoy';

function App() {
  return (
    <GoogleOAuthProvider clientId="599564993457-c1fefiejk9akhmbl1642q105hjpbu0tk.apps.googleusercontent.com">
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="/search" element={<SearchResults />} />
        <Route path="/stores" element={<Stores />} />          
        <Route path="/allproducts" element={<AllProducts />} />
        <Route path="/products/:productId" element={<ProductDetail />} />
        <Route path="/checkout" element={<Checkout />} />

        <Route path="/stores/popmart" element={<Popmart />} />         
        <Route path="/stores/gachabox" element={<Gachabox />} />       
        <Route path="/stores/atongshopp" element={<Atongshopp />} />   
        <Route path="/stores/arttoys" element={<Arttoys />} />         
        <Route path="/stores/pieceofjoy" element={<Pieceofjoy />} />
      </Routes>
    </Router>
    </GoogleOAuthProvider>
  );
}

export default App;