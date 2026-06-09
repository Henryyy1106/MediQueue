package com.mediqueue.controller;

import com.mediqueue.ai.AIHelper;
import com.mediqueue.ai.AIResponse;
import com.mediqueue.dao.ClinicDAO;
import com.mediqueue.model.Clinic;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * AIHelperServlet - REST-style endpoint for AI chat & clinic recommendation
 * MediQueue | SWE3024 Code Camp
 * Author: Hor Jian Qi (22049860) - Module 3: AI Helper Integration
 */
@WebServlet("/ai/*")
public class AIHelperServlet extends HttpServlet {

    private final AIHelper aiHelper = new AIHelper();
    private final ClinicDAO clinicDAO = new ClinicDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            if ("/chat".equals(pathInfo)) {
                String message = req.getParameter("message");
                String context = req.getParameter("context");
                if (message == null || message.trim().isEmpty()) {
                    out.print("{\"error\": \"Message is required\"}");
                    return;
                }
                String reply = aiHelper.chat(message.trim(), context);
                out.print("{\"reply\": " + org.json.JSONObject.quote(reply) + "}");

            } else if ("/classify".equals(pathInfo)) {
                String symptoms = req.getParameter("symptoms");
                if (symptoms == null || symptoms.trim().isEmpty()) {
                    out.print("{\"error\": \"Symptoms are required\"}");
                    return;
                }
                AIResponse aiResp = aiHelper.classifyUrgency(symptoms.trim());
                org.json.JSONObject json = new org.json.JSONObject();
                json.put("urgency", aiResp.getUrgencyLevel());
                json.put("advice", aiResp.getAdvice());
                json.put("recommend_er", aiResp.isRecommendEr());
                json.put("fallback", aiResp.isFallback());
                out.print(json.toString());

            } else if ("/caretips".equals(pathInfo)) {
                String symptoms = req.getParameter("symptoms");
                if (symptoms == null || symptoms.trim().isEmpty()) {
                    out.print("{\"error\": \"Symptoms are required\"}");
                    return;
                }
                String tips = aiHelper.getCareTips(symptoms.trim());
                org.json.JSONObject json = new org.json.JSONObject();
                json.put("tips", tips);
                out.print(json.toString());

            } else if ("/recommend".equals(pathInfo)) {
                String symptoms = req.getParameter("symptoms");
                String district = req.getParameter("district");
                List<Clinic> clinics = clinicDAO.getAllClinics();
                AIResponse aiResp = aiHelper.recommendClinic(clinics, symptoms, district != null ? district : "Klang Valley");
                org.json.JSONObject json = new org.json.JSONObject();
                json.put("clinic_id", aiResp.getRecommendedClinicId());
                json.put("clinic_name", aiResp.getRecommendedClinicName());
                json.put("estimated_wait_mins", aiResp.getEstimatedWaitMins());
                json.put("message", aiResp.getMessage());
                json.put("urgency", aiResp.getUrgencyLevel());
                json.put("fallback", aiResp.isFallback());
                out.print(json.toString());

            } else {
                resp.setStatus(404);
                out.print("{\"error\": \"Unknown AI endpoint\"}");
            }
        } catch (Exception e) {
            resp.setStatus(500);
            out.print("{\"error\": " + org.json.JSONObject.quote(e.getMessage()) + "}");
        }
    }
}
