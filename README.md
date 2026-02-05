## 🗺️ แผนการพัฒนา ISY CRM (Detailed Roadmap)

### **Phase 0: Workspace Setup & Environment (การเตรียมพื้นที่และเครื่องมือ)**

เป้าหมาย: เตรียม Environment ให้พร้อมสำหรับการพัฒนาแบบ Monorepo, Local Dev, และ Production Parity

- **Task 1: Monorepo Structure Initialization**
  - **Step 1:** ตรวจสอบและติดตั้ง Node.js (เวอร์ชัน 24.x LTS) และ pnpm (เวอร์ชัน 10.x) พร้อมตั้งค่า `.nvmrc` เพื่อ lock version ให้ตรงกันทั้งทีม
  - **Step 2:** สร้าง Root Directory และ Initialize `package.json` พร้อมกำหนด `private: true` เพื่อป้องกันการ publish โดยไม่ตั้งใจ
  - **Step 3:** สร้างไฟล์ `pnpm-workspace.yaml` ระบุ scope ของ packages (`client`, `server`, และเผื่อ `shared`)
  - **Step 4:** สร้างโฟลเดอร์ `client`, `server` และ `shared` (สำหรับ type, util ที่ใช้ร่วมกัน)
  - **Step 5:** ตั้งค่า Root-level Script (เช่น `dev`, `build`, `lint`) เพื่อ orchestrate ทั้ง monorepo
- **Task 2: Supabase CLI Integration**
  - **Step 1:** ติดตั้ง Supabase CLI และตรวจสอบเวอร์ชันให้ตรงกับ Production Supabase
  - **Step 2:** Initialize Supabase Project (กำหนด Project Ref, DB password อย่างปลอดภัย)
  - **Step 3:** ตั้งค่า `.env.local` และ `.env.example` สำหรับแยก secret ออกจาก source code
  - **Step 4:** ทดสอบ Start Local Supabase (Postgres, Auth, Storage) และตรวจสอบ Docker health

### **Phase 1: Foundation & Configuration (การวางรากฐาน)**

เป้าหมาย: สร้างโครงสร้างที่ maintainable, secure และรองรับการ scale

- **Task 1: Server Foundation**
  - **Step 1:** Initialize Node.js Project ด้วย TypeScript-first approach
  - **Step 2:** ติดตั้ง Dependencies หลัก: `express`, `cors`, `helmet`, `compression`, `@supabase/supabase-js`
  - **Step 3:** ติดตั้ง Dev Dependencies: `typescript`, `ts-node`, `nodemon`, `tsx`, type definitions
  - **Step 4:** ตั้งค่า `tsconfig.json` ให้รองรับ strict mode, path alias, และ build สำหรับ production
  - **Step 5:** แยก Config ตาม Environment (`development`, `production`, `test`)
- **Task 2: Client Foundation**
  - **Step 1:** สร้าง React Project ด้วย Vite (React + TypeScript)
  - **Step 2:** ติดตั้ง Dependencies หลัก: `axios`, `react-router-dom`, `@tanstack/react-query`
  - **Step 3:** ตั้งค่า Tailwind CSS พร้อม Design Token (สี, spacing, typography)
  - **Step 4:** แยก Environment Variables (`VITE_API_URL`, `VITE_SUPABASE_URL`)
- **Task 3: Code Quality Standards**
  - **Step 1:** ติดตั้ง ESLint, Prettier, และ Config กลางของ Monorepo
  - **Step 2:** เพิ่ม Rules สำหรับ Type Safety, Unused Imports, และ Naming Convention
  - **Step 3:** เพิ่ม Pre-commit Hook ด้วย `lint-staged` และ `husky`

### **Phase 2: Database Architecture (ออกแบบฐานข้อมูล)**

เป้าหมาย: Database ที่ secure, auditable และรองรับ business growth

- **Task 1: Schema Design & Migration**
  - **Step 1:** ออกแบบตาราง `tasks` พร้อม constraints (NOT NULL, CHECK status)
  - **Step 2:** ออกแบบตาราง `profiles` เชื่อม `auth.users` พร้อม unique constraint
  - **Step 3:** เพิ่ม audit columns (`created_at`, `updated_at`, `deleted_at`)
  - **Step 4:** เขียน Trigger Function สำหรับ auto-update timestamp
- **Task 2: Row Level Security (RLS)**
  - **Step 1:** เปิด RLS ทุกตารางที่มี user data
  - **Step 2:** เขียน Policy สำหรับ SELECT / INSERT / UPDATE / DELETE แยกตาม role
  - **Step 3:** ทดสอบ RLS ด้วย anon และ authenticated role
- **Task 3: Type Generation**
  - **Step 1:** Generate TypeScript Types จาก Schema ด้วย Supabase CLI
  - **Step 2:** Sync Types เข้า `shared` package เพื่อให้ Client / Server ใช้ร่วมกัน
  - **Step 3:** ตั้ง CI ตรวจจับ schema drift

### **Phase 3: Backend Development (พัฒนาระบบหลังบ้าน)**

เป้าหมาย: API ที่ปลอดภัย, ทดสอบได้ และสังเกตการณ์ได้

- **Task 1: Core Architecture**
  - **Step 1:** สร้าง Express App ด้วย Layered Architecture (Route → Controller → Service → Repository)
  - **Step 2:** เพิ่ม Centralized Error Handling + Error Code Standard
  - **Step 3:** เพิ่ม Request Validation (Zod / Joi)
  - **Step 4:** เพิ่ม Logging (structured log) และ Correlation ID
- **Task 2: Feature Implementation (Vertical Slice)**
  - **Step 1:** Users Module (Profile read/update + validation)
  - **Step 2:** Tasks Module (CRUD + pagination + filtering)
  - **Step 3:** Enforce Authorization ที่ Service Layer (ไม่พึ่ง RLS อย่างเดียว)
- **Task 3: API Assembly**
  - **Step 1:** Versioning API (`/api/v1`)
  - **Step 2:** เพิ่ม Rate Limit และ Security Headers
  - **Step 3:** เขียน Integration Test สำหรับ Critical API

### **Phase 4: Frontend Development (พัฒนาระบบหน้าบ้าน)**

เป้าหมาย: UX ดี, State ชัดเจน, และ error-handling ครบ

- **Task 1: Client Core Logic**
  - **Step 1:** Axios Instance + Refresh Token Strategy
  - **Step 2:** Auth Context + Persist Session
  - **Step 3:** Protected Route + Role-based Guard
- **Task 2: UI Implementation**
  - **Step 1:** Layout Component ที่ Responsive
  - **Step 2:** Auth Pages พร้อม Form Validation
  - **Step 3:** TaskBoard รองรับ optimistic update
  - **Step 4:** Profile Page พร้อม error / loading state
- **Task 3: Routing & Integration**
  - **Step 1:** Centralized Route Definition
  - **Step 2:** Global Error Boundary

### **Phase 5: Deployment (การนำขึ้นใช้งานจริง)**

เป้าหมาย: Deploy ได้อย่างมั่นใจ และดูแลระยะยาวได้

- **Task 1: Serverless Adaptation**
  - **Step 1:** Refactor Backend ให้ stateless และ cold-start friendly
  - **Step 2:** ตั้งค่า `vercel.json` (rewrite, cache, region)
- **Task 2: Final Check & Deploy**
  - **Step 1:** ตั้งค่า Environment Variables และ Secrets อย่างปลอดภัย
  - **Step 2:** ตั้ง Monitoring (Logs, Error Tracking)
  - **Step 3:** Smoke Test หลัง Deploy
