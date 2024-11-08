import React from 'react';
import { Link , useNavigate} from 'react-router-dom';
import { useState } from 'react';
import { FaSearch, FaShoppingCart, FaUser } from 'react-icons/fa';
//import GoogleAuth from './GoogleAuth'

const TopMenu = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const navigate = useNavigate(); // ใช้ในการเปลี่ยนเส้นทาง

  const handleSearchSubmit = (e) => {
    e.preventDefault();
    if (searchTerm) {
      // เปลี่ยนเส้นทางไปที่หน้าผลการค้นหา พร้อม query string
      navigate(`/search?q=${searchTerm}`);
    }
  };

  return (
    <nav className="navbar navbar-expand-lg navbar-dark bg-light p-0">
      <div className="container-fluid">
         {/* Logo ชิดซ้าย */}
         <Link className="navbar-brand" to="/" style={{ color: '#333333' , fontWeight: 'bold'}}>
          <img src="/assets/logo.png" alt="Logo" width="160" height="100"/>
        </Link>
        <button
          className="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#navbarSupportedContent"
          aria-controls="navbarSupportedContent"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span className="navbar-toggler-icon" />
        </button>
        <div className="collapse navbar-collapse" id="navbarSupportedContent" >
          <ul className="navbar-nav">
            <li className="nav-item">
              <Link className="nav-link" to="/category" style={{ color: '#000000', fontWeight: 'bold', fontSize: '14px'}}>
                สินค้าใหม่
              </Link>
            </li>

            <li className="nav-item">
              <Link className="nav-link" to="/category" style={{ color: '#000000', fontWeight: 'bold', fontSize: '14px'}}>
                สินค้าทั้งหมด
              </Link>
            </li>

            <li className="nav-item">
              <Link className="nav-link" to="/category" style={{ color: '#000000', fontWeight: 'bold', fontSize: '14px'}}>
                ร้านค้า
              </Link>
            </li>
          </ul>
        </div>
        <form onSubmit={handleSearchSubmit} className="d-flex flex-grow-1 mx-4">
          <input
            className="form-control me-2 w-100"
            type="search"
            placeholder="ค้นหาสินค้า"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            aria-label="Search"
          />
          <button className="btn btn-outline-success" type="submit">
            <FaSearch />
          </button>
        </form>

        {/* ตะกร้าและผู้ใช้ชิดขวา */}
        <div className="d-flex">
          <Link className="btn btn-light" to="/cart">
            <FaShoppingCart /> <span className="badge bg-danger"></span>
          </Link>
          <Link className="btn btn-light ms-2" to="/user">
            <FaUser />
          </Link>
        </div>
      </div>
    </nav>
  );
};

export default TopMenu;