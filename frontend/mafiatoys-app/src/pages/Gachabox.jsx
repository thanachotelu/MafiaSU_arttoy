import React, { useState, useEffect } from 'react';
import TopMenu from '../components/TopMenu'; // ส่วนแสดงเมนูด้านบน
import Footer from '../components/Footer'; // ส่วนแสดง Footer
import BannerShop from '../components/BannerShop';
import axios from 'axios';
import { Link } from 'react-router-dom';

import RangeSlider from 'react-range-slider-input';
import 'react-range-slider-input/dist/style.css';
import '../index.css';

const Gachabox = () => {
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
    const isFromArtToysSeller = product.sellers[0]?.name === "Gachabox";
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

      <BannerShop storeName="Gachabox" backgroundColor="#FFD700" banner_img1="/assets/images/logo_gachabox.jpg"
                banner_img2="https://scontent.fbkk8-2.fna.fbcdn.net/v/t39.30808-6/465866070_960482722774081_8596527507718089336_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=127cfc&_nc_ohc=tko_14XsVz8Q7kNvgHbmgfy&_nc_zt=23&_nc_ht=scontent.fbkk8-2.fna&_nc_gid=AYtX6h7RxLKDM3Pbzm88sr1&oh=00_AYBqHRRDcyWOaTWCqlyz26ZyVbkNo_j0JjtpDBgD7lOBdQ&oe=6737C5A4"
                banner_img3="https://scontent.fbkk9-3.fna.fbcdn.net/v/t39.30808-6/465777239_957222976433389_592922328259176680_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=127cfc&_nc_ohc=K1hEv_w6hOQQ7kNvgGHQH8p&_nc_zt=23&_nc_ht=scontent.fbkk9-3.fna&_nc_gid=AVhcBoXKz18su6BmynvJ11v&oh=00_AYCZPRMH_eYEFVuT6-n1g4cdjWtF7uJzao4-y5rae0xT9Q&oe=6737EDA5"
                width_img2="49%" height_img2="49%" width_img3="51%" height_img3="51%"
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
                        value="Hirono"
                        onChange={handleBrandChange}
                    />
                    ㅤHirono
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="Lamtoys"
                        onChange={handleBrandChange}
                    />
                    ㅤLamtoys
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="Medicom Toy"
                        onChange={handleBrandChange}
                    />
                    ㅤMedicom Toy
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="Mytoy"
                        onChange={handleBrandChange}
                    />
                    ㅤMytoy
                </label>
                <label>
                    <input
                        type="checkbox"
                        value="POLAR"
                        onChange={handleBrandChange}
                    />
                    ㅤPOLAR
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

          <h1 className="title">All Products</h1>
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

export default Gachabox;