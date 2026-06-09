package com.mediqueue.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * VisitHistory Model
 * MediQueue | SWE3024 Code Camp
 */
public class VisitHistory {

    private int visitId;
    private int userId;
    private int clinicId;
    private int apptId;
    private Date visitDate;
    private int actualWaitMins;
    private String outcome;
    private String doctorNotes;
    private String aiSummary;
    private Timestamp createdAt;

    // Joined fields
    private String clinicName;
    private String patientName;
    private String timeSlot;
    private int userRating; // this user's star rating for this visit (0 = not rated)

    public VisitHistory() {}

    public int getVisitId() { return visitId; }
    public void setVisitId(int visitId) { this.visitId = visitId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getClinicId() { return clinicId; }
    public void setClinicId(int clinicId) { this.clinicId = clinicId; }

    public int getApptId() { return apptId; }
    public void setApptId(int apptId) { this.apptId = apptId; }

    public Date getVisitDate() { return visitDate; }
    public void setVisitDate(Date visitDate) { this.visitDate = visitDate; }

    public int getActualWaitMins() { return actualWaitMins; }
    public void setActualWaitMins(int actualWaitMins) { this.actualWaitMins = actualWaitMins; }

    public String getOutcome() { return outcome; }
    public void setOutcome(String outcome) { this.outcome = outcome; }

    public String getDoctorNotes() { return doctorNotes; }
    public void setDoctorNotes(String doctorNotes) { this.doctorNotes = doctorNotes; }

    public String getAiSummary() { return aiSummary; }
    public void setAiSummary(String aiSummary) { this.aiSummary = aiSummary; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getClinicName() { return clinicName; }
    public void setClinicName(String clinicName) { this.clinicName = clinicName; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

    public int getUserRating() { return userRating; }
    public void setUserRating(int userRating) { this.userRating = userRating; }
}
