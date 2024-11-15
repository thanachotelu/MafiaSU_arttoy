import React from 'react';
import TopMenu from '../components/TopMenu'; // ส่วนแสดงเมนูด้านบน
import BannerCarousel from '../components/BannerCarousel'; // ส่วนแสดง Banner
import RecommendProducts from '../components/RecommendProducts'; // ส่วนแสดงสินค้าแนะนำ
import NewProduct from '../components/NewProduct'; // ส่วนแสดงสินค้ามาใหม่
import Footer from '../components/Footer'; // ส่วนแสดง Footer

const Home = () => {
  return (
    <div>
      <TopMenu />
      <BannerCarousel />
      <RecommendProducts /> {/* แสดงสินค้ามาใหม่ */}
      <NewProduct/>
      <Footer />
    </div>
  );
};

export default Home;
