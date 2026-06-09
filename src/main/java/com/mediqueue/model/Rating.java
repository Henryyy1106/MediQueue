package com.mediqueue.model;

import java.sql.Timestamp;

/**
 * Rating Model - a patient's star rating of a clinic for a completed visit
 * MediQueue | SWE3024 Code Camp
 */
public class Rating {

    private int ratingId;
    private int userId;
    private int clinicId;
    private int apptId;
    private int stars; // 1 to 5
    private String comment;
    private Timestamp createdAt;

    // Joined fields
    private String clinicName;
    private String patientName;

    public Rating() {}

    public int getRatingId() { return ratingId; }
    public void setRatingId(int ratingId) { this.ratingId = ratingId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getClinicId() { return clinicId; }
    public void setClinicId(int clinicId) { this.clinicId = clinicId; }

    public int getApptId() { return apptId; }
    public void setApptId(int apptId) { this.apptId = apptId; }

    public int getStars() { return stars; }
    public void setStars(int stars) { this.stars = stars; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getClinicName() { return clinicName; }
    public void setClinicName(String clinicName) { this.clinicName = clinicName; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
}
