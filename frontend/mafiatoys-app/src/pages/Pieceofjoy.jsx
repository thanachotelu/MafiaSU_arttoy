import React, { useState, useEffect } from 'react';
import TopMenu from '../components/TopMenu'; // ส่วนแสดงเมนูด้านบน
import Footer from '../components/Footer'; // ส่วนแสดง Footer
import BannerShop from '../components/BannerShop';
import axios from 'axios';
import { Link } from 'react-router-dom';

import RangeSlider from 'react-range-slider-input';
import 'react-range-slider-input/dist/style.css';
import '../index.css';

const Pieceofjoy = () => {
  const [products, setProducts] = useState([]);
  const [productImages, setProductImages] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [priceRange, setPriceRange] = useState([0, 20000]);
  const [selectedCategories, setSelectedCategories] = useState([]);
  const [sortOption, setSortOption] = useState('');
  const [selectedBrands, setSelectedBrands] = useState([]);

  const handlePriceRangeChange = (value) => {
    setPriceRange(value);
};

const handleSortChange = (e) => {
    setSortOption(e.target.value);
};

// ดึงข้อมูลรูปภาพของสินค้าจาก API getProductImages
const fetchProductImages = async (productId) => {
    try {
        const response = await axios.get(`http://localhost:8080/api/v1/products/images/${productId}`);
        
        // ตรวจสอบว่า data.images และ data.images[0] มีค่าหรือไม่
        setProductImages(prevImages => ({
            ...prevImages,
            [productId]: response.data.images && response.data.images.length > 0 ? response.data.images[0]?.image_url : ''
        }));
    } catch (error) {
        console.error('Error fetching product images:', error);
    }
};

useEffect(() => {
    // เมื่อได้ข้อมูลสินค้าแล้ว เราจะดึงข้อมูลภาพสำหรับแต่ละสินค้า
    products.forEach(product => {
        fetchProductImages(product.product_id);
    });
}, [products]);

// ดึงข้อมูลสินค้าทั้งหมดจาก API products
useEffect(() => {
    const fetchProducts = async () => {
        try {
            const response = await axios.get('http://localhost:8080/api/v1/products');
            setProducts(response.data.items || []);
        } catch (err) {
            setError('Failed to fetch products');
        } finally {
            setLoading(false);
        }
    };
    fetchProducts();
}, []);

const handleCategoryChange = (e) => {
    const category = e.target.value;
    if (e.target.checked) {
        setSelectedCategories([...selectedCategories, category]);
    } else {
        setSelectedCategories(selectedCategories.filter(item => item !== category));
    }
};

const handleBrandChange = (e) => {
    const brand = e.target.value;
    if (e.target.checked) {
        setSelectedBrands([...selectedBrands, brand]);
    } else {
        setSelectedBrands(selectedBrands.filter(item => item !== brand));
    }
};

// กรองสินค้าตามราคาและหมวดหมู่และร้านค้า
const filteredProducts = products.filter(product => {
    let price = 0;
    if (typeof product.price === 'string') {
        price = parseInt(product.price.replace("฿", "").replace(",", ""));
    } else if (typeof product.price === 'number') {
        price = product.price;
    }
    const isInPriceRange = price >= priceRange[0] && price <= priceRange[1];
    const isInCategory = selectedCategories.length === 0 || selectedCategories.includes(product.product_type);
    const isInBrand = selectedBrands.length === 0 || selectedBrands.includes(product.brand);
    const isFromArtToysSeller = product.sellers[0]?.name === "PIECE Of JOY";
    return isInPriceRange && isInCategory && isInBrand && isFromArtToysSeller;
});

const sortedProducts = filteredProducts.sort((a, b) => {
    if (sortOption === 'price-asc') {
        return a.price - b.price;
    }
    if (sortOption === 'price-desc') {
        return b.price - a.price;
    }
    if (sortOption === 'name-asc') {
        return a.name.localeCompare(b.name);
    }
    if (sortOption === 'name-desc') {
        return b.name.localeCompare(a.name);
    }
    return 0;
});
if (loading) return <div>Loading...</div>;
if (error) return <div>{error}</div>;
  return (
    <div>
      <TopMenu />

      <BannerShop storeName="Piece of joy" backgroundColor="#f48fb1" banner_img1="https://scontent.fbkk13-3.fna.fbcdn.net/v/t39.30808-6/346975532_193998963556760_4073645957057748162_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=cc71e4&_nc_ohc=eZC_8NtbuAwQ7kNvgFlqXWz&_nc_zt=23&_nc_ht=scontent.fbkk13-3.fna&_nc_gid=AeL31NZ1vSyNjUiMresnOn-&oh=00_AYALNhV3TLJtpnPWh5JuLfOUyEq81ohG8K-rtMMBWQfzwQ&oe=6737BAC4"
                banner_img2="https://scontent.fbkk8-2.fna.fbcdn.net/v/t39.30808-6/465737692_1084221606960560_6886901789086080647_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=833d8c&_nc_ohc=lS75l6lKuu8Q7kNvgHHa1YD&_nc_zt=23&_nc_ht=scontent.fbkk8-2.fna&_nc_gid=A5W3foXEQNXqzDDJLK4De3Q&oh=00_AYAZFzGCzXAhvNf8YtQXRHguBVKcPuHkqWnUPn0JThPwjg&oe=6737E0B3"
                banner_img3="https://scontent.fbkk8-2.fna.fbcdn.net/v/t39.30808-6/465271364_1084221796960541_4030137183314992019_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=833d8c&_nc_ohc=6BPmMsfOsDkQ7kNvgEbMxZR&_nc_zt=23&_nc_ht=scontent.fbkk8-2.fna&_nc_gid=AOKWAbSfZbDUUE3MoPyvBQs&oh=00_AYAVkMwpTHmEVQXQFKRgkDk00dr08LdAdFEEoP9fA09BeQ&oe=6737B7B6"
                width_img2="55%" height_img2="55%" width_img3="40%" height_img3="40%"
      />


      <div className="all-products-container">
        <div className="filter-container">
          <h2>Category</h2>
          <div className="category-checkbox">
            <label>
              <input
                type="checkbox"
                value="arttoy"
                onChange={handleCategoryChange}
              />
              ㅤArt Toy
            </label>
            <label>
              <input
                type="checkbox"
                value="figure"
                onChange={handleCategoryChange}
              />
              ㅤFigure
            </label>
            <label>
              <input
                type="checkbox"
                value="accessory"
                onChange={handleCategoryChange}
              />
              ㅤAccessories
            </label>
          </div>

          <h2>Brand</h2>
            <div className="category-checkbox">
                <label>
                    <input
                        type="checkbox"
                        value="Baby Three"
                        onChange={handleBrandChange}
                    />
                    ㅤBaby Three
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="F.UN"
                        onChange={handleBrandChange}
                    />
                    ㅤF.UN
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="MOLLY"
                        onChange={handleBrandChange}
                    />
                    ㅤMOLLY
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="Maltese"
                        onChange={handleBrandChange}
                    />
                    ㅤMaltese
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="RICO"
                        onChange={handleBrandChange}
                    />
                    ㅤRICO
                </label>
            </div>

          <div className="price-range-container">
            <div className="range-label">ช่วงราคา</div>
            <RangeSlider
              min={0}
              max={20000}
              step={100}
              value={priceRange}
              onInput={handlePriceRangeChange}
              className="range-slider"
            />
            <div className="range-value">
              <span>฿{priceRange[0]}</span>
              <span>฿{priceRange[1]}</span>
            </div>
          </div>
        </div>

        <div className="product-section">

          <h1 className="title">All Products[{sortedProducts.length}]</h1>

          <div className="sort-container-right" style={{marginBottom: '30px'}}>
            <label>Sort by : </label>
            <select onChange={handleSortChange} value={sortOption}>
              <option value="">None</option>
              <option value="price-asc">Price: Low to High</option>
              <option value="price-desc">Price: High to Low</option>
              <option value="name-asc">Name: A-Z</option>
              <option value="name-desc">Name: Z-A</option>
            </select>
          </div>
          
          {sortedProducts.length.length === 0 && <p>No products found</p>}
          <div className="product-grid">
            {sortedProducts.map(product => {
                // ตรวจสอบว่า images มีค่าหรือไม่ และเป็น Array หรือไม่
                const primaryImage = Array.isArray(product.images) && product.images.length > 0 
                    ? product.images.find(img => img.is_primary && product.category_id === product.categories[0]?.id) 
                    : null;

                // ถ้าไม่มีรูปภาพที่เป็น primary ให้ใช้รูปแรกใน Array หรือเป็นค่าว่างถ้าไม่มีรูปใดๆ
                const imageUrl = primaryImage 
                    ? primaryImage.image_url 
                    : (Array.isArray(product.images) && product.images[0]?.image_url) || '';

                const displayedImageUrl = productImages[product.product_id] || imageUrl || '/placeholder.jpg';

                return (
                    <Link to={`/products/${product.product_id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                        <div className="card" key={product.product_id} style={{ cursor: 'pointer' , height: '100%'}}>
                            <img
                                src={displayedImageUrl} 
                                alt={product.name} 
                                className="product-image" 
                                onError={(e) => { e.target.src = '/placeholder.jpg'; }} // ใช้ placeholder ถ้าภาพโหลดไม่ได้
                            />
                            <div className="container">
                                <h5 align="left"><b style={{color: 'gray'}}>{product.sellers[0]?.name || "Unknown Shop"}</b></h5>
                                <h6 align="left"><b>{product.name}</b></h6>
                                <p align="left"style={{ color: 'red', fontSize: '1.1em' }}>฿{product.price.toLocaleString()}.00</p>
                            </div>
                        </div>
                    </Link>
                );
            })}
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
};

export default Pieceofjoy;