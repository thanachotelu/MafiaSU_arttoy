# Project Backend-Frontend

### e-commerce web-application with React and Golang

---

## Requirements

ติดตั้งสิ่งเหล่านี้ก่อน:

- [Git](https://git-scm.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Node.js](https://nodejs.org/) (v18+)

---

## Getting Started

### 1. Clone โปรเจค

```bash
git clone https://github.com/thanachotelu/MafiaSU_arttoy.git
cd MafiaSU_arttoy
```

---

### 2. ตั้งค่า Environment

เข้าไปที่ `backend-database/.env` แล้วแก้แค่บรรทัดนี้:

```env
POSTGRES_HOST=mafiatoys_postgres
```

---

### 3. รัน Backend + Database

เปิด **Docker Desktop** ให้รันอยู่ก่อน จากนั้น:

```bash
cd backend-database
docker-compose build
docker-compose up
```

รอจนขึ้น log ว่า server พร้อม ใช้เวลาประมาณ 1-2 นาทีครั้งแรก

---

### 4. ตรวจสอบ Database (ครั้งแรกเท่านั้น)

เปิดเบราว์เซอร์ไปที่ `http://localhost:5000`

| Field | ค่า |
|---|---|
| Email | ตามที่ตั้งใน `.env` |
| Password | ตามที่ตั้งใน `.env` |

เพิ่ม Server ใน pgAdmin:
- Host: `mafiatoys_postgres`
- Port: `5432`
- Database: `mafiatoys`
- Username: `mafiatoys_user`
- Password: `mafiasu`

---

### 5. รัน Frontend

เปิด **terminal ใหม่** (อย่าปิด terminal ที่รัน Docker):

```bash
cd frontend/mafiatoys-app
npm install
npm start
```

เว็บจะเปิดที่ `http://localhost:4000` ครับ

---

## โครงสร้างโปรเจค

```
MafiaSU_arttoy/
├── backend-database/       # Go API + Docker
│   ├── .env                # Environment variables
│   ├── docker-compose.yml  # Docker config
│   ├── cmd/main.go         # Entry point
│   ├── internal/
│   │   ├── handler/        # API handlers
│   │   ├── service/        # Business logic
│   │   ├── repository/     # Database queries
│   │   └── model/          # Data models
│   └── docker/
│       └── init.sql        # Database schema
└── frontend/
    └── mafiatoys-app/      # React app
        ├── src/
        │   ├── components/ # Reusable components
        │   ├── pages/      # Page components
        │   └── context/    # React context
        └── public/
            └── assets/     # Images
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React (Create React App) |
| Backend | Go + Gin Framework |
| Database | PostgreSQL |
| DevOps | Docker + Docker Compose |
| Auth | Google OAuth + JWT |

---

## Port Summary

| Service | URL |
|---|---|
| Frontend | http://localhost:4000 |
| Backend API | http://localhost:8080 |
| pgAdmin | http://localhost:5000 |
| PostgreSQL | localhost:5432 |

---

## ทุกครั้งที่จะเปิดโปรเจค

```bash
# Terminal 1 — Backend
cd backend-database
docker-compose up

# Terminal 2 — Frontend
cd frontend/mafiatoys-app
npm start
```
