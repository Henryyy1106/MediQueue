package com.mediqueue.controller;

import com.mediqueue.dao.ClinicDAO;
import com.mediqueue.model.Clinic;
import com.mediqueue.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * ClinicServlet - Find and search clinics
 * Author: Hor Jian Qi (22049860) - Module 3 (AI-enhanced clinic search)
 */
@WebServlet("/patient/clinics")
public class ClinicServlet extends HttpServlet {

    private final ClinicDAO clinicDAO = new ClinicDAO();
    private final com.mediqueue.ai.AIHelper aiHelper = new com.mediqueue.ai.AIHelper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("search");
        String symptoms = req.getParameter("symptoms");
        try {
            List<Clinic> clinics;
            if (keyword != null && !keyword.trim().isEmpty()) {
                clinics = clinicDAO.searchClinics(keyword.trim());
            } else {
                clinics = clinicDAO.getAllClinics();
            }

            req.setAttribute("clinics", clinics);

            // AI recommendation if symptoms provided
            if (symptoms != null && !symptoms.trim().isEmpty() && !clinics.isEmpty()) {
                String district = keyword != null ? keyword : "Klang Valley";
                com.mediqueue.ai.AIResponse aiResp = aiHelper.recommendClinic(clinics, symptoms, district);
                req.setAttribute("aiRecommendation", aiResp);
                req.setAttribute("symptoms", symptoms);
            }

            req.getRequestDispatcher("/WEB-INF/views/patient/clinics.jsp").forward(req, resp);
        } catch (Exception e) {
            log("Error loading clinics", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/patient/clinics.jsp").forward(req, resp);
        }
    }
}
