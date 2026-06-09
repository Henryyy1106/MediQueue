package com.mediqueue.ai;

import com.mediqueue.model.Clinic;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;

/**
 * AIHelper - Claude API integration for MediQueue
 * MediQueue | SWE3024 Code Camp
 * Author: Hor Jian Qi (22049860) - Module 3: AI Helper Integration
 *
 * Capabilities:
 * 1. Wait Time Prediction
 * 2. Clinic Recommendation
 * 3. Urgency Classification
 * 4. Appointment Summarisation
 * 5. Guidance & Decision Support
 */
public class AIHelper {

    private static final String CLAUDE_API_URL = "https://api.anthropic.com/v1/messages";
    private static final String CLAUDE_MODEL = "claude-haiku-4-5-20251001";
    private static final String API_KEY_ENV = "CLAUDE_API_KEY";

    private static final String SYSTEM_PROMPT =
        "You are the MediQueue AI Helper — a clinical decision-support assistant for Malaysian public government clinics. " +
        "Your role is to help patients navigate the queue and appointment system. " +
        "You MUST follow these strict rules:\n" +
        "1. You do NOT diagnose medical conditions or interpret test results.\n" +
        "2. You do NOT recommend specific medications or dosages.\n" +
        "3. You do NOT access or store patient health records externally.\n" +
        "4. For emergencies (difficulty breathing, chest pain, high fever >39.5°C, unconsciousness), ALWAYS direct to emergency services.\n" +
        "5. Keep responses concise, practical, and in plain English. Avoid medical jargon.\n" +
        "6. You may respond in simple Malay if the patient writes in Malay.\n" +
        "7. Always end with a disclaimer if giving health-related advice: 'This is for guidance only. Consult a qualified doctor for medical advice.'\n";

    private static final String CARE_TIPS_DISCLAIMER =
        "This is general guidance only — see the doctor at your appointment.";

    private static final String CARE_TIPS_SYSTEM_PROMPT =
        "You are the MediQueue AI Helper providing gentle pre-visit self-care tips to a patient who is " +
        "currently waiting in a clinic queue. Offer only safe, general comfort measures such as resting, " +
        "staying hydrated, gentle positioning, keeping warm or cool, and staying calm. " +
        "You MUST follow these strict rules with NO exceptions:\n" +
        "1. NEVER name specific medicines, drugs, supplements, or brands, and NEVER suggest any dosage.\n" +
        "2. NEVER diagnose, name a condition, or speculate about what is wrong with the patient.\n" +
        "3. NEVER interpret test results or symptoms clinically.\n" +
        "4. Keep advice to safe, non-medical comfort measures only (rest, hydration, comfort, calm).\n" +
        "5. If symptoms sound like an emergency (chest pain, difficulty breathing, severe bleeding, " +
        "fainting), gently advise the patient to alert clinic staff immediately.\n" +
        "6. Use 2-4 short, friendly sentences in plain English. No lists, no headings.\n" +
        "7. You MUST end your reply with exactly this sentence on its own: \"" + CARE_TIPS_DISCLAIMER + "\"\n";

    private final HttpClient httpClient;
    private final String apiKey;

