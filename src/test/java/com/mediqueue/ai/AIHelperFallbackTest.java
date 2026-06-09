package com.mediqueue.ai;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assumptions.assumeTrue;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests the offline fallback behaviour of AIHelper (no Claude API key set).
 * These assert the safety guarantees that must hold without any network call.
 */
class AIHelperFallbackTest {

    private static final String DISCLAIMER =
            "This is general guidance only — see the doctor at your appointment.";

    private boolean noApiKey() {
        String k = System.getenv("CLAUDE_API_KEY");
        return k == null || k.isEmpty();
    }

    @Test
    void careTipsFallbackIsSafeAndDisclaimed() {
        assumeTrue(noApiKey(), "skipped: CLAUDE_API_KEY is set, would hit the live API");
        String tips = new AIHelper().getCareTips("high fever and chills since yesterday");

        assertTrue(tips.endsWith(DISCLAIMER), "must end with the standard disclaimer");
        String lower = tips.toLowerCase();
        assertTrue(lower.contains("water") || lower.contains("hydrat"),
                "should offer safe comfort guidance");
        // never names medicines / dosages
        assertFalse(lower.matches(".*\\b\\d+\\s?mg\\b.*"), "must not contain a dosage");
        assertFalse(lower.contains("paracetamol"));
    }

    @Test
    void urgencyFallbackFlagsEmergency() {
        assumeTrue(noApiKey(), "skipped: CLAUDE_API_KEY is set");
        AIResponse r = new AIHelper().classifyUrgency("severe chest pain and difficulty breathing");
        assertTrue(r.isFallback());
        assertEquals("emergency", r.getUrgencyLevel());
        assertTrue(r.isRecommendEr());
    }

    @Test
    void urgencyFallbackTreatsMildAsRoutine() {
        assumeTrue(noApiKey(), "skipped: CLAUDE_API_KEY is set");
        AIResponse r = new AIHelper().classifyUrgency("slight runny nose");
        assertEquals("routine", r.getUrgencyLevel());
        assertFalse(r.isRecommendEr());
    }
}
