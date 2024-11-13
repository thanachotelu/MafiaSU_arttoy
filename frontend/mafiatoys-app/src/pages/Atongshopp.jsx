import React, { useState, useEffect } from 'react';
import TopMenu from '../components/TopMenu'; // ส่วนแสดงเมนูด้านบน
import Footer from '../components/Footer'; // ส่วนแสดง Footer
import BannerShop from '../components/BannerShop';
import axios from 'axios';
import { Link } from 'react-router-dom';

import RangeSlider from 'react-range-slider-input';
import 'react-range-slider-input/dist/style.css';
import '../index.css';

const Atongshopp = () => {
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
    const isFromArtToysSeller = product.sellers[0]?.name === "Atongshopp 玩具";
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

      <BannerShop storeName="Atong Shopp" backgroundColor="#D2B48C" banner_img1="https://scontent.fbkk9-3.fna.fbcdn.net/v/t39.30808-6/428617724_925811632880787_5884227748070235600_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=cc71e4&_nc_ohc=76CvZw22JZAQ7kNvgFidYTP&_nc_zt=23&_nc_ht=scontent.fbkk9-3.fna&_nc_gid=AFJjwuN2Knn0p31hC8jNzC3&oh=00_AYDoyCZ5WEVRY9sda3Ne8jidjtA6M5ka-g0nG13Iv8AVMA&oe=673543F1"
            banner_img2="https://scontent.fbkk13-2.fna.fbcdn.net/v/t39.30808-6/465790529_1120811343380814_5388387444380418414_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=127cfc&_nc_ohc=AaIgzBls4L4Q7kNvgFxYVhz&_nc_zt=23&_nc_ht=scontent.fbkk13-2.fna&_nc_gid=AKhU9X5-VgpDrFIb088xvVF&oh=00_AYAT4AmqzRXKa4G7VVkjmXcX301Wm9_kMoG6DwLL0u3oUw&oe=67354B56"
            banner_img3="https://scontent.fbkk13-2.fna.fbcdn.net/v/t39.30808-6/465790529_1120811343380814_5388387444380418414_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=127cfc&_nc_ohc=AaIgzBls4L4Q7kNvgFxYVhz&_nc_zt=23&_nc_ht=scontent.fbkk13-2.fna&_nc_gid=AKhU9X5-VgpDrFIb088xvVF&oh=00_AYAT4AmqzRXKa4G7VVkjmXcX301Wm9_kMoG6DwLL0u3oUw&oe=67354B56"
            width_img2="50%" height_img2="auto" width_img3="50%" height_img3="auto"
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
                        value="BABY ZORAA"
                        onChange={handleBrandChange}
                    />
                    ㅤBABY ZORAA
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="CRYBABY"
                        onChange={handleBrandChange}
                    />
                    ㅤCRYBABY
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="FORERUNNER"
                        onChange={handleBrandChange}
                    />
                    ㅤFORERUNNER
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="Hirono"
                        onChange={handleBrandChange}
                    />
                    ㅤHirono
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
                        value="SKULLPANDA"
                        onChange={handleBrandChange}
                    />
                    ㅤSKULLPANDA
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="Sank"
                        onChange={handleBrandChange}
                    />
                    ㅤSank
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
          <div className="sort-container-right">
            <label>Sort by: </label>
            <select onChange={handleSortChange} value={sortOption}>
              <option value="">None</option>
              <option value="price-asc">Price: Low to High</option>
              <option value="price-desc">Price: High to Low</option>
              <option value="name-asc">Name: A-Z</option>
              <option value="name-desc">Name: Z-A</option>
            </select>
          </div>

          <h1 className="title">All Products[{sortedProducts.length}]</h1>
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

export default Atongshopp;