    public AIHelper() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
        this.apiKey = System.getenv(API_KEY_ENV);
    }

    /**
     * Classify urgency level based on symptoms
     * Returns: "routine", "urgent", or "emergency"
     */
    public AIResponse classifyUrgency(String symptoms) {
        if (apiKey == null || apiKey.isEmpty()) {
            return getFallbackUrgency(symptoms);
        }

        String prompt = "A patient has described their symptoms as: \"" + symptoms + "\"\n\n" +
                "Classify their case urgency level and provide guidance. Respond in this exact JSON format:\n" +
                "{\n" +
                "  \"urgency\": \"routine|urgent|emergency\",\n" +
                "  \"advice\": \"brief plain-language advice\",\n" +
                "  \"recommend_er\": true|false\n" +
                "}";

        try {
            String raw = callClaude(prompt);
            JSONObject json = parseJSON(raw);
            if (json != null) {
                AIResponse response = new AIResponse();
                response.setUrgencyLevel(json.optString("urgency", "routine"));
                response.setAdvice(json.optString("advice", "Please proceed to your nearest clinic."));
                response.setRecommendEr(json.optBoolean("recommend_er", false));
                response.setSuccess(true);
                return response;
            }
        } catch (Exception e) {
            System.err.println("[AIHelper] classifyUrgency error: " + e.getMessage());
        }
        return getFallbackUrgency(symptoms);
    }

    /**
     * Predict wait time for a clinic
     */
    public AIResponse predictWaitTime(int clinicId, String clinicName, int currentQueue, int historicalAvgMins) {
        if (apiKey == null || apiKey.isEmpty()) {
            return getFallbackWaitTime(currentQueue, historicalAvgMins);
        }

        String prompt = "Predict the wait time for " + clinicName + " (Clinic ID: " + clinicId + ").\n" +
                "Current queue length: " + currentQueue + " patients waiting.\n" +
                "Historical average wait time this hour: " + historicalAvgMins + " minutes.\n" +
                "Provide a realistic estimated wait time in minutes. Respond in JSON:\n" +
                "{\n" +
                "  \"estimated_wait_mins\": <number>,\n" +
                "  \"confidence\": \"low|medium|high\",\n" +
                "  \"message\": \"brief explanation\"\n" +
                "}";

        try {
            String raw = callClaude(prompt);
            JSONObject json = parseJSON(raw);
            if (json != null) {
                AIResponse response = new AIResponse();
                response.setEstimatedWaitMins(json.optInt("estimated_wait_mins", historicalAvgMins));
                response.setMessage(json.optString("message", "Estimated based on current queue."));
                response.setSuccess(true);
                return response;
            }
        } catch (Exception e) {
            System.err.println("[AIHelper] predictWaitTime error: " + e.getMessage());
        }
        return getFallbackWaitTime(currentQueue, historicalAvgMins);
    }

    /**
     * Recommend best clinic from a list
     */
    public AIResponse recommendClinic(List<Clinic> clinics, String symptoms, String district) {
        if (apiKey == null || apiKey.isEmpty() || clinics.isEmpty()) {
            return getFallbackClinicRecommendation(clinics);
        }

        StringBuilder clinicList = new StringBuilder();
        for (Clinic c : clinics) {
            clinicList.append("- ").append(c.getName())
                    .append(" (ID: ").append(c.getClinicId()).append(")")
                    .append(", District: ").append(c.getDistrict())
                    .append(", Queue: ").append(c.getCurrentQueueCount()).append(" waiting")
                    .append(", Est. wait: ").append(c.getEstimatedWaitMins()).append(" mins")
                    .append(", Patient rating: ")
                    .append(c.getRatingCount() > 0
                            ? String.format("%.1f", c.getRating()) + "/5 from " + c.getRatingCount() + " reviews"
                            : "no ratings yet")
                    .append("\n");
        }

        String prompt = "A patient in " + district + " needs a clinic recommendation.\n" +
                "Symptoms: \"" + symptoms + "\"\n\n" +
                "Available clinics:\n" + clinicList +
                "\nRecommend the best clinic for this patient. Balance BOTH a shorter wait time AND a higher " +
                "patient rating (out of 5), while also considering location and urgency. Prefer clinics that " +
                "are highly rated unless their wait time is much longer; treat clinics with no ratings yet neutrally. " +
                "Respond in JSON:\n" +
                "{\n" +
                "  \"recommended_clinic_id\": <number>,\n" +
                "  \"recommended_clinic_name\": \"<name>\",\n" +
                "  \"estimated_wait_mins\": <number>,\n" +
                "  \"reason\": \"brief explanation\",\n" +
                "  \"urgency\": \"routine|urgent|emergency\"\n" +
                "}";

        try {
            String raw = callClaude(prompt);
            JSONObject json = parseJSON(raw);
            if (json != null) {
                AIResponse response = new AIResponse();
                response.setRecommendedClinicId(json.optInt("recommended_clinic_id", clinics.get(0).getClinicId()));
                response.setRecommendedClinicName(json.optString("recommended_clinic_name", clinics.get(0).getName()));
                response.setEstimatedWaitMins(json.optInt("estimated_wait_mins", clinics.get(0).getEstimatedWaitMins()));
                response.setMessage(json.optString("reason", "Shortest available wait time."));
                response.setUrgencyLevel(json.optString("urgency", "routine"));
                response.setSuccess(true);
                return response;
            }
        } catch (Exception e) {
            System.err.println("[AIHelper] recommendClinic error: " + e.getMessage());
        }
        return getFallbackClinicRecommendation(clinics);
    }

    /**
     * Generate visit summary for history
     */
    public String generateVisitSummary(String clinicName, String reason, String symptoms, String outcome) {
        if (apiKey == null || apiKey.isEmpty()) {
            return "Visit to " + clinicName + ". Reason: " + reason + ". " + (outcome != null ? outcome : "");
        }

        String prompt = "Generate a brief, plain-language visit summary for a patient's medical record.\n" +
                "Clinic: " + clinicName + "\n" +
                "Reason for visit: " + reason + "\n" +
                "Symptoms described: " + symptoms + "\n" +
                "Outcome/notes: " + (outcome != null ? outcome : "Not recorded") + "\n\n" +
                "Write a 2-3 sentence summary in plain English. Do not diagnose. Do not include personally identifiable info.";

        try {
            return callClaude(prompt);
        } catch (Exception e) {
            System.err.println("[AIHelper] generateVisitSummary error: " + e.getMessage());
            return "Visit to " + clinicName + ". Reason: " + reason + ".";
        }
    }

    /**
     * General AI chat for patient queries
     */
    public String chat(String userMessage, String clinicContext) {
        if (apiKey == null || apiKey.isEmpty()) {
            return "AI features are temporarily unavailable. Please proceed to your nearest clinic or contact clinic staff for assistance.";
        }

        String contextPrompt = clinicContext != null && !clinicContext.isEmpty()
                ? "Current clinic context: " + clinicContext + "\n\n"
                : "";

        try {
            return callClaude(contextPrompt + userMessage);
        } catch (Exception e) {
            System.err.println("[AIHelper] chat error: " + e.getMessage());
            return "AI features are temporarily unavailable. Please contact clinic staff for assistance.";
        }
    }

    /**
     * AI Pre-Visit Care Tips - safe self-care guidance for a patient waiting in the queue,
     * based on the symptoms they entered when booking.
     * Strict: no medicines/dosages, no diagnosis, always ends with the standard disclaimer.
     */
    public String getCareTips(String symptoms) {
        if (apiKey == null || apiKey.isEmpty()) {
            return getFallbackCareTips(symptoms);
        }

        String prompt = "A patient is waiting in the clinic queue. When booking, they described their " +
                "symptoms as: \"" + symptoms + "\"\n\n" +
                "Give them safe, comforting pre-visit self-care tips for while they wait. " +
                "Follow every rule in your instructions exactly.";

        try {
            String tips = callClaude(CARE_TIPS_SYSTEM_PROMPT, prompt);
            if (tips != null && !tips.isBlank()) {
                tips = tips.trim();
                // Safety net: guarantee the disclaimer is always present.
                if (!tips.contains(CARE_TIPS_DISCLAIMER)) {
                    tips = tips + "\n\n" + CARE_TIPS_DISCLAIMER;
                }
                return tips;
            }
        } catch (Exception e) {
            System.err.println("[AIHelper] getCareTips error: " + e.getMessage());
        }
        return getFallbackCareTips(symptoms);
    }

    // Core Claude API call (uses the default MediQueue system prompt)
    private String callClaude(String userMessage) throws IOException, InterruptedException {
        return callClaude(SYSTEM_PROMPT, userMessage);
    }

    // Core Claude API call with an explicit system prompt
    private String callClaude(String systemPrompt, String userMessage) throws IOException, InterruptedException {
        JSONObject requestBody = new JSONObject();
        requestBody.put("model", CLAUDE_MODEL);
        requestBody.put("max_tokens", 1024);
        requestBody.put("system", systemPrompt);

        JSONArray messages = new JSONArray();
        JSONObject userMsg = new JSONObject();
        userMsg.put("role", "user");
        userMsg.put("content", userMessage);
        messages.put(userMsg);
        requestBody.put("messages", messages);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(CLAUDE_API_URL))
                .header("Content-Type", "application/json")
                .header("x-api-key", apiKey)
                .header("anthropic-version", "2023-06-01")
                .POST(HttpRequest.BodyPublishers.ofString(requestBody.toString()))
                .timeout(Duration.ofSeconds(30))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new IOException("Claude API error: " + response.statusCode() + " " + response.body());
        }

        JSONObject responseJson = new JSONObject(response.body());
        JSONArray content = responseJson.getJSONArray("content");
        if (content.length() > 0) {
            return content.getJSONObject(0).getString("text");
        }
        throw new IOException("Empty response from Claude API");
    }

    private JSONObject parseJSON(String text) {
        try {
            // Extract JSON from response (Claude sometimes wraps in markdown)
            int start = text.indexOf('{');
            int end = text.lastIndexOf('}');
            if (start >= 0 && end > start) {
                return new JSONObject(text.substring(start, end + 1));
            }
        } catch (Exception e) {
            System.err.println("[AIHelper] JSON parse error: " + e.getMessage());
        }
        return null;
    }

    // ==================== Fallback Methods ====================

    private AIResponse getFallbackUrgency(String symptoms) {
        AIResponse r = new AIResponse();
        r.setSuccess(false);
        r.setFallback(true);
        String lower = symptoms != null ? symptoms.toLowerCase() : "";
        if (lower.contains("chest pain") || lower.contains("difficulty breathing") ||
                lower.contains("unconscious") || lower.contains("stroke") || lower.contains("seizure")) {
            r.setUrgencyLevel("emergency");
            r.setAdvice("Please proceed immediately to the nearest Emergency & Accident department.");
            r.setRecommendEr(true);
        } else if (lower.contains("high fever") || lower.contains("39") || lower.contains("severe") ||
                lower.contains("vomiting blood") || lower.contains("fracture")) {
            r.setUrgencyLevel("urgent");
            r.setAdvice("Please visit a clinic as soon as possible. Bring someone with you if possible.");
            r.setRecommendEr(false);
        } else {
            r.setUrgencyLevel("routine");
            r.setAdvice("Please book an appointment at your nearest clinic.");
            r.setRecommendEr(false);
        }
        return r;
    }

    private AIResponse getFallbackWaitTime(int queueCount, int historicalAvg) {
        AIResponse r = new AIResponse();
        r.setSuccess(false);
        r.setFallback(true);
        int estimated = Math.max(historicalAvg, queueCount * 8);
        r.setEstimatedWaitMins(estimated);
        r.setMessage("Estimated based on current queue length (" + queueCount + " patients).");
        return r;
    }

    private String getFallbackCareTips(String symptoms) {
        String lower = symptoms != null ? symptoms.toLowerCase() : "";
        StringBuilder tips = new StringBuilder();

        if (lower.contains("chest pain") || lower.contains("difficulty breathing") ||
                lower.contains("breathless") || lower.contains("faint") || lower.contains("unconscious") ||
                lower.contains("bleeding")) {
            tips.append("If your symptoms feel severe or are getting worse while you wait, please tell the " +
                    "clinic staff straight away so they can help you sooner. Try to stay calm and breathe slowly, " +
                    "and sit somewhere comfortable.");
        } else if (lower.contains("fever") || lower.contains("hot") || lower.contains("chills")) {
            tips.append("While you wait, sip water regularly to stay hydrated and rest in a cool, comfortable spot. " +
                    "Wear light clothing and let yourself relax — try not to over-exert.");
        } else if (lower.contains("cough") || lower.contains("cold") || lower.contains("flu") ||
                lower.contains("sore throat") || lower.contains("throat")) {
            tips.append("Keep sipping warm or room-temperature water to soothe your throat, and rest your voice " +
                    "where you can. Covering your mouth when you cough helps keep those around you safe.");
        } else if (lower.contains("headache") || lower.contains("migraine") || lower.contains("dizzy") ||
                lower.contains("dizziness")) {
            tips.append("Try to rest in a quieter, dimly lit spot and take slow, steady breaths. " +
                    "Sipping some water and avoiding sudden movements may help you feel more comfortable while you wait.");
        } else if (lower.contains("stomach") || lower.contains("nausea") || lower.contains("vomit") ||
                lower.contains("diarrh") || lower.contains("abdominal")) {
            tips.append("Take small sips of water to stay hydrated and sit in a position that feels comfortable. " +
                    "Resting quietly and breathing slowly can help settle how you feel until you're seen.");
        } else {
            tips.append("While you wait, find a comfortable place to sit, rest, and sip some water to stay hydrated. " +
                    "Try to stay calm and relaxed, and let the clinic staff know if you start to feel worse.");
        }

        tips.append("\n\n").append(CARE_TIPS_DISCLAIMER);
        return tips.toString();
    }

    private AIResponse getFallbackClinicRecommendation(List<Clinic> clinics) {
        AIResponse r = new AIResponse();
        r.setSuccess(false);
        r.setFallback(true);
        if (!clinics.isEmpty()) {
            // Find clinic with shortest wait
            Clinic best = clinics.stream()
                    .min((a, b) -> a.getEstimatedWaitMins() - b.getEstimatedWaitMins())
                    .orElse(clinics.get(0));
            r.setRecommendedClinicId(best.getClinicId());
            r.setRecommendedClinicName(best.getName());
            r.setEstimatedWaitMins(best.getEstimatedWaitMins());
            r.setMessage(best.getName() + " has the shortest current wait (" + best.getEstimatedWaitMins() + " mins).");
        }
        return r;
    }
}
