package com.mediqueue.model;

import java.sql.Timestamp;

/**
 * Clinic Model
 * MediQueue | SWE3024 Code Camp
 */
public class Clinic {

    private int clinicId;
    private String name;
    private String address;
    private String district;
    private String state;
    private String phone;
    private String operatingHours;
    private int capacity;
    private double rating;
    private int ratingCount;
    private double latitude;
    private double longitude;
    private boolean isActive;
    private Timestamp createdAt;

    // Runtime fields (not in DB, populated by DAO)
    private int currentQueueCount;
    private int estimatedWaitMins;

    public Clinic() {}

    // Getters and Setters
    public int getClinicId() { return clinicId; }
    public void setClinicId(int clinicId) { this.clinicId = clinicId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getOperatingHours() { return operatingHours; }
    public void setOperatingHours(String operatingHours) { this.operatingHours = operatingHours; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public int getRatingCount() { return ratingCount; }
    public void setRatingCount(int ratingCount) { this.ratingCount = ratingCount; }

    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }

    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getCurrentQueueCount() { return currentQueueCount; }
    public void setCurrentQueueCount(int currentQueueCount) { this.currentQueueCount = currentQueueCount; }

    public int getEstimatedWaitMins() { return estimatedWaitMins; }
    public void setEstimatedWaitMins(int estimatedWaitMins) { this.estimatedWaitMins = estimatedWaitMins; }

    public String getWaitLabel() {
        if (estimatedWaitMins < 20) return "Short Wait";
        if (estimatedWaitMins < 45) return "Moderate Wait";
        return "Long Wait";
    }

    public String getWaitBadgeClass() {
        if (estimatedWaitMins < 20) return "badge-success";
        if (estimatedWaitMins < 45) return "badge-warning";
        return "badge-danger";
    }

    public boolean hasRating() {
        return ratingCount > 0;
    }

    public String getRatingLabel() {
        if (ratingCount <= 0) return "No ratings yet";
        return String.format("%.1f", rating) + " (" + ratingCount + ")";
    }
}
