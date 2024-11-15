import React, { useState } from 'react';

const Sorting = ({ sortOption, onSortChange }) => {
    const [hover, setHover] = useState(false);

    const styles = {
        container: {
            maxWidth: '16em',
            display: 'flex',
            flexDirection: 'column',
        },
        label: {
            marginBottom: '8px',
            fontWeight: 'bold',
            color: '#000000',
            marginRight: '190px' /* เพิ่ม margin-left เพื่อขยับไปทางซ้าย */
        },
        selectWrapper: {
            position: 'relative',
            width: '100%',
        },
        select: {
            width: '100%',
            padding: '4px 15px',
            fontSize: '16px',
            fontWeight: '400',
            color: '#000000',
            border: '3px solid #E6E6E6',
            borderRadius: '0',
            outline: 'none',
            appearance: 'none',
            transition: 'border-color 0.2s ease, outline 0.2s ease',
        },
        selectHover: {
            borderColor: '#000000',
        },
        arrowTop: {
            content: '""',
            position: 'absolute',
            pointerEvents: 'none',
            right: '16px',
            bottom: '55%',
            border: '8px solid transparent',
            borderBottomColor: hover ? '#000000' : '#D6D6D6', // เปลี่ยนสีตาม hover
        },
        arrowBottom: {
            content: '""',
            position: 'absolute',
            pointerEvents: 'none',
            right: '16px',
            top: '55%',
            border: '8px solid transparent',
            borderTopColor: hover ? '#000000' : '#D6D6D6', // เปลี่ยนสีตาม hover
        },
        sortcontainercenter: {
            display: 'flex',
            justifycontent: 'center',  /* จัดตำแหน่งให้อยู่ตรงกลางในแนวนอน */
            alignitems: 'center',     /* จัดตำแหน่งให้อยู่ตรงกลางในแนวตั้ง (ถ้าจำเป็น) */
            marginbottom: '30px',    /* เพิ่มระยะห่างด้านล่าง */
        }
    };

    return (
        <div style={styles.container}>
            <label style={styles.label}>Sort by:</label>
            <div
                className="form-input-select"
                style={styles.selectWrapper}
                onMouseEnter={() => setHover(true)} // เมื่อเมาส์เข้ามา
                onMouseLeave={() => setHover(false)} // เมื่อเมาส์ออก
            >
                <span style={styles.arrowTop}></span>
                <span style={styles.arrowBottom}></span>
                <select
                    onChange={onSortChange}
                    value={sortOption}
                    style={styles.select}
                >
                    <option value="">None</option>
                    <option value="price-asc">Price: Low to High</option>
                    <option value="price-desc">Price: High to Low</option>
                    <option value="name-asc">Name: A-Z</option>
                    <option value="name-desc">Name: Z-A</option>
                </select>
            </div>
        </div>
    );
};

export default Sorting;