import React, { useState , useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { FaSearch, FaShoppingCart, FaUser } from 'react-icons/fa';
import { Button, Modal, Dropdown } from 'react-bootstrap'; // เพิ่ม Dropdown จาก react-bootstrap
import GoogleAuth from './GoogleAuth';

const TopMenu = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [showLogin, setShowLogin] = useState(false);
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [dropdownOpen, setDropdownOpen] = useState(false);

  useEffect(() => {
    // ดึงข้อมูลผู้ใช้จาก sessionStorage เมื่อหน้าเว็บถูกโหลดหรือรีเฟรช
    const storedUser = sessionStorage.getItem('user');
    if (storedUser) {
      setUser(JSON.parse(storedUser)); // กำหนดข้อมูลผู้ใช้ใน state
    }
  }, []);

  const handleSearchSubmit = (e) => {
    e.preventDefault();
    if (searchTerm) {
      navigate(`/search?q=${searchTerm}`);
    }
  };

  const toggleDropdown = () => {
    setDropdownOpen(!dropdownOpen);
  };

  const handleShow = () => setShowLogin(true);
  const handleClose = () => setShowLogin(false);

  const handleLogout = () => {
    // ลบข้อมูลผู้ใช้จาก sessionStorage
    sessionStorage.removeItem('user');
    setUser(null); // รีเซ็ต state
    navigate('/'); // เปลี่ยนเส้นทางกลับไปที่หน้าหลัก
  };

  return (
    <nav className="navbar navbar-expand-lg navbar-dark bg-light p-0">
      <div className="container-fluid">
        <Link className="navbar-brand" to="/" style={{ color: '#333333', fontWeight: 'bold' }}>
          <img src="/assets/toys_logo.png" alt="Logo" width="120" height="90" />
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
        
        <div className="collapse navbar-collapse" id="navbarSupportedContent">
          <ul className="navbar-nav">
            <li className="nav-item">
              <Link className="nav-link" to="/new" style={{ color: '#000000', fontWeight: 'bold', fontSize: '14px' }}>
                ใหม่&แนะนำ
              </Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link" to="/allproduct" style={{ color: '#000000', fontWeight: 'bold', fontSize: '14px' }}>
                สินค้าทั้งหมด
              </Link>
            </li>
            
            {/* Dropdown for ร้านค้า */}
            <li className="nav-item dropdown" onMouseEnter={toggleDropdown} onMouseLeave={toggleDropdown}>
              <span className="nav-link" style={{ color: '#000000', fontWeight: 'bold', fontSize: '14px', cursor: 'pointer' }}>
                SHOP
              </span>
              {dropdownOpen && (
                <div
                className="dropdown-menu show"
                style={{
                  position: 'absolute',
                  top: '100%',
                  left: '0',
                  backgroundColor: 'white',
                  boxShadow: '0 4px 8px rgba(0, 0, 0, 0.1)',
                  borderRadius: '4px',
                  padding: '10px 0',
                  display: dropdownOpen ? 'block' : 'none',
                }}
              >
                  <Link className="dropdown-item" to="/store-1" style={{ display: 'flex', alignItems: 'center', padding: '8px 20px', color: '#000' ,fontWeight: 'bold'}}>
                    <img src="/assets/images/logo_images_Atongshopp.png" alt="Atongshopp" width="30" height="30" style={{ marginRight: '10px' }} />
                    ATONG SHOPP 玩具
                  </Link>

                  <Link className="dropdown-item" to="/store-1" style={{ display: 'flex', alignItems: 'center', padding: '8px 20px', color: '#000' ,fontWeight: 'bold'}}>
                    <img src="/assets/images/logo_images_arttoys.png" alt="Arttoys" width="30" height="30" style={{ marginRight: '10px' }} />
                    ART TOYS
                  </Link>

                  <Link className="dropdown-item" to="/store-1" style={{ display: 'flex', alignItems: 'center', padding: '8px 20px', color: '#000' ,fontWeight: 'bold'}}>
                    <img src="/assets/images/logo_images_gachabox.png" alt="Arttoys" width="30" height="30" style={{ marginRight: '10px' }} />
                    GACHABOX
                  </Link>

                  <Link className="dropdown-item" to="/store-1" style={{ display: 'flex', alignItems: 'center', padding: '8px 20px', color: '#000' ,fontWeight: 'bold'}}>
                    <img src="/assets/images/logo_images_popmart.png" alt="Arttoys" width="30" height="30" style={{ marginRight: '10px' }} />
                    POP MART
                  </Link>

                  <Link className="dropdown-item" to="/store-1" style={{ display: 'flex', alignItems: 'center', padding: '8px 20px', color: '#000' ,fontWeight: 'bold'}}>
                    <img src="/assets/images/logo_images_pieceofjoy.png" alt="Arttoys" width="30" height="30" style={{ marginRight: '10px' }} />
                    PIECE OF JOY
                  </Link>
                </div>
                
              )}
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

        <div className="d-flex">
          <Link className="btn btn-light" to="/cart">
            <FaShoppingCart /> <span className="badge bg-danger"></span>
          </Link>


          {user ? (
            <Dropdown>
              <Dropdown.Toggle variant="light" id="dropdown-basic" className="d-flex align-items-center">
                <img
                  src={user.picture} // รูปภาพจาก Google
                  alt="user-profile"
                  style={{ borderRadius: '50%', width: '40px' }}
                  referrerPolicy="no-referrer"
                />
              </Dropdown.Toggle>

              <Dropdown.Menu>
                <Dropdown.Item as={Link} to="/profile">My Profile</Dropdown.Item>
                <Dropdown.Item onClick={handleLogout}>Logout</Dropdown.Item>
              </Dropdown.Menu>
            </Dropdown>
          ) : (
            <Button variant="light" className="ms-2" onClick={handleShow}>
              <FaUser /> เข้าสู่ระบบ
            </Button>
          )}

          
        </div>
      </div>

        {/* Modal สำหรับเข้าสู่ระบบ */}
        <Modal show={showLogin} onHide={handleClose} centered>
          <Modal.Header closeButton>
            <Modal.Title>เข้าสู่ระบบ</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <GoogleAuth
              setUser={(user) => {
                setUser(user);
                sessionStorage.setItem('user', JSON.stringify(user)); // เก็บข้อมูลผู้ใช้ใน sessionStorage
              }}
              handleClose={handleClose}
            />
          </Modal.Body>
        </Modal>
    </nav>
  );
};

export default TopMenu;
