package com.mediqueue.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Appointment Model
 * MediQueue | SWE3024 Code Camp
 * Author: Si Thu Lin Khant (22042642) - Module 2: Appointment Booking
 */
public class Appointment {

    private int apptId;
    private int userId;
    private int clinicId;
    private Date apptDate;
    private String timeSlot;
    private String reason;
    private String symptoms;
    private String status; // pending, confirmed, cancelled, completed
    private String urgencyLevel; // routine, urgent, emergency
    private String aiNotes;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Joined fields
    private String patientName;
    private String clinicName;
    private String clinicAddress;

    public Appointment() {}

    // Getters and Setters
    public int getApptId() { return apptId; }
    public void setApptId(int apptId) { this.apptId = apptId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getClinicId() { return clinicId; }
    public void setClinicId(int clinicId) { this.clinicId = clinicId; }

    public Date getApptDate() { return apptDate; }
    public void setApptDate(Date apptDate) { this.apptDate = apptDate; }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getUrgencyLevel() { return urgencyLevel; }
    public void setUrgencyLevel(String urgencyLevel) { this.urgencyLevel = urgencyLevel; }

    public String getAiNotes() { return aiNotes; }
    public void setAiNotes(String aiNotes) { this.aiNotes = aiNotes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getClinicName() { return clinicName; }
    public void setClinicName(String clinicName) { this.clinicName = clinicName; }

    public String getClinicAddress() { return clinicAddress; }
    public void setClinicAddress(String clinicAddress) { this.clinicAddress = clinicAddress; }

    public String getStatusBadgeClass() {
        switch (status != null ? status : "") {
            case "confirmed": return "badge-success";
            case "pending": return "badge-warning";
            case "cancelled": return "badge-danger";
            case "completed": return "badge-info";
            default: return "badge-secondary";
        }
    }

    public String getUrgencyBadgeClass() {
        switch (urgencyLevel != null ? urgencyLevel : "") {
            case "emergency": return "badge-danger";
            case "urgent": return "badge-warning";
            default: return "badge-success";
        }
    }
}
