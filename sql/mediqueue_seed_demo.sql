-- MediQueue Demo Data Seed
-- Run this after mediqueue_schema.sql
-- Purpose: populate appointments, queue, visit history, ratings, and notifications
-- so the admin dashboard, queue panel, reports, and patient pages have realistic data.

USE mediqueue;

START TRANSACTION;

-- Keep the seed script compatible with older local databases created before
-- appointments.admin_notes was added to the schema.
SET @has_admin_notes := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'appointments'
      AND COLUMN_NAME = 'admin_notes'
);
SET @admin_notes_sql := IF(
    @has_admin_notes = 0,
    'ALTER TABLE appointments ADD COLUMN admin_notes TEXT NULL',
    'SELECT 1'
);
PREPARE stmt_admin_notes FROM @admin_notes_sql;
EXECUTE stmt_admin_notes;
DEALLOCATE PREPARE stmt_admin_notes;

DROP TEMPORARY TABLE IF EXISTS demo_seed_numbers;
CREATE TEMPORARY TABLE demo_seed_numbers (
    n INT PRIMARY KEY
);

INSERT INTO demo_seed_numbers (n)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 50
)
SELECT n FROM seq;

-- Demo patients use the same BCrypt hash as patient123 from the base schema.
INSERT INTO users (name, email, password_hash, role, phone, gender) VALUES
('Aisyah Rahman', 'aisyah.demo@mediqueue.my', '$2a$12$vlheWfmCUu5ERSdkrKnRN.dQxHzXvvBYmCZfRmgK6KCJDDX3lDQWG', 'patient', '012-7000001', 'female'),
('Daniel Lee', 'daniel.demo@mediqueue.my', '$2a$12$vlheWfmCUu5ERSdkrKnRN.dQxHzXvvBYmCZfRmgK6KCJDDX3lDQWG', 'patient', '012-7000002', 'male'),
('Farah Nordin', 'farah.demo@mediqueue.my', '$2a$12$vlheWfmCUu5ERSdkrKnRN.dQxHzXvvBYmCZfRmgK6KCJDDX3lDQWG', 'patient', '012-7000003', 'female'),
('Gavin Tan', 'gavin.demo@mediqueue.my', '$2a$12$vlheWfmCUu5ERSdkrKnRN.dQxHzXvvBYmCZfRmgK6KCJDDX3lDQWG', 'patient', '012-7000004', 'male'),
('Hani Zulkifli', 'hani.demo@mediqueue.my', '$2a$12$vlheWfmCUu5ERSdkrKnRN.dQxHzXvvBYmCZfRmgK6KCJDDX3lDQWG', 'patient', '012-7000005', 'female'),
('Isaac Wong', 'isaac.demo@mediqueue.my', '$2a$12$vlheWfmCUu5ERSdkrKnRN.dQxHzXvvBYmCZfRmgK6KCJDDX3lDQWG', 'patient', '012-7000006', 'male')
ON DUPLICATE KEY UPDATE
password_hash = VALUES(password_hash),
phone = VALUES(phone),
gender = VALUES(gender);

INSERT INTO users (name, email, password_hash, role, phone, gender)
SELECT
    CONCAT('Seed Patient ', LPAD(n, 2, '0')),
    CONCAT('seed', LPAD(n, 2, '0'), '@mediqueue.my'),
    '$2a$12$vlheWfmCUu5ERSdkrKnRN.dQxHzXvvBYmCZfRmgK6KCJDDX3lDQWG',
    'patient',
    CONCAT('012-71', LPAD(n, 4, '0')),
    CASE WHEN MOD(n, 2) = 0 THEN 'female' ELSE 'male' END
FROM demo_seed_numbers
WHERE n <= 20
ON DUPLICATE KEY UPDATE
password_hash = VALUES(password_hash),
phone = VALUES(phone),
gender = VALUES(gender);

-- Resolve demo user ids.
SET @u_aisyah = (SELECT user_id FROM users WHERE email = 'aisyah.demo@mediqueue.my');
SET @u_daniel = (SELECT user_id FROM users WHERE email = 'daniel.demo@mediqueue.my');
SET @u_farah  = (SELECT user_id FROM users WHERE email = 'farah.demo@mediqueue.my');
SET @u_gavin  = (SELECT user_id FROM users WHERE email = 'gavin.demo@mediqueue.my');
SET @u_hani   = (SELECT user_id FROM users WHERE email = 'hani.demo@mediqueue.my');
SET @u_isaac  = (SELECT user_id FROM users WHERE email = 'isaac.demo@mediqueue.my');

