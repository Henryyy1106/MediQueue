package com.mediqueue.controller;

import com.mediqueue.dao.AppointmentDAO;
import com.mediqueue.dao.ClinicDAO;
import com.mediqueue.dao.QueueDAO;
import com.mediqueue.dao.VisitHistoryDAO;
import com.mediqueue.model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * AdminDashboardServlet
 * Author: Ong Rong Yaw (22061584) - Module 5: Queue Dashboard & Reporting
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final QueueDAO queueDAO = new QueueDAO();
    private final AppointmentDAO apptDAO = new AppointmentDAO();
    private final ClinicDAO clinicDAO = new ClinicDAO();
    private final VisitHistoryDAO visitDAO = new VisitHistoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            LocalDate today = LocalDate.now();
            Date sqlToday = Date.valueOf(today);
            List<Queue> todayQueue = queueDAO.getAllTodayQueue();
            List<Appointment> allAppts = apptDAO.getAllAppointments();
            List<Clinic> clinics = clinicDAO.getAllClinics();
            List<VisitHistory> allVisits = visitDAO.getAllVisits();

            long totalToday = allAppts.stream()
                    .filter(appt -> sqlToday.equals(appt.getApptDate()))
                    .filter(appt -> !"cancelled".equals(appt.getStatus()))
                    .map(Appointment::getUserId)
                    .distinct()
                    .count();
            long waitingCount = todayQueue.stream().filter(q -> "waiting".equals(q.getStatus())).count();
            long inProgressCount = todayQueue.stream().filter(q -> "in_progress".equals(q.getStatus())).count();
            long doneCount = todayQueue.stream().filter(q -> "done".equals(q.getStatus())).count();
            long urgentCount = todayQueue.stream()
                    .filter(q -> "urgent".equals(q.getUrgencyLevel()) || "emergency".equals(q.getUrgencyLevel()))
                    .count();

            int activeQueueCount = (int) todayQueue.stream()
                    .filter(q -> "waiting".equals(q.getStatus()) || "in_progress".equals(q.getStatus()))
                    .count();
            int avgLiveWait = (int) Math.round(todayQueue.stream()
                    .filter(q -> "waiting".equals(q.getStatus()) || "in_progress".equals(q.getStatus()))
                    .mapToInt(Queue::getEstimatedWaitMins)
                    .average()
                    .orElse(0));
            int avgCompletedWait = (int) Math.round(allVisits.stream()
                    .filter(v -> sqlToday.equals(v.getVisitDate()))
                    .mapToInt(VisitHistory::getActualWaitMins)
                    .average()
                    .orElse(0));
            int completionRate = totalToday > 0 ? (int) Math.round((doneCount * 100.0) / totalToday) : 0;

            List<TrendPoint> operationsTrend = buildOperationsTrend(allAppts, allVisits, today);
            List<SingleTrendPoint> waitTrend = buildWaitTrend(allVisits, today);
            List<StatusMetric> statusMetrics = buildStatusMetrics(todayQueue);
            List<ClinicLoadMetric> clinicMetrics = buildClinicLoadMetrics(clinics, todayQueue);
            List<VisitHistory> recentVisits = allVisits.stream().limit(4).collect(Collectors.toList());
            List<Queue> priorityQueue = todayQueue.stream().limit(5).collect(Collectors.toList());

            req.setAttribute("todayQueue", todayQueue);
            req.setAttribute("priorityQueue", priorityQueue);
            req.setAttribute("clinics", clinics);
            req.setAttribute("recentVisits", recentVisits);
            req.setAttribute("waitingCount", waitingCount);
            req.setAttribute("inProgressCount", inProgressCount);
            req.setAttribute("doneCount", doneCount);
            req.setAttribute("totalToday", totalToday);
            req.setAttribute("todayLabel", today.format(DateTimeFormatter.ofPattern("d MMM yyyy", Locale.ENGLISH)));
            req.setAttribute("activeQueueCount", activeQueueCount);
            req.setAttribute("avgLiveWait", avgLiveWait);
            req.setAttribute("avgCompletedWait", avgCompletedWait);
            req.setAttribute("completionRate", completionRate);
            req.setAttribute("urgentCount", urgentCount);
            req.setAttribute("operationsTrend", operationsTrend);
            req.setAttribute("operationsChartSvg", buildDualLineChartSvg(operationsTrend, "#8b5cf6", "#22c55e"));
            req.setAttribute("waitTrend", waitTrend);
            req.setAttribute("waitChartSvg", buildSingleLineChartSvg(waitTrend, "#38bdf8"));
            req.setAttribute("statusMetrics", statusMetrics);
            req.setAttribute("clinicMetrics", clinicMetrics);

            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            log("Dashboard error", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
        }
    }

    private List<TrendPoint> buildOperationsTrend(List<Appointment> appointments, List<VisitHistory> visits, LocalDate today) {
        Map<LocalDate, Integer> appointmentCounts = new LinkedHashMap<>();
        Map<LocalDate, Integer> completionCounts = new LinkedHashMap<>();

        for (int i = 6; i >= 0; i--) {
            LocalDate day = today.minusDays(i);
            appointmentCounts.put(day, 0);
            completionCounts.put(day, 0);
        }

        for (Appointment appointment : appointments) {
            if (appointment.getApptDate() == null || "cancelled".equals(appointment.getStatus())) {
                continue;
            }
            LocalDate day = appointment.getApptDate().toLocalDate();
            if (appointmentCounts.containsKey(day)) {
                appointmentCounts.put(day, appointmentCounts.get(day) + 1);
            }
        }

        for (VisitHistory visit : visits) {
            if (visit.getVisitDate() == null) {
                continue;
            }
            LocalDate day = visit.getVisitDate().toLocalDate();
            if (completionCounts.containsKey(day)) {
                completionCounts.put(day, completionCounts.get(day) + 1);
            }
        }

        List<TrendPoint> points = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d MMM", Locale.ENGLISH);
        for (Map.Entry<LocalDate, Integer> entry : appointmentCounts.entrySet()) {
            LocalDate day = entry.getKey();
            points.add(new TrendPoint(
                    formatter.format(day),
                    entry.getValue(),
                    completionCounts.getOrDefault(day, 0)
            ));
        }
        return points;
    }

    private List<SingleTrendPoint> buildWaitTrend(List<VisitHistory> visits, LocalDate today) {
        Map<LocalDate, List<Integer>> waitBuckets = new LinkedHashMap<>();
        for (int i = 6; i >= 0; i--) {
            waitBuckets.put(today.minusDays(i), new ArrayList<>());
        }

        for (VisitHistory visit : visits) {
            if (visit.getVisitDate() == null) {
                continue;
            }
            LocalDate day = visit.getVisitDate().toLocalDate();
            List<Integer> waits = waitBuckets.get(day);
            if (waits != null) {
                waits.add(visit.getActualWaitMins());
            }
        }

        List<SingleTrendPoint> points = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d MMM", Locale.ENGLISH);
        for (Map.Entry<LocalDate, List<Integer>> entry : waitBuckets.entrySet()) {
            List<Integer> waits = entry.getValue();
            int avg = waits.isEmpty()
                    ? 0
                    : (int) Math.round(waits.stream().mapToInt(Integer::intValue).average().orElse(0));
            points.add(new SingleTrendPoint(formatter.format(entry.getKey()), avg));
        }
        return points;
    }

    private List<StatusMetric> buildStatusMetrics(List<Queue> todayQueue) {
        int total = todayQueue.size();
        List<StatusMetric> metrics = new ArrayList<>();
        metrics.add(new StatusMetric("Waiting", countStatus(todayQueue, "waiting"), total, "warning"));
        metrics.add(new StatusMetric("In Progress", countStatus(todayQueue, "in_progress"), total, "info"));
        metrics.add(new StatusMetric("Completed", countStatus(todayQueue, "done"), total, "success"));
        metrics.add(new StatusMetric("Skipped", countStatus(todayQueue, "skipped"), total, "muted"));
        return metrics;
    }

    private int countStatus(List<Queue> todayQueue, String status) {
        return (int) todayQueue.stream().filter(q -> status.equals(q.getStatus())).count();
    }

    private List<ClinicLoadMetric> buildClinicLoadMetrics(List<Clinic> clinics, List<Queue> todayQueue) {
        Map<Integer, Long> inProgressByClinic = todayQueue.stream()
                .filter(q -> "in_progress".equals(q.getStatus()))
                .collect(Collectors.groupingBy(Queue::getClinicId, Collectors.counting()));
        Map<Integer, Long> doneByClinic = todayQueue.stream()
                .filter(q -> "done".equals(q.getStatus()))
                .collect(Collectors.groupingBy(Queue::getClinicId, Collectors.counting()));

        return clinics.stream()
                .map(clinic -> new ClinicLoadMetric(
                        clinic.getClinicId(),
                        clinic.getName(),
                        clinic.getDistrict(),
                        clinic.getCurrentQueueCount(),
                        inProgressByClinic.getOrDefault(clinic.getClinicId(), 0L).intValue(),
                        doneByClinic.getOrDefault(clinic.getClinicId(), 0L).intValue(),
                        clinic.getCapacity(),
                        clinic.getEstimatedWaitMins()
                ))
                .sorted(Comparator.comparingInt(ClinicLoadMetric::getLoadPercent).reversed()
                        .thenComparingInt(ClinicLoadMetric::getWaitingCount).reversed())
                .collect(Collectors.toList());
    }

    private String buildDualLineChartSvg(List<TrendPoint> points, String primaryColor, String secondaryColor) {
        if (points.isEmpty()) {
            return "";
        }

        int width = 720;
        int height = 320;
        int left = 42;
        int right = 20;
        int top = 24;
        int bottom = 42;
        int chartWidth = width - left - right;
        int chartHeight = height - top - bottom;
        int rawMax = Math.max(1, points.stream()
                .mapToInt(point -> Math.max(point.getPrimaryValue(), point.getSecondaryValue()))
                .max()
                .orElse(1));
        int maxValue = niceAxisMax(rawMax);

        int[] primaryValues = points.stream().mapToInt(TrendPoint::getPrimaryValue).toArray();
        int[] secondaryValues = points.stream().mapToInt(TrendPoint::getSecondaryValue).toArray();
        List<ChartPoint> primaryPoints = buildChartPoints(primaryValues, maxValue, left, top, chartWidth, chartHeight);
        List<ChartPoint> secondaryPoints = buildChartPoints(secondaryValues, maxValue, left, top, chartWidth, chartHeight);
        String primaryLine = buildSmoothPath(primaryPoints);
        String secondaryLine = buildSmoothPath(secondaryPoints);

        return "<svg viewBox=\"0 0 " + width + " " + height + "\" class=\"analytics-chart\" role=\"img\" aria-label=\"Operations trend chart\">"
                + buildGridLines(width, height, left, right, top, bottom)
                + buildYAxisLabels(maxValue, left, top, chartHeight)
                + buildXAxisLabels(points.stream().map(TrendPoint::getLabel).collect(Collectors.toList()), left, top, chartWidth, chartHeight)
                + "<path d=\"" + secondaryLine + "\" fill=\"none\" stroke=\"" + secondaryColor + "\" stroke-width=\"18\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.16\"></path>"
                + "<path d=\"" + primaryLine + "\" fill=\"none\" stroke=\"" + primaryColor + "\" stroke-width=\"22\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.14\"></path>"
                + "<path d=\"" + secondaryLine + "\" fill=\"none\" stroke=\"" + secondaryColor + "\" stroke-width=\"3.5\" stroke-linecap=\"round\" stroke-linejoin=\"round\"></path>"
                + "<path d=\"" + primaryLine + "\" fill=\"none\" stroke=\"" + primaryColor + "\" stroke-width=\"4\" stroke-linecap=\"round\" stroke-linejoin=\"round\"></path>"
                + buildPointDots(primaryPoints, primaryColor, "#ffffff")
                + buildPointDots(secondaryPoints, secondaryColor, "#ffffff")
                + "</svg>";
    }

    private String buildSingleLineChartSvg(List<SingleTrendPoint> points, String color) {
        if (points.isEmpty()) {
            return "";
        }

        int width = 720;
        int height = 220;
        int left = 26;
        int right = 20;
        int top = 18;
        int bottom = 26;
        int chartWidth = width - left - right;
        int chartHeight = height - top - bottom;
        int maxValue = Math.max(1, points.stream().mapToInt(SingleTrendPoint::getValue).max().orElse(1));

        int[] values = points.stream().mapToInt(SingleTrendPoint::getValue).toArray();
        String line = buildPolyline(values, maxValue, left, top, chartWidth, chartHeight);
        String area = buildAreaPath(values, maxValue, left, top, chartWidth, chartHeight);

        return "<svg viewBox=\"0 0 " + width + " " + height + "\" class=\"analytics-chart analytics-chart-compact\" role=\"img\" aria-label=\"Average wait trend chart\">"
                + buildGridLines(width, height, left, right, top, bottom)
                + "<path d=\"" + area + "\" fill=\"url(#analyticsWaitArea)\" opacity=\"0.22\"></path>"
                + "<polyline points=\"" + line + "\" fill=\"none\" stroke=\"" + color + "\" stroke-width=\"3.5\" stroke-linecap=\"round\" stroke-linejoin=\"round\"></polyline>"
                + "<defs><linearGradient id=\"analyticsWaitArea\" x1=\"0\" y1=\"0\" x2=\"0\" y2=\"1\">"
                + "<stop offset=\"0%\" stop-color=\"" + color + "\"/>"
                + "<stop offset=\"100%\" stop-color=\"#0f172a\" stop-opacity=\"0\"/>"
                + "</linearGradient></defs></svg>";
    }

    private String buildGridLines(int width, int height, int left, int right, int top, int bottom) {
        int chartHeight = height - top - bottom;
        int lineCount = 4;
        StringBuilder grid = new StringBuilder();
        for (int i = 0; i < lineCount; i++) {
            double ratio = i / (double) (lineCount - 1);
            int y = top + (int) Math.round(chartHeight * ratio);
            grid.append("<line x1=\"")
                    .append(left)
                    .append("\" y1=\"")
                    .append(y)
                    .append("\" x2=\"")
                    .append(width - right)
                    .append("\" y2=\"")
                    .append(y)
                    .append("\" stroke=\"rgba(148,163,184,0.45)\" stroke-dasharray=\"4 7\"></line>");
        }
        return grid.toString();
    }

    private String buildYAxisLabels(int maxValue, int left, int top, int chartHeight) {
        StringBuilder labels = new StringBuilder();
        int lineCount = 4;
        for (int i = 0; i < lineCount; i++) {
            double ratio = i / (double) (lineCount - 1);
            int y = top + (int) Math.round(chartHeight * ratio) + 5;
            int value = maxValue - (int) Math.round(maxValue * ratio);
            labels.append("<text x=\"")
                    .append(left - 10)
                    .append("\" y=\"")
                    .append(y)
                    .append("\" text-anchor=\"end\" class=\"analytics-axis-label\">")
                    .append(value)
                    .append("</text>");
        }
        return labels.toString();
    }

    private String buildXAxisLabels(List<String> labels, int left, int top, int chartWidth, int chartHeight) {
        StringBuilder result = new StringBuilder();
        int y = top + chartHeight + 24;
        if (labels.size() == 1) {
            result.append("<text x=\"")
                    .append(left + chartWidth / 2)
                    .append("\" y=\"")
                    .append(y)
                    .append("\" text-anchor=\"middle\" class=\"analytics-axis-label\">")
                    .append(labels.get(0))
                    .append("</text>");
            return result.toString();
        }

        for (int i = 0; i < labels.size(); i++) {
            int x = left + (int) Math.round((chartWidth * i) / (double) (labels.size() - 1));
            result.append("<text x=\"")
                    .append(x)
                    .append("\" y=\"")
                    .append(y)
                    .append("\" text-anchor=\"middle\" class=\"analytics-axis-label\">")
                    .append(labels.get(i))
                    .append("</text>");
        }
        return result.toString();
    }

    private List<ChartPoint> buildChartPoints(int[] values, int maxValue, int left, int top, int chartWidth, int chartHeight) {
        List<ChartPoint> points = new ArrayList<>();
        if (values.length == 1) {
            points.add(new ChartPoint(left + chartWidth / 2.0, top + chartHeight - scaleValue(values[0], maxValue, chartHeight)));
            return points;
        }

        for (int i = 0; i < values.length; i++) {
            double x = left + ((chartWidth * i) / (double) (values.length - 1));
            double y = top + chartHeight - scaleValue(values[i], maxValue, chartHeight);
            points.add(new ChartPoint(x, y));
        }
        return points;
    }

    private String buildSmoothPath(List<ChartPoint> points) {
        if (points.isEmpty()) {
            return "";
        }
        if (points.size() == 1) {
            ChartPoint point = points.get(0);
            return "M " + formatDouble(point.x) + " " + formatDouble(point.y);
        }

        StringBuilder path = new StringBuilder("M ")
                .append(formatDouble(points.get(0).x))
                .append(' ')
                .append(formatDouble(points.get(0).y));

        for (int i = 0; i < points.size() - 1; i++) {
            ChartPoint current = points.get(i);
            ChartPoint next = points.get(i + 1);
            double controlX = (current.x + next.x) / 2.0;
            path.append(" C ")
                    .append(formatDouble(controlX)).append(' ').append(formatDouble(current.y)).append(' ')
                    .append(formatDouble(controlX)).append(' ').append(formatDouble(next.y)).append(' ')
                    .append(formatDouble(next.x)).append(' ').append(formatDouble(next.y));
        }
        return path.toString();
    }

    private String buildPointDots(List<ChartPoint> points, String color, String centerFill) {
        StringBuilder dots = new StringBuilder();
        for (ChartPoint point : points) {
            dots.append("<circle cx=\"")
                    .append(formatDouble(point.x))
                    .append("\" cy=\"")
                    .append(formatDouble(point.y))
                    .append("\" r=\"5.5\" fill=\"")
                    .append(color)
                    .append("\" opacity=\"0.18\"></circle>");
            dots.append("<circle cx=\"")
                    .append(formatDouble(point.x))
                    .append("\" cy=\"")
                    .append(formatDouble(point.y))
                    .append("\" r=\"3.7\" fill=\"")
                    .append(color)
                    .append("\" stroke=\"")
                    .append(centerFill)
                    .append("\" stroke-width=\"1.5\"></circle>");
        }
        return dots.toString();
    }

    private String buildPolyline(int[] values, int maxValue, int left, int top, int chartWidth, int chartHeight) {
        if (values.length == 1) {
            int y = top + chartHeight - scaleValue(values[0], maxValue, chartHeight);
            return left + "," + y + " " + (left + chartWidth) + "," + y;
        }

        StringBuilder points = new StringBuilder();
        for (int i = 0; i < values.length; i++) {
            int x = left + (int) Math.round((chartWidth * i) / (double) (values.length - 1));
            int y = top + chartHeight - scaleValue(values[i], maxValue, chartHeight);
            if (i > 0) {
                points.append(' ');
            }
            points.append(x).append(',').append(y);
        }
        return points.toString();
    }

    private String buildAreaPath(int[] values, int maxValue, int left, int top, int chartWidth, int chartHeight) {
        if (values.length == 0) {
            return "";
        }

        StringBuilder path = new StringBuilder();
        for (int i = 0; i < values.length; i++) {
            int x = values.length == 1
                    ? left + chartWidth / 2
                    : left + (int) Math.round((chartWidth * i) / (double) (values.length - 1));
            int y = top + chartHeight - scaleValue(values[i], maxValue, chartHeight);
            path.append(i == 0 ? "M " : " L ")
                    .append(x)
                    .append(' ')
                    .append(y);
        }

        int lastX = values.length == 1 ? left + chartWidth / 2 : left + chartWidth;
        path.append(" L ").append(lastX).append(' ').append(top + chartHeight)
                .append(" L ").append(left).append(' ').append(top + chartHeight)
                .append(" Z");
        return path.toString();
    }

    private int scaleValue(int value, int maxValue, int chartHeight) {
        return (int) Math.round((value / (double) maxValue) * chartHeight);
    }

    private int niceAxisMax(int rawMax) {
        if (rawMax <= 4) {
            return 4;
        }
        if (rawMax <= 10) {
            return ((rawMax + 1) / 2) * 2;
        }
        if (rawMax <= 20) {
            return ((rawMax + 4) / 5) * 5;
        }
        return ((rawMax + 9) / 10) * 10;
    }

    private String formatDouble(double value) {
        return String.format(Locale.ENGLISH, "%.2f", value);
    }

    private static class ChartPoint {
        private final double x;
        private final double y;

        private ChartPoint(double x, double y) {
            this.x = x;
            this.y = y;
        }
    }

    public static class TrendPoint {
        private final String label;
        private final int primaryValue;
        private final int secondaryValue;

        public TrendPoint(String label, int primaryValue, int secondaryValue) {
            this.label = label;
            this.primaryValue = primaryValue;
            this.secondaryValue = secondaryValue;
        }

        public String getLabel() { return label; }
        public int getPrimaryValue() { return primaryValue; }
        public int getSecondaryValue() { return secondaryValue; }
    }

    public static class SingleTrendPoint {
        private final String label;
        private final int value;

        public SingleTrendPoint(String label, int value) {
            this.label = label;
            this.value = value;
        }

        public String getLabel() { return label; }
        public int getValue() { return value; }
    }

    public static class StatusMetric {
        private final String label;
        private final int count;
        private final int percent;
        private final String tone;

        public StatusMetric(String label, int count, int total, String tone) {
            this.label = label;
            this.count = count;
            this.percent = total > 0 ? (int) Math.round((count * 100.0) / total) : 0;
            this.tone = tone;
        }

        public String getLabel() { return label; }
        public int getCount() { return count; }
        public int getPercent() { return percent; }
        public String getTone() { return tone; }
    }

    public static class ClinicLoadMetric {
        private final int clinicId;
        private final String clinicName;
        private final String district;
        private final int waitingCount;
        private final int inProgressCount;
        private final int completedCount;
        private final int capacity;
        private final int estimatedWaitMins;
        private final int loadPercent;

        public ClinicLoadMetric(int clinicId, String clinicName, String district, int waitingCount,
                                int inProgressCount, int completedCount, int capacity, int estimatedWaitMins) {
            this.clinicId = clinicId;
            this.clinicName = clinicName;
            this.district = district;
            this.waitingCount = waitingCount;
            this.inProgressCount = inProgressCount;
            this.completedCount = completedCount;
            this.capacity = capacity;
            this.estimatedWaitMins = estimatedWaitMins;
            this.loadPercent = capacity > 0 ? Math.min(100, (int) Math.round((waitingCount * 100.0) / capacity)) : 0;
        }

        public int getClinicId() { return clinicId; }
        public String getClinicName() { return clinicName; }
        public String getDistrict() { return district; }
        public int getWaitingCount() { return waitingCount; }
        public int getInProgressCount() { return inProgressCount; }
        public int getCompletedCount() { return completedCount; }
        public int getCapacity() { return capacity; }
        public int getEstimatedWaitMins() { return estimatedWaitMins; }
        public int getLoadPercent() { return loadPercent; }
    }
}
