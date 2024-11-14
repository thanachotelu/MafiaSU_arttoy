import React from "react";
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
  return (
    <GoogleOAuthProvider clientId="599564993457-c1fefiejk9akhmbl1642q105hjpbu0tk.apps.googleusercontent.com">
      <CartProvider>
        <Router>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/search" element={<SearchResults />} />
            <Route path="/stores" element={<Stores />} />
            <Route path="/cart" element={<Cart />} />       
            <Route path="/allproducts" element={<AllProducts />} />
            <Route path="/products/:productId" element={<ProductDetail />} />
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