SET @c_taman_jaya   = (SELECT clinic_id FROM clinics WHERE name = 'Klinik Kesihatan Taman Jaya' LIMIT 1);
SET @c_ss2          = (SELECT clinic_id FROM clinics WHERE name = 'Klinik Kesihatan SS2' LIMIT 1);
SET @c_kelana_jaya  = (SELECT clinic_id FROM clinics WHERE name = 'Klinik Kesihatan Kelana Jaya' LIMIT 1);
SET @c_subang_jaya  = (SELECT clinic_id FROM clinics WHERE name = 'Klinik Kesihatan Subang Jaya' LIMIT 1);
SET @c_shah_alam    = (SELECT clinic_id FROM clinics WHERE name = 'Klinik Kesihatan Shah Alam' LIMIT 1);

DROP TEMPORARY TABLE IF EXISTS demo_seed_user_ids;
CREATE TEMPORARY TABLE demo_seed_user_ids AS
SELECT user_id
FROM users
WHERE email LIKE '%.demo@mediqueue.my'
   OR email LIKE 'seed%@mediqueue.my';

-- Clean up previous demo rows so the script is rerunnable.
DELETE cr
FROM clinic_ratings cr
JOIN appointments a ON a.appt_id = cr.appt_id
JOIN demo_seed_user_ids du ON du.user_id = a.user_id;

DELETE vh
FROM visit_history vh
JOIN demo_seed_user_ids du ON du.user_id = vh.user_id;

DELETE q
FROM queue q
JOIN demo_seed_user_ids du ON du.user_id = q.user_id;

DELETE n
FROM notifications n
JOIN demo_seed_user_ids du ON du.user_id = n.user_id;

DELETE a
FROM appointments a
JOIN demo_seed_user_ids du ON du.user_id = a.user_id;

DROP TEMPORARY TABLE IF EXISTS demo_seed_bulk_users;
CREATE TEMPORARY TABLE demo_seed_bulk_users AS
SELECT ROW_NUMBER() OVER (ORDER BY user_id) AS idx, user_id
FROM users
WHERE email LIKE 'seed%@mediqueue.my';

-- Appointments: a mix of near-past history, today's live queue, and upcoming
-- bookings. The date spread intentionally reaches further into the future so
-- demo dashboards stay populated for longer between reseeds.
INSERT INTO appointments (user_id, clinic_id, appt_date, time_slot, reason, symptoms, status, urgency_level, ai_notes, admin_notes) VALUES
(@u_aisyah, @c_taman_jaya, CURDATE(), '09:00 AM', '[DEMO] Fever and sore throat', 'Fever for 2 days with sore throat', 'confirmed', 'routine', 'Hydrate and monitor temperature.', 'Patient checked in at counter.'),
(@u_daniel, @c_taman_jaya, CURDATE(), '09:30 AM', '[DEMO] Persistent cough', 'Dry cough and mild chest tightness', 'confirmed', 'urgent', 'Assess breathing and oxygen saturation.', 'Priority review requested.'),
(@u_farah, @c_ss2, CURDATE(), '10:00 AM', '[DEMO] Antenatal follow-up', 'Routine pregnancy follow-up visit', 'confirmed', 'routine', 'Standard maternal check-up.', 'Booked via patient portal.'),
(@u_gavin, @c_shah_alam, CURDATE(), '10:30 AM', '[DEMO] Migraine review', 'Recurring migraine with nausea', 'completed', 'urgent', 'Reduce screen exposure and review medication.', 'Completed consultation and discharged.'),
(@u_hani, @c_kelana_jaya, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '02:00 PM', '[DEMO] Child vaccination', 'Scheduled immunisation visit', 'completed', 'routine', 'Routine paediatric follow-up.', 'Completed smoothly yesterday.'),
(@u_isaac, @c_subang_jaya, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '11:00 AM', '[DEMO] Sports injury follow-up', 'Ankle sprain follow-up after futsal injury', 'confirmed', 'routine', 'Advise rest, ice, compression, elevation.', 'Bring previous x-ray report.'),
(@u_farah, @c_kelana_jaya, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '03:00 PM', '[DEMO] Skin rash assessment', 'Itchy rash on forearm', 'pending', 'routine', 'Observe for allergy triggers.', 'Awaiting admin review.'),
(@u_daniel, @c_ss2, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '04:00 PM', '[DEMO] Cancelled dental referral review', 'Follow-up for dental referral letter', 'cancelled', 'routine', 'No AI notes.', 'Patient cancelled before attending.');

