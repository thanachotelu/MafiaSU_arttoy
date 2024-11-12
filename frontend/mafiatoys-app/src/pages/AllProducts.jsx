import React, { useState, useEffect } from 'react';
import axios from 'axios';
import TopMenu from '../components/TopMenu';
import Footer from '../components/Footer';
import RangeSlider from 'react-range-slider-input';
import 'react-range-slider-input/dist/style.css';
import '../index.css';

const AllProducts = () => {
    const [products, setProducts] = useState([]);
    const [productImages, setProductImages] = useState({});
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [priceRange, setPriceRange] = useState([0, 20000]);
    const [selectedShops, setSelectedShops] = useState([]);
    const [sortOption, setSortOption] = useState('');
    const [selectedCategories, setSelectedCategories] = useState([]);
    const [selectedSellers, setSelectedSellers] = useState([]);
    const [selectedBrands, setSelectedBrands] = useState([]);

    const handlePriceRangeChange = (value) => {
        setPriceRange(value);
    };

    const handleSortChange = (e) => {
        setSortOption(e.target.value);
    };

    // ดึงข้อมูลสินค้าจาก API getProductbySeller
    const fetchProductsBySeller = async (sellerId) => {
        try {
            const response = await fetch(`http://localhost:8080/api/v1/products/seller/${sellerId}`);
            const data = await response.json();
            setProducts(data.items);
        } catch (error) {
            console.error('Error fetching products by seller:', error);
        }
    };

    // ดึงข้อมูลสินค้าจาก API getProductbyCate
    const fetchProductsByCategory = async (categoryId) => {
        try {
            const response = await fetch(`http://localhost:8080/api/v1/products/category/${categoryId}`);
            const data = await response.json();
            setProducts(data.items);
        } catch (error) {
            console.error('Error fetching products by category:', error);
        }
    };

    // ดึงข้อมูลรูปภาพของสินค้าจาก API getProductImages
    const fetchProductImages = async (productId) => {
        try {
            const response = await fetch(`http://localhost:8080/api/v1/products/images/${productId}`);
            const data = await response.json();
            
            // ตรวจสอบว่า data.images และ data.images[0] มีค่าหรือไม่
            setProductImages(prevImages => ({
                ...prevImages,
                [productId]: data.images && data.images.length > 0 ? data.images[0]?.image_url : ''
            }));
        } catch (error) {
            console.error('Error fetching product images:', error);
        }
    };

    useEffect(() => {
        // ตัวอย่าง: เรียกข้อมูลสินค้าโดยใช้ category_id = 1
        fetchProductsByCategory(1);
    }, []);

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

    const handleSellerChange = (e) => {
        const seller = e.target.value;
        if (e.target.checked) {
            setSelectedSellers([...selectedSellers, seller]);
        } else {
            setSelectedSellers(selectedSellers.filter(item => item !== seller));
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
        const isInSeller = selectedSellers.length === 0 || selectedSellers.includes(product.sellers[0]?.name);
        const isInBrand = selectedBrands.length === 0 || selectedBrands.includes(product.brand);
        return isInPriceRange && isInCategory && isInSeller && isInBrand;
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
                            ㅤAccessory
                        </label>
                    </div>

                    <h2>Shop</h2>
                    <div className="category-checkbox">
                        <label>
                            <input
                                type="checkbox"
                                value="Atongshopp 玩具"
                                onChange={handleSellerChange}
                            />
                            ㅤATONGS SHOPP 玩具
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="Art Toys"
                                onChange={handleSellerChange}
                            />
                            ㅤART TOYS
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="Gachabox"
                                onChange={handleSellerChange}
                            />
                            ㅤGACHABOX
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="PIECE Of JOY"
                                onChange={handleSellerChange}
                            />
                            ㅤPIECE OF JOY
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="POP MART"
                                onChange={handleSellerChange}
                            />
                            ㅤPOP MART
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
                    <h2>Brand</h2>
                    <div className="category-checkbox">
                        <label>
                            <input
                                type="checkbox"
                                value="52toys"
                                onChange={handleBrandChange}
                            />
                            ㅤ52toys
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="Art Toys"
                                onChange={handleBrandChange}
                            />
                            ㅤArt Toys
                        </label>
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
                                value="BAZBON"
                                onChange={handleBrandChange}
                            />
                            ㅤBAZBON
                        </label>
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
                                value="CRYBABY"
                                onChange={handleBrandChange}
                            />
                            ㅤCRYBABY
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="Disney"
                                onChange={handleBrandChange}
                            />
                            ㅤDisney
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="Duckyo’s"
                                onChange={handleBrandChange}
                            />
                            ㅤDuckyo’s
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
                                value="FORERUNNER"
                                onChange={handleBrandChange}
                            />
                            ㅤFORERUNNER
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="FUFUTIETIE"
                                onChange={handleBrandChange}
                            />
                            ㅤFUFUTIETIE
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
                                value="LABUBU"
                                onChange={handleBrandChange}
                            />
                            ㅤLABUBU
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
                        <label>
                            <input
                                type="checkbox"
                                value="RICO"
                                onChange={handleBrandChange}
                            />
                            ㅤRICO
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
                        <label>
                            <input
                                type="checkbox"
                                value="Sanrio"
                                onChange={handleBrandChange}
                            />
                            ㅤSanrio
                        </label>
                        <label>
                            <input
                                type="checkbox"
                                value="THE MONSTERS"
                                onChange={handleBrandChange}
                            />
                            ㅤTHE MONSTERS
                        </label>
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
                    <h1 className="title">All Products[{filteredProducts.length}]</h1>
                    {filteredProducts.length === 0 && <p>No products found</p>}
                    <div className="product-grid">
                        {filteredProducts.map(product => {
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
                                <div className="card" key={product.product_id}>
                                    <img
                                        src={displayedImageUrl} 
                                        alt={product.name} 
                                        className="product-image" 
                                        onError={(e) => { e.target.src = '/placeholder.jpg'; }} // ใช้ placeholder ถ้าภาพโหลดไม่ได้
                                    />
                                    <div className="container">
                                        <h6 align="left"><b>{product.sellers[0]?.name || "Unknown Shop"}</b></h6>
                                        <h6 align="left"><b>{product.name}</b></h6>
                                        <p align="left"style={{ color: 'red', fontSize: '1.1em' }}>฿{product.price}</p>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                </div>
            </div>

            <Footer />
        </div>
    );
};

export default AllProducts;
