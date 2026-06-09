-- MediQueue Database Schema
-- SWE3024 Code Camp | Sunway University
-- Created by: Tam Lik Herng, Si Thu Lin Khant, Hor Jian Qi, Ong Rong Yaw

CREATE DATABASE IF NOT EXISTS mediqueue;
USE mediqueue;

-- Users table (Module 1 - Tam Lik Herng)
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('patient', 'admin') DEFAULT 'patient',
    phone VARCHAR(20),
    ic_number VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other'),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Clinics table
CREATE TABLE IF NOT EXISTS clinics (
    clinic_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    district VARCHAR(100),
    state VARCHAR(100) DEFAULT 'Selangor',
    phone VARCHAR(20),
    operating_hours VARCHAR(100) DEFAULT '8:00 AM - 5:00 PM',
    capacity INT DEFAULT 100,
    rating DECIMAL(2, 1) DEFAULT 0,
    rating_count INT DEFAULT 0,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Appointments table (Module 2 - Si Thu Lin Khant)
CREATE TABLE IF NOT EXISTS appointments (
    appt_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    clinic_id INT NOT NULL,
    appt_date DATE NOT NULL,
    time_slot VARCHAR(20) NOT NULL,
    reason TEXT,
    symptoms TEXT,
    status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    urgency_level ENUM('routine', 'urgent', 'emergency') DEFAULT 'routine',
    ai_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id) ON DELETE CASCADE
);

-- Queue table (Module 5 - Ong Rong Yaw)
CREATE TABLE IF NOT EXISTS queue (
    queue_id INT AUTO_INCREMENT PRIMARY KEY,
    clinic_id INT NOT NULL,
    appt_id INT NOT NULL,
    user_id INT NOT NULL,
    position INT NOT NULL,
    status ENUM('waiting', 'in_progress', 'done', 'skipped') DEFAULT 'waiting',
    estimated_wait_mins INT DEFAULT 0,
    queue_date DATE NOT NULL,
    called_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id),
    FOREIGN KEY (appt_id) REFERENCES appointments(appt_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Visit history table
CREATE TABLE IF NOT EXISTS visit_history (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    clinic_id INT NOT NULL,
    appt_id INT,
    visit_date DATE NOT NULL,
    actual_wait_mins INT DEFAULT 0,
    outcome TEXT,
    doctor_notes TEXT,
    ai_summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id),
    FOREIGN KEY (appt_id) REFERENCES appointments(appt_id)
);

-- Clinic ratings table (patients rate completed visits)
CREATE TABLE IF NOT EXISTS clinic_ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    clinic_id INT NOT NULL,
    appt_id INT,
    stars TINYINT NOT NULL COMMENT '1 to 5',
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id) ON DELETE CASCADE,
    FOREIGN KEY (appt_id) REFERENCES appointments(appt_id) ON DELETE CASCADE,
    UNIQUE KEY unique_rating (user_id, appt_id)
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    notif_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('appointment', 'queue', 'system') DEFAULT 'system',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Clinic stats table (for AI predictions)
CREATE TABLE IF NOT EXISTS clinic_stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    clinic_id INT NOT NULL,
    stat_date DATE NOT NULL,
    hour_slot INT NOT NULL COMMENT '8=8AM, 9=9AM, etc',
    avg_wait_mins INT DEFAULT 30,
    patient_count INT DEFAULT 0,
    FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id),
    UNIQUE KEY unique_stat (clinic_id, stat_date, hour_slot)
);

-- Sample users use BCrypt hashes to match PasswordUtil (passwords: admin123 / patient123)
INSERT INTO users (name, email, password_hash, role, phone) VALUES
('Admin MediQueue', 'admin@mediqueue.my', '$2a$12$HpARNHov7gKWUN6391vdqerhm0kiZr42fAtTmmpJIviqd7QDLHSey', 'admin', '03-12345678'),
('Tam Lik Herng', 'lik@mediqueue.my', '$2a$12$vlheWfmCUu5ERSdkrKnRN.dQxHzXvvBYmCZfRmgK6KCJDDX3lDQWG', 'patient', '012-3456789'),
('Test Patient', 'patient@mediqueue.my', '$2a$12$vlheWfmCUu5ERSdkrKnRN.dQxHzXvvBYmCZfRmgK6KCJDDX3lDQWG', 'patient', '011-9876543')
ON DUPLICATE KEY UPDATE
password_hash = VALUES(password_hash),
role = VALUES(role),
phone = VALUES(phone);

-- Sample clinics (Klang Valley area)
INSERT INTO clinics (name, address, district, phone, capacity, latitude, longitude) VALUES
('Klinik Kesihatan Taman Jaya', 'Jalan Taman Jaya, 46000 Petaling Jaya', 'Petaling Jaya', '03-79572345', 120, 3.1073, 101.6345),
('Klinik Kesihatan SS2', 'Jalan SS2/66, 47300 Petaling Jaya', 'Petaling Jaya', '03-78763456', 100, 3.1175, 101.6197),
('Klinik Kesihatan Kelana Jaya', 'Jalan SS7/2, 47301 Petaling Jaya', 'Subang Jaya', '03-78069876', 90, 3.1073, 101.5936),
('Klinik Kesihatan Subang Jaya', 'Persiaran Kemajuan, 47500 Subang Jaya', 'Subang Jaya', '03-56312345', 110, 3.0506, 101.5782),
('Klinik Kesihatan Shah Alam', 'Jalan Tengku Ampuan Zabedah E 9/E, 40100 Shah Alam', 'Shah Alam', '03-55116789', 150, 3.0738, 101.5183);

-- Sample clinic stats (average wait times by hour)
INSERT INTO clinic_stats (clinic_id, stat_date, hour_slot, avg_wait_mins, patient_count) VALUES
(1, CURDATE(), 8, 25, 15), (1, CURDATE(), 9, 45, 28), (1, CURDATE(), 10, 55, 35),
(1, CURDATE(), 11, 60, 38), (1, CURDATE(), 12, 40, 22), (1, CURDATE(), 14, 35, 20),
(1, CURDATE(), 15, 50, 30), (1, CURDATE(), 16, 30, 18),
(2, CURDATE(), 8, 30, 18), (2, CURDATE(), 9, 50, 32), (2, CURDATE(), 10, 65, 40),
(2, CURDATE(), 11, 70, 42), (2, CURDATE(), 12, 45, 25), (2, CURDATE(), 14, 40, 22),
(3, CURDATE(), 8, 20, 12), (3, CURDATE(), 9, 35, 22), (3, CURDATE(), 10, 45, 28),
(4, CURDATE(), 8, 28, 16), (4, CURDATE(), 9, 42, 26), (4, CURDATE(), 10, 52, 33),
(5, CURDATE(), 8, 22, 14), (5, CURDATE(), 9, 38, 24), (5, CURDATE(), 10, 48, 30);