INSERT INTO appointments (user_id, clinic_id, appt_date, time_slot, reason, symptoms, status, urgency_level, ai_notes, admin_notes)
SELECT
    u.user_id,
    CASE MOD(n.n - 1, 5)
        WHEN 0 THEN @c_taman_jaya
        WHEN 1 THEN @c_ss2
        WHEN 2 THEN @c_kelana_jaya
        WHEN 3 THEN @c_subang_jaya
        ELSE @c_shah_alam
    END AS clinic_id,
    CASE
        WHEN n.n <= 4 THEN DATE_SUB(CURDATE(), INTERVAL 6 DAY)
        WHEN n.n <= 8 THEN DATE_SUB(CURDATE(), INTERVAL 5 DAY)
        WHEN n.n <= 12 THEN DATE_SUB(CURDATE(), INTERVAL 4 DAY)
        WHEN n.n <= 16 THEN DATE_SUB(CURDATE(), INTERVAL 3 DAY)
        WHEN n.n <= 20 THEN DATE_SUB(CURDATE(), INTERVAL 2 DAY)
        WHEN n.n <= 24 THEN DATE_SUB(CURDATE(), INTERVAL 1 DAY)
        WHEN n.n <= 30 THEN CURDATE()
        WHEN n.n <= 34 THEN DATE_ADD(CURDATE(), INTERVAL 1 DAY)
        WHEN n.n <= 38 THEN DATE_ADD(CURDATE(), INTERVAL 2 DAY)
        WHEN n.n <= 41 THEN DATE_ADD(CURDATE(), INTERVAL 3 DAY)
        ELSE DATE_ADD(CURDATE(), INTERVAL 4 DAY)
    END AS appt_date,
    ELT(MOD(n.n - 1, 8) + 1, '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '02:00 PM', '03:00 PM') AS time_slot,
    CONCAT('[DEMO-BULK ', LPAD(n.n, 2, '0'), '] ', ELT(MOD(n.n - 1, 6) + 1,
        'General fever review',
        'Blood pressure follow-up',
        'Diabetes management consult',
        'Prenatal routine check',
        'Minor injury assessment',
        'Respiratory symptom review'
    )) AS reason,
    ELT(MOD(n.n - 1, 6) + 1,
        'Mild fever, body ache, sore throat',
        'Elevated blood pressure from home readings',
        'Review blood sugar log and medication tolerance',
        'Routine maternal wellness and scan follow-up',
        'Swollen ankle after weekend sports',
        'Cough, congestion, and fatigue for several days'
    ) AS symptoms,
    CASE
        WHEN n.n <= 24 THEN CASE
            WHEN MOD(n.n, 8) = 0 THEN 'cancelled'
            ELSE 'completed'
        END
        WHEN n.n <= 30 THEN CASE
            WHEN n.n IN (27, 29) THEN 'completed'
            WHEN n.n = 30 THEN 'cancelled'
            ELSE 'confirmed'
        END
        ELSE CASE
            WHEN MOD(n.n, 2) = 0 THEN 'confirmed'
            ELSE 'pending'
        END
    END AS status,
    CASE
        WHEN MOD(n.n, 9) = 0 THEN 'emergency'
        WHEN MOD(n.n, 3) = 0 THEN 'urgent'
        ELSE 'routine'
    END AS urgency_level,
    'Generated bulk demo notes for dashboard trends.' AS ai_notes,
    'Bulk seeded appointment for admin dashboard analytics.' AS admin_notes
FROM demo_seed_numbers n
JOIN demo_seed_bulk_users u ON u.idx = MOD(n.n - 1, 20) + 1
WHERE n.n <= 42;

-- Capture appointment ids for related queue/history rows.
SET @a_aisyah_today = (
    SELECT appt_id FROM appointments
    WHERE user_id = @u_aisyah AND appt_date = CURDATE() AND reason = '[DEMO] Fever and sore throat'
    ORDER BY appt_id DESC LIMIT 1
);
SET @a_daniel_today = (
    SELECT appt_id FROM appointments
    WHERE user_id = @u_daniel AND appt_date = CURDATE() AND reason = '[DEMO] Persistent cough'
    ORDER BY appt_id DESC LIMIT 1
);
SET @a_farah_today = (
    SELECT appt_id FROM appointments
    WHERE user_id = @u_farah AND appt_date = CURDATE() AND reason = '[DEMO] Antenatal follow-up'
    ORDER BY appt_id DESC LIMIT 1
);
SET @a_gavin_today = (
    SELECT appt_id FROM appointments
    WHERE user_id = @u_gavin AND appt_date = CURDATE() AND reason = '[DEMO] Migraine review'
    ORDER BY appt_id DESC LIMIT 1
);
SET @a_hani_yesterday = (
    SELECT appt_id FROM appointments
    WHERE user_id = @u_hani AND appt_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND reason = '[DEMO] Child vaccination'
    ORDER BY appt_id DESC LIMIT 1
);
SET @a_isaac_tomorrow = (
    SELECT appt_id FROM appointments
    WHERE user_id = @u_isaac AND appt_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) AND reason = '[DEMO] Sports injury follow-up'
    ORDER BY appt_id DESC LIMIT 1
);

