import React, { useState } from 'react';
import TopMenu from '../../components/TopMenu'; // ส่วนแสดงเมนูด้านบน
import Footer from '../../components/Footer'; // ส่วนแสดง Footer

import RangeSlider from 'react-range-slider-input';
import 'react-range-slider-input/dist/style.css';
import '../../index.css';

const products = [
    { id: 1, name: "Art Toy 1", price: "฿1,200", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp", shop: "POP MART" },
    { id: 2, name: "Art Toy 2", price: "฿1,500", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp", shop: "ATONGS SHOPP" },
    { id: 3, name: "Art Toy 3", price: "฿2,000", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp", shop: "ART TOYS" },
    { id: 4, name: "Art Toy 4", price: "฿2,500", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp", shop: "GACHABOX" },
    { id: 5, name: "Art Toy 5", price: "฿3,000", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp", shop: "PIECE OF JOY" },
    { id: 6, name: "Art Toy 6", price: "฿3,500", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp", shop: "POP MART" }
];

const Atongshopp = () => {
    const [priceRange, setPriceRange] = useState([0, 5000]);
    const [selectedCategories, setSelectedCategories] = useState([]);
    const [selectedShops, setSelectedShops] = useState(["ATONGS SHOPP"]); // Default selected shop
    const [sortOption, setSortOption] = useState('');

    const handlePriceRangeChange = (value) => {
        setPriceRange(value);
    };

    const handleCategoryChange = (e) => {
        const category = e.target.value;
        if (e.target.checked) {
            setSelectedCategories([...selectedCategories, category]);
        } else {
            setSelectedCategories(selectedCategories.filter(item => item !== category));
        }
    };

    const handleShopChange = (e) => {
        const shop = e.target.value;
        if (e.target.checked) {
            setSelectedShops([...selectedShops, shop]);
        } else {
            setSelectedShops(selectedShops.filter(item => item !== shop));
        }
    };

    const handleSortChange = (e) => {
        setSortOption(e.target.value);
    };

    const filteredProducts = products.filter(product => {
        const price = parseInt(product.price.replace("฿", "").replace(",", ""));
        const isInPriceRange = price >= priceRange[0] && price <= priceRange[1];
        const isInCategory = selectedCategories.length === 0 || selectedCategories.some(category => product.name.includes(category));
        const isInShop = selectedShops.length === 0 || selectedShops.includes(product.shop);
        return isInPriceRange && isInCategory && isInShop;
    });

    const sortedProducts = filteredProducts.sort((a, b) => {
        if (sortOption === 'price-asc') {
            return parseInt(a.price.replace('฿', '').replace(',', '')) - parseInt(b.price.replace('฿', '').replace(',', ''));
        }
        if (sortOption === 'price-desc') {
            return parseInt(b.price.replace('฿', '').replace(',', '')) - parseInt(a.price.replace('฿', '').replace(',', ''));
        }
        if (sortOption === 'name-asc') {
            return a.name.localeCompare(b.name);
        }
        if (sortOption === 'name-desc') {
            return b.name.localeCompare(a.name);
        }
        return 0;
    });


    return (
        <div>
            <TopMenu />

            {/* ป้ายโฆษณาของร้านค้า */}
            {/* เพิ่ม <style> ที่กำหนด keyframes animation */}
            <style>
                {`
                    @keyframes marquee {
                        0% {
                            transform: translateX(100%); /* เริ่มต้นที่ขวาสุด */
                        }
                        100% {
                            transform: translateX(-300%); /* เลื่อนจนถึงขวาสุด */
                        }
                    }
                `}
            </style>
            {/* ป้ายโฆษณาของร้านค้า */}
            <div className="advertisement-banner" style={{
                backgroundColor: '#D2B48C',
                padding: '20px',
                textAlign: 'center',
                marginBottom: '20px',
                fontSize: '1.25rem',
                fontWeight: 'bold',
                borderRadius: '10px',
                boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
                overflow: 'hidden', // ให้ขอบข้อความที่เลื่อนออกไปไม่แสดง
                position: 'relative',
                height: '70px'
            }}>
                <div style={{
                    display: 'inline-block',
                    whiteSpace: 'nowrap', // ให้ข้อความอยู่ในแถวเดียว
                    animation: 'marquee 11s linear infinite', // กำหนดความเร็วและการวนลูปของการเคลื่อนที่
                    position: 'absolute', // ใช้ position เพื่อให้ข้อความเคลื่อนไปจากขวาไปซ้าย
                    left: '100%' // เริ่มต้นจากขวาสุด
                }}>
                    <p>🚨 Welcome to Atongshopp! 🚨 Check out our latest art toys and limited edition figures! 🛍️</p>
                </div>
            </div>

            {/* รูปภาพโฆษณาต่อจากป้ายโฆษณา */}

            <div style={{
                marginBottom: '20px',
                textAlign: 'center'
            }}>
                <img
                    src="https://scontent.fbkk9-3.fna.fbcdn.net/v/t39.30808-6/428617724_925811632880787_5884227748070235600_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=cc71e4&_nc_ohc=76CvZw22JZAQ7kNvgFidYTP&_nc_zt=23&_nc_ht=scontent.fbkk9-3.fna&_nc_gid=AFJjwuN2Knn0p31hC8jNzC3&oh=00_AYDoyCZ5WEVRY9sda3Ne8jidjtA6M5ka-g0nG13Iv8AVMA&oe=673543F1"
                    alt="Advertisement"
                    style={{
                        width: '100%',
                        height: 'auto',
                        borderRadius: '10px',
                        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)'
                    }}
                />
            </div>

            <div style={{
                marginBottom: '20px',
                textAlign: 'center',
                padding: '0 10px' // เพิ่ม padding ด้านซ้ายและขวา เพื่อไม่ให้แนบติดขอบ
            }}>
                <img
                    src="https://scontent.fbkk13-2.fna.fbcdn.net/v/t39.30808-6/465790529_1120811343380814_5388387444380418414_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=127cfc&_nc_ohc=AaIgzBls4L4Q7kNvgFxYVhz&_nc_zt=23&_nc_ht=scontent.fbkk13-2.fna&_nc_gid=AKhU9X5-VgpDrFIb088xvVF&oh=00_AYAT4AmqzRXKa4G7VVkjmXcX301Wm9_kMoG6DwLL0u3oUw&oe=67354B56"
                    alt="Advertisement"
                    style={{
                        width: '50%', // กำหนดให้รูปภาพขยายเต็มความกว้าง
                        maxWidth: '1200px', // จำกัดขนาดความกว้างสูงสุด
                        height: 'auto',
                        borderRadius: '10px',
                        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
                        margin: '0 auto' // จัดกลาง
                    }}
                />

                <img
                    src="https://scontent.fbkk12-1.fna.fbcdn.net/v/t39.30808-6/465279387_1119393893522559_6173654287841269165_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=127cfc&_nc_ohc=4KfBww6rQJYQ7kNvgGt6Sk-&_nc_zt=23&_nc_ht=scontent.fbkk12-1.fna&_nc_gid=AioKtf_51Y8m-MN7HQy8eVl&oh=00_AYCbwHXHNEvTOECVQb9zODWd5pO10jGrryHSnecmfVXVmg&oe=673530B9"
                    alt="Advertisement"
                    style={{
                        width: '50%',
                        maxWidth: '1200px', // จำกัดขนาดความกว้างสูงสุด
                        height: 'auto',
                        borderRadius: '10px',
                        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
                        margin: '0 auto' // จัดกลาง
                    }}
                />
            </div>


            <div className="all-products-container">
                <div className="filter-container">
                    <h2>Category</h2>
                    <div className="category-checkbox">
                        <label>
                            <input
                                type="checkbox"
                                value="Art Toy"
                                onChange={handleCategoryChange}
                            />
                            ㅤArt Toy
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="Figure"
                                onChange={handleCategoryChange}
                            />
                            ㅤFigure
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="Accessories"
                                onChange={handleCategoryChange}
                            />
                            ㅤAccessories
                        </label>
                    </div>

                    <h2>Shop</h2>
                    <div className="category-checkbox">
                        <label>
                            <input
                                type="checkbox"
                                value="ATONGS SHOPP"
                                onChange={handleShopChange}
                                checked={selectedShops.includes("ATONGS SHOPP")}
                            />
                            ㅤATONGS SHOPP
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="ART TOYS"
                                onChange={handleShopChange}
                                checked={selectedShops.includes("ART TOYS")}
                            />
                            ㅤART TOYS
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="GACHABOX"
                                onChange={handleShopChange}
                                checked={selectedShops.includes("GACHABOX")}
                            />
                            ㅤGACHABOX
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="POP MART"
                                onChange={handleShopChange}
                                checked={selectedShops.includes("POP MART")} // Default checked
                            />
                            ㅤPOP MART
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="PIECE OF JOY"
                                onChange={handleShopChange}
                                checked={selectedShops.includes("PIECE OF JOY")}
                            />
                            ㅤPIECE OF JOY
                        </label>
                    </div>

                    <div className="price-range-container">
                        <div className="range-label">ช่วงราคา</div>
                        <RangeSlider
                            min={0}
                            max={5000}
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

                    <h1 className="title">All Products</h1>
                    <div className="product-grid">
                        {sortedProducts.map(product => (
                            <div className="card" key={product.id}>
                                <img src={product.imageUrl} alt={product.name} className="product-image" />
                                <div className="container">
                                    <h6><b>{product.name}</b></h6>
                                    <p>{product.price}</p>
                                    <p><small>Shop: {product.shop}</small></p>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            <Footer />
        </div>
    );
};

export default Atongshopp;
