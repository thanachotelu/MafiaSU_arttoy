import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { GoogleOAuthProvider } from '@react-oauth/google'; // เพิ่ม GoogleOAuthProvider
import Home from './pages/Home';
import SearchResults from './pages/SearchResults';  // ตรวจสอบการ import ตรงนี้
import ProductDetail from './pages/ProductsDetail';

import Stores from './pages/Stores'; // เพิ่มการนำเข้า Store
import AllProducts from './pages/AllProducts';
// import Profile from './pages/Profile'; // นำเข้า Profile page


function App() {
  return (
    <GoogleOAuthProvider clientId="599564993457-c1fefiejk9akhmbl1642q105hjpbu0tk.apps.googleusercontent.com">
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/search" element={<SearchResults />} />
        <Route path="/stores" element={<Stores />} />          
        <Route path="/allproducts" element={<AllProducts />} />
        <Route path="/productsdetail" element={<ProductDetail />} />
      </Routes>
    </Router>
    </GoogleOAuthProvider>
  );
}

export default App;