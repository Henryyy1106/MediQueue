package com.mediqueue.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * User Model
 * MediQueue | SWE3024 Code Camp
 * Author: Tam Lik Herng (23093024) - Module 1: User Auth & Profile
 */
public class User {

    private int userId;
    private String name;
    private String email;
    private String passwordHash;
    private String role; // "patient" or "admin"
    private String phone;
    private String icNumber;
    private Date dateOfBirth;
    private String gender;
    private String address;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public User() {}

    public User(String name, String email, String passwordHash, String role, String phone) {
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.phone = phone;
    }

    // Getters and Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getIcNumber() { return icNumber; }
    public void setIcNumber(String icNumber) { this.icNumber = icNumber; }

    public Date getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(Date dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public boolean isAdmin() { return "admin".equals(this.role); }
    public boolean isPatient() { return "patient".equals(this.role); }

    @Override
    public String toString() {
        return "User{userId=" + userId + ", name='" + name + "', email='" + email + "', role='" + role + "'}";
    }
}
