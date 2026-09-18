
# 🏢 Enterprise Employee Management App (Enterprise HR Hub)

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/Riverpod%20%26%20BLoC-Blue?style=for-the-badge&logo=flutter)](https://riverpod.dev)
[![Backend](https://img.shields.io/badge/Firebase-Firestore%20%26%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

A modern, full-featured, cross-platform **Enterprise Employee & HR Management System** built with **Flutter**, **Riverpod & BLoC state management**, and **Firebase**. Designed for enterprises, HR teams, and employees to streamline personnel operations, attendance tracking, leave requests, role-based access control, document management, and real-time notifications.

---

****Key Features
 **1. Executive Dashboard & Analytics**
* Real-time metrics for total workforce, daily attendance rates, employees on leave, and pending approval queues.
* Interactive visual breakdown by department, attendance status, and leave distribution.
* Quick action shortcuts tailored to user roles (Clock In/Out, Request Leave, Add Employee, Send Announcements).
**
** 2. Employee Directory & Profile Management****
* **Comprehensive Records**: View, search, and filter employees by department, designation, and employment status.
* **Employee Profiles**: Detailed profile views including contact info, role, date of joining, salary details, manager info, and emergency contacts.
* **Document Locker**: Upload, view, and manage employee documents (contracts, certificates, IDs) powered by Firebase Storage.
* **CRUD Operations**: Admin/HR authorization to recruit, update, or deactivate employee records seamlessly.

** 3. Attendance Tracking System**
* One-tap **Clock-In** and **Clock-Out** functionality with time logging and status markers (Present, Late, Half-Day, Absent).
* Interactive attendance history calendar & log breakdown.
* Managerial view to monitor department-wide daily attendance.

4. Leave Request & Approval Management
* Submit leave applications with leave types (Casual, Sick, Earned, Unpaid), custom date ranges, and reason notes.
* Real-time status tracking (Pending, Approved, Rejected) with administrative response notes.
* HR & Manager approval workflow to approve or reject employee leave requests with automated status synchronization.

### 5. Role-Based Access Control (RBAC) & Security
* Multi-tiered authorization system supporting **Admin**, **HR Manager**, **Team Lead**, and **Employee** roles.
* Dynamic navigation guarding and restricted access to administrative screens (e.g., Role Management, Employee Onboarding, Notification Dispatch).
* Role Management panel allowing Admins to modify user roles and permissions on the fly.

###  6. Notifications & Broadcast Center
* In-app notification center for instant alerts regarding leave approvals, system updates, and announcements.
* Admin capability to broadcast announcements to specific departments or the entire enterprise.

### 7. Adaptive UI & Dual Backend Architecture
* **Dark & Light Mode**: Smooth theme toggling powered by Riverpod and persistent system preferences.
* **Responsive Design**: Adaptive navigation supporting Bottom Navigation Bar on mobile devices and expandable `NavigationRail` on tablet/desktop views.
* **Dual Backend Toggle**: Seamlessly switch between a zero-config **Local Mock Data Engine** (ideal for testing/demos) and **Firebase Cloud Services** (Firestore + Auth + Storage) from the Settings menu.
  
