import React from 'react';

const BannerShop = ({ storeName , backgroundColor , banner_img1 , banner_img2 , banner_img3 , width_img2 , height_img2 , width_img3 , height_img3 }) => {
  return (
    <div>

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
        backgroundColor: backgroundColor,
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
          <p>🚨 Welcome to {storeName}! 🚨 Check out our latest art toys and limited edition figures! 🛍️</p>
        </div>
      </div>

      {/* รูปภาพโฆษณาต่อจากป้ายโฆษณา */}

      <div style={{
        marginBottom: '20px',
        textAlign: 'center'
      }}>
        <img
          src= {banner_img1}
          alt="Advertisement"
          style={{
            width: '99%',
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
          src= {banner_img2}
          alt="Advertisement"
          style={{
            width: width_img2, // กำหนดให้รูปภาพขยายเต็มความกว้าง
            // maxWidth: '1200px', // จำกัดขนาดความกว้างสูงสุด
            height: height_img2,
            borderRadius: '10px',
            boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
            margin: '0 auto' // จัดกลาง
          }}
        />

        <img
          src={banner_img3}
          alt="Advertisement"
          style={{
            width: width_img3,
            // maxWidth: '1200px', // จำกัดขนาดความกว้างสูงสุด
            height: height_img3,
            borderRadius: '10px',
            boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
            margin: '0 auto' // จัดกลาง
          }}
        />
      </div>

    </div>


  );
};

export default BannerShop;

