package com.mediqueue.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Queue Model
 * MediQueue | SWE3024 Code Camp
 * Author: Ong Rong Yaw (22061584) - Module 5: Queue Dashboard & Reporting
 */
public class Queue {

    private int queueId;
    private int clinicId;
    private int apptId;
    private int userId;
    private int position;
    private String status; // waiting, in_progress, done, skipped
    private int estimatedWaitMins;
    private Date queueDate;
    private Timestamp calledAt;
    private Timestamp completedAt;
    private Timestamp updatedAt;

    // Joined fields
    private String patientName;
    private String clinicName;
    private String timeSlot;
    private String urgencyLevel;
    private String symptoms;

    public Queue() {}

    // Getters and Setters
    public int getQueueId() { return queueId; }
    public void setQueueId(int queueId) { this.queueId = queueId; }

    public int getClinicId() { return clinicId; }
    public void setClinicId(int clinicId) { this.clinicId = clinicId; }

    public int getApptId() { return apptId; }
    public void setApptId(int apptId) { this.apptId = apptId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getPosition() { return position; }
    public void setPosition(int position) { this.position = position; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getEstimatedWaitMins() { return estimatedWaitMins; }
    public void setEstimatedWaitMins(int estimatedWaitMins) { this.estimatedWaitMins = estimatedWaitMins; }

    public Date getQueueDate() { return queueDate; }
    public void setQueueDate(Date queueDate) { this.queueDate = queueDate; }

    public Timestamp getCalledAt() { return calledAt; }
    public void setCalledAt(Timestamp calledAt) { this.calledAt = calledAt; }

    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getClinicName() { return clinicName; }
    public void setClinicName(String clinicName) { this.clinicName = clinicName; }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

    public String getUrgencyLevel() { return urgencyLevel; }
    public void setUrgencyLevel(String urgencyLevel) { this.urgencyLevel = urgencyLevel; }

    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }

    public String getStatusBadgeClass() {
        switch (status != null ? status : "") {
            case "in_progress": return "badge-primary";
            case "done": return "badge-success";
            case "skipped": return "badge-secondary";
            default: return "badge-warning";
        }
    }

    public String getWaitLabel() {
        if (estimatedWaitMins <= 0) return "Now";
        if (estimatedWaitMins < 30) return estimatedWaitMins + " min";
        int hours = estimatedWaitMins / 60;
        int mins = estimatedWaitMins % 60;
        if (hours > 0) return hours + "h " + mins + "m";
        return estimatedWaitMins + " min";
    }
}
