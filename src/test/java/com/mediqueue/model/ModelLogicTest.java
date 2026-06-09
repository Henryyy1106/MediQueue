package com.mediqueue.model;

import com.mediqueue.ai.AIResponse;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/** Unit tests for the pure presentation logic on the model classes. */
class ModelLogicTest {

    @Test
    void clinicRatingLabelReflectsCount() {
        Clinic c = new Clinic();
        assertEquals("No ratings yet", c.getRatingLabel());
        assertFalse(c.hasRating());

        c.setRating(4.0);
        c.setRatingCount(3);
        assertTrue(c.hasRating());
        assertEquals("4.0 (3)", c.getRatingLabel());
    }

    @Test
    void clinicWaitBadgeBuckets() {
        Clinic c = new Clinic();
        c.setEstimatedWaitMins(10);
        assertEquals("badge-success", c.getWaitBadgeClass());
        c.setEstimatedWaitMins(30);
        assertEquals("badge-warning", c.getWaitBadgeClass());
        c.setEstimatedWaitMins(60);
        assertEquals("badge-danger", c.getWaitBadgeClass());
    }

    @Test
    void queueWaitLabelFormatsMinutesAndHours() {
        Queue q = new Queue();
        q.setEstimatedWaitMins(0);
        assertEquals("Now", q.getWaitLabel());
        q.setEstimatedWaitMins(15);
        assertEquals("15 min", q.getWaitLabel());
        q.setEstimatedWaitMins(90);
        assertEquals("1h 30m", q.getWaitLabel());
    }

    @Test
    void aiResponseUrgencyMapping() {
        AIResponse r = new AIResponse();
        r.setUrgencyLevel("emergency");
        assertEquals("badge-danger", r.getUrgencyBadgeClass());
        assertEquals("EMERGENCY", r.getUrgencyLabel());

        r.setUrgencyLevel("routine");
        assertEquals("badge-success", r.getUrgencyBadgeClass());
        assertEquals("Routine", r.getUrgencyLabel());
    }
}
