package com.mediqueue.ai;

/**
 * AIResponse - Structured response object from AI Helper
 * MediQueue | SWE3024 Code Camp
 * Author: Hor Jian Qi (22049860) - Module 3
 */
public class AIResponse {

    private boolean success;
    private boolean fallback;
    private String urgencyLevel;
    private String advice;
    private boolean recommendEr;
    private int estimatedWaitMins;
    private String message;
    private int recommendedClinicId;
    private String recommendedClinicName;
    private String fullText;

    public AIResponse() {
        this.success = false;
        this.fallback = false;
        this.urgencyLevel = "routine";
    }

    // Getters and Setters
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }

    public boolean isFallback() { return fallback; }
    public void setFallback(boolean fallback) { this.fallback = fallback; }

    public String getUrgencyLevel() { return urgencyLevel; }
    public void setUrgencyLevel(String urgencyLevel) { this.urgencyLevel = urgencyLevel; }

    public String getAdvice() { return advice; }
    public void setAdvice(String advice) { this.advice = advice; }

    public boolean isRecommendEr() { return recommendEr; }
    public void setRecommendEr(boolean recommendEr) { this.recommendEr = recommendEr; }

    public int getEstimatedWaitMins() { return estimatedWaitMins; }
    public void setEstimatedWaitMins(int estimatedWaitMins) { this.estimatedWaitMins = estimatedWaitMins; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public int getRecommendedClinicId() { return recommendedClinicId; }
    public void setRecommendedClinicId(int recommendedClinicId) { this.recommendedClinicId = recommendedClinicId; }

    public String getRecommendedClinicName() { return recommendedClinicName; }
    public void setRecommendedClinicName(String recommendedClinicName) { this.recommendedClinicName = recommendedClinicName; }

    public String getFullText() { return fullText; }
    public void setFullText(String fullText) { this.fullText = fullText; }

    public String getUrgencyBadgeClass() {
        switch (urgencyLevel != null ? urgencyLevel : "") {
            case "emergency": return "badge-danger";
            case "urgent": return "badge-warning";
            default: return "badge-success";
        }
    }

    public String getUrgencyLabel() {
        switch (urgencyLevel != null ? urgencyLevel : "") {
            case "emergency": return "EMERGENCY";
            case "urgent": return "URGENT";
            default: return "Routine";
        }
    }
}
