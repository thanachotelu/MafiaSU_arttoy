import React, { useState } from 'react';
import TopMenu from '../components/TopMenu'; // ส่วนแสดงเมนูด้านบน
import Footer from '../components/Footer'; // ส่วนแสดง Footer
import '../index.css'; // นำเข้าไฟล์ CSS

const products = [
    { id: 1, name: "Art Toy 1", price: "฿1,200", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp" },
    { id: 2, name: "Art Toy 2", price: "฿1,500", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp" },
    { id: 3, name: "Asscories 1", price: "฿2,000", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp" },
    { id: 4, name: "Figure 1", price: "฿2,500", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp" },
    { id: 5, name: "Art Toy 3", price: "฿3,000", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp" },
    { id: 6, name: "ATONGS SHOPP 玩具", price: "฿3,500", imageUrl: "https://prod-eurasian-res.popmart.com/default/20240304_164111_296715__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp" }
];

const AllProducts = () => {
    const [minPrice, setMinPrice] = useState(0);
    const [maxPrice, setMaxPrice] = useState(5000);
    const [selectedCategories, setSelectedCategories] = useState([]);

    const handleMinPriceChange = (e) => setMinPrice(e.target.value);
    const handleMaxPriceChange = (e) => setMaxPrice(e.target.value);

    const handleCategoryChange = (e) => {
        const category = e.target.value;
        if (e.target.checked) {
            setSelectedCategories([...selectedCategories, category]);
        } else {
            setSelectedCategories(selectedCategories.filter(item => item !== category));
        }
    };

    const filteredProducts = products.filter(product => {
        const price = parseInt(product.price.replace("฿", "").replace(",", ""));
        const isInPriceRange = price >= minPrice && price <= maxPrice;
        const isInCategory = selectedCategories.length === 0 || selectedCategories.some(category => product.name.includes(category));
        return isInPriceRange && isInCategory;
    });

    return (
        <div>
            <TopMenu />

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
                                value="Asscories"
                                onChange={handleCategoryChange}
                            />
                            ㅤAsscories
                        </label>
                    </div>

                    <h2>ㅤ</h2>
                    <h2>Shop</h2>
                    <div className="category-checkbox">
                        <label>
                            <input
                                type="checkbox"
                                value="ATONGS SHOPP"
                                onChange={handleCategoryChange}
                            />
                            ㅤATONGS SHOPP 玩具
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="ART TOYS"
                                onChange={handleCategoryChange}
                            />
                            ㅤART TOYS
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="GACHABOX"
                                onChange={handleCategoryChange}
                            />
                            ㅤGACHABOX
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="POP MART"
                                onChange={handleCategoryChange}
                            />
                            ㅤPOP MART
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="PIECE OF JOY"
                                onChange={handleCategoryChange}
                            />
                            ㅤPIECE OF JOY
                        </label>
                    </div>

                    <h2>ㅤ</h2>

                    <div className="price-range-container">
                        <div className="range-label"><h2>Price range</h2></div>
                        <p>minPrice</p>
                        <input
                            type="range"
                            min="0"
                            max="5000"
                            value={minPrice}
                            onChange={handleMinPriceChange}
                            className="range-slider"
                        />
                        <p>maxPrice</p>
                        <input
                            type="range"
                            min="0"
                            max="5000"
                            value={maxPrice}
                            onChange={handleMaxPriceChange}
                            className="range-slider"
                        />
                        <div className="range-value">
                            <span>฿{minPrice}</span>
                            <span>฿{maxPrice}</span>
                        </div>
                    </div>
                </div>

                <div className="product-section">
                    <h1 className="title">All Products</h1>
                    <div className="product-grid">
                        {filteredProducts.map(product => (
                            <div className="card" key={product.id}>
                                <img src={product.imageUrl} alt={product.name} className="product-image" />
                                <div className="container">
                                    <h6><b>{product.name}</b></h6>
                                    <p style={{ color: '#888', fontSize: '0.8pm'}}>{product.price}</p> 
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

export default AllProducts;