-- Curated queue rows for the named demo patients power the admin queue panel and
-- dashboard queue cards. These are inserted first so they keep their narrative
-- positions (1/2), and the bulk rows below are offset past them per clinic/date
-- to avoid duplicate positions within the same clinic and queue date.
INSERT INTO queue (clinic_id, appt_id, user_id, position, status, estimated_wait_mins, queue_date, called_at, completed_at) VALUES
(@c_taman_jaya, @a_aisyah_today, @u_aisyah, 1, 'waiting', 10, CURDATE(), NULL, NULL),
(@c_taman_jaya, @a_daniel_today, @u_daniel, 2, 'in_progress', 20, CURDATE(), NOW(), NULL),
(@c_ss2, @a_farah_today, @u_farah, 1, 'waiting', 10, CURDATE(), NULL, NULL),
(@c_shah_alam, @a_gavin_today, @u_gavin, 1, 'done', 15, CURDATE(), DATE_SUB(NOW(), INTERVAL 90 MINUTE), DATE_SUB(NOW(), INTERVAL 40 MINUTE)),
(@c_kelana_jaya, @a_hani_yesterday, @u_hani, 1, 'done', 12, DATE_SUB(CURDATE(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 23 HOUR)),
(@c_subang_jaya, @a_isaac_tomorrow, @u_isaac, 1, 'waiting', 10, DATE_ADD(CURDATE(), INTERVAL 1 DAY), NULL, NULL);

-- Bulk queue rows, offset past any existing position for the same clinic/date so
-- they never collide with the curated rows above.
INSERT INTO queue (clinic_id, appt_id, user_id, position, status, estimated_wait_mins, queue_date, called_at, completed_at)
SELECT
    seeded.clinic_id,
    seeded.appt_id,
    seeded.user_id,
    seeded.position,
    CASE
        WHEN seeded.status = 'completed' THEN 'done'
        WHEN seeded.appt_date = CURDATE() AND seeded.position = 1 THEN 'in_progress'
        ELSE 'waiting'
    END AS queue_status,
    seeded.position * 8 AS estimated_wait_mins,
    seeded.appt_date,
    CASE
        WHEN seeded.status = 'completed' THEN DATE_SUB(NOW(), INTERVAL 3 HOUR)
        WHEN seeded.appt_date = CURDATE() AND seeded.position = 1 THEN DATE_SUB(NOW(), INTERVAL 35 MINUTE)
        ELSE NULL
    END AS called_at,
    CASE
        WHEN seeded.status = 'completed' THEN DATE_SUB(NOW(), INTERVAL 2 HOUR)
        ELSE NULL
    END AS completed_at
FROM (
    SELECT
        a.appt_id,
        a.user_id,
        a.clinic_id,
        a.appt_date,
        a.status,
        COALESCE(existing.max_position, 0)
            + ROW_NUMBER() OVER (PARTITION BY a.clinic_id, a.appt_date ORDER BY a.appt_id) AS position
    FROM appointments a
    LEFT JOIN (
        SELECT clinic_id, queue_date, MAX(position) AS max_position
        FROM queue
        GROUP BY clinic_id, queue_date
    ) existing
        ON existing.clinic_id = a.clinic_id
       AND existing.queue_date = a.appt_date
    WHERE a.reason LIKE '[DEMO-BULK %'
      AND a.status <> 'cancelled'
      AND a.appt_date <= DATE_ADD(CURDATE(), INTERVAL 4 DAY)
) seeded;

-- Completed visits feed the reports page and patient visit history.
INSERT INTO visit_history (user_id, clinic_id, appt_id, visit_date, actual_wait_mins, outcome, doctor_notes, ai_summary) VALUES
(@u_gavin, @c_shah_alam, @a_gavin_today, CURDATE(), 15, 'Migraine stabilised. Medication adjusted and patient discharged.', 'Review headache diary in two weeks.', 'Patient attended urgent migraine review and completed treatment today.'),
(@u_hani, @c_kelana_jaya, @a_hani_yesterday, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 12, 'Vaccination completed without complications.', 'Observe mild redness at injection site only.', 'Routine vaccination visit completed successfully yesterday.');

INSERT INTO visit_history (user_id, clinic_id, appt_id, visit_date, actual_wait_mins, outcome, doctor_notes, ai_summary)
SELECT
    a.user_id,
    a.clinic_id,
    a.appt_id,
    a.appt_date,
    8 + MOD(a.appt_id, 6) * 6 AS actual_wait_mins,
    CONCAT('Bulk seeded visit completed for ', a.reason, '.'),
    'Follow-up if symptoms persist beyond the expected recovery window.',
    'Bulk generated visit summary for dashboard and reports analytics.'
FROM appointments a
WHERE a.reason LIKE '[DEMO-BULK %'
  AND a.status = 'completed';

INSERT INTO clinic_ratings (user_id, clinic_id, appt_id, stars, comment) VALUES
(@u_gavin, @c_shah_alam, @a_gavin_today, 5, 'Fast response from the queue team and very clear explanations.'),
(@u_hani, @c_kelana_jaya, @a_hani_yesterday, 4, 'Smooth visit and short waiting time.')
ON DUPLICATE KEY UPDATE
stars = VALUES(stars),
comment = VALUES(comment);

INSERT INTO clinic_ratings (user_id, clinic_id, appt_id, stars, comment)
SELECT
    a.user_id,
    a.clinic_id,
    a.appt_id,
    CASE MOD(a.appt_id, 3)
        WHEN 0 THEN 5
        WHEN 1 THEN 4
        ELSE 3
    END AS stars,
    'Bulk seeded feedback for analytics preview.'
FROM appointments a
WHERE a.reason LIKE '[DEMO-BULK %'
  AND a.status = 'completed'
  AND MOD(a.appt_id, 4) = 0
ON DUPLICATE KEY UPDATE
stars = VALUES(stars),
comment = VALUES(comment);

INSERT INTO notifications (user_id, title, message, type, is_read) VALUES
(@u_aisyah, 'Queue registered', 'You are now in the live queue for Klinik Kesihatan Taman Jaya.', 'queue', FALSE),
(@u_daniel, 'Doctor is ready', 'Please proceed to the consultation room. Your visit is now in progress.', 'queue', FALSE),
(@u_farah, 'Appointment reminder', 'Your clinic visit is scheduled for today at 10:00 AM in Klinik Kesihatan SS2.', 'appointment', TRUE),
(@u_isaac, 'Appointment confirmed', 'Your follow-up appointment for tomorrow has been confirmed.', 'appointment', FALSE);

INSERT INTO notifications (user_id, title, message, type, is_read)
SELECT
    a.user_id,
    CASE
        WHEN a.appt_date = CURDATE() THEN 'Today''s appointment'
        WHEN a.appt_date > CURDATE() THEN 'Upcoming appointment confirmed'
        ELSE 'Visit completed'
    END AS title,
    CASE
        WHEN a.appt_date = CURDATE() THEN CONCAT('Your visit for ', a.reason, ' is scheduled for today at ', a.time_slot, '.')
        WHEN a.appt_date > CURDATE() THEN CONCAT('Your appointment for ', a.reason, ' is confirmed on ', a.appt_date, '.')
        ELSE CONCAT('Your visit for ', a.reason, ' has been marked as completed.')
    END AS message,
    CASE
        WHEN a.appt_date < CURDATE() THEN 'system'
        ELSE 'appointment'
    END AS type,
    CASE
        WHEN a.appt_date < CURDATE() THEN TRUE
        ELSE FALSE
    END AS is_read
FROM appointments a
WHERE a.reason LIKE '[DEMO-BULK %'
  AND (
      a.appt_date = CURDATE()
      OR a.appt_date > CURDATE()
      OR (a.appt_date < CURDATE() AND a.status = 'completed' AND MOD(a.appt_id, 5) = 0)
  );

COMMIT;

-- Quick summary checks after seeding:
-- SELECT COUNT(*) AS today_appointments FROM appointments WHERE appt_date = CURDATE() AND status <> 'cancelled';
-- SELECT status, COUNT(*) FROM queue WHERE queue_date = CURDATE() GROUP BY status;
-- SELECT COUNT(*) AS completed_visits FROM visit_history;
