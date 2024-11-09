import React from 'react';
import TopMenu from '../components/TopMenu'; // ส่วนแสดงเมนูด้านบน
import BannerCarousel from '../components/BannerCarousel'; // ส่วนแสดง Banner
import NewProducts from '../components/NewProducts'; // ส่วนแสดงสินค้ามาใหม่
import Footer from '../components/Footer'; // ส่วนแสดง Footer

const Home = () => {
  return (
    <div>
      <TopMenu />
      <BannerCarousel />
      <NewProducts /> {/* แสดงสินค้ามาใหม่ */}
      <Footer />
    </div>
  );
};

export default Home;
