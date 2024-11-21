CREATE TABLE IF NOT EXISTS patient_record (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    age INTEGER NOT NULL,
    gender TEXT NOT NULL,
    date_of_birth TEXT NOT NULL,
    blood_group TEXT NOT NULL,
    contact_number_1 TEXT NOT NULL,
    contact_number_2 TEXT,
    aadhar_or_voter_id TEXT NOT NULL UNIQUE,
    weight INTEGER NOT NULL,
    height INTEGER NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    pin_code TEXT NOT NULL,
    emergency_contact_name TEXT NOT NULL,
    emergency_contact_relation TEXT NOT NULL,
    emergency_contact_no TEXT NOT NULL,
    email_id TEXT,
    date_of_registration TEXT NOT NULL,
    time_of_registration TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS doctor_record (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    age INTEGER NOT NULL,
    gender TEXT NOT NULL,
    date_of_birth TEXT NOT NULL,
    blood_group TEXT NOT NULL,
    department_id TEXT NOT NULL,
    department_name TEXT NOT NULL,
    contact_number_1 TEXT NOT NULL,
    contact_number_2 TEXT,
    aadhar_or_voter_id TEXT NOT NULL UNIQUE,
    email_id TEXT NOT NULL UNIQUE,
    qualification TEXT NOT NULL,
    specialisation TEXT NOT NULL,
    years_of_experience INTEGER NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    pin_code TEXT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES department_record(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS department_record (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    contact_number_1 TEXT NOT NULL,
    contact_number_2 TEXT,
    address TEXT NOT NULL,
    email_id TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS prescription_record (
    id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    patient_name TEXT NOT NULL,
    doctor_id TEXT NOT NULL,
    doctor_name TEXT NOT NULL,
    diagnosis TEXT NOT NULL,
    comments TEXT,
    medicine_1_name TEXT NOT NULL,
    medicine_1_dosage_description TEXT NOT NULL,
    medicine_2_name TEXT,
    medicine_2_dosage_description TEXT,
    medicine_3_name TEXT,
    medicine_3_dosage_description TEXT,
    FOREIGN KEY (patient_id) REFERENCES patient_record(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES doctor_record(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS medical_test_record (
    id TEXT PRIMARY KEY,
    test_name TEXT NOT NULL,
    patient_id TEXT NOT NULL,
    patient_name TEXT NOT NULL,
    doctor_id TEXT NOT NULL,
    doctor_name TEXT NOT NULL,
    medical_lab_scientist_id TEXT NOT NULL,
    test_date_time TEXT NOT NULL,
    result_date_time TEXT NOT NULL,
    result_and_diagnosis TEXT,
    description TEXT,
    comments TEXT,
    cost INTEGER NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patient_record(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES doctor_record(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS doctor_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    doctor_id TEXT NOT NULL,
    action TEXT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER IF NOT EXISTS after_doctor_insert
AFTER INSERT ON doctor_record
FOR EACH ROW
BEGIN
    INSERT INTO doctor_log (doctor_id, action, timestamp)
    VALUES (NEW.id, 'INSERT', CURRENT_TIMESTAMP);
END;

CREATE TRIGGER IF NOT EXISTS after_doctor_update
AFTER UPDATE ON doctor_record
FOR EACH ROW
BEGIN
    INSERT INTO doctor_log (doctor_id, action, timestamp)
    VALUES (NEW.id, 'UPDATE', CURRENT_TIMESTAMP);
END;

CREATE TRIGGER IF NOT EXISTS after_doctor_delete
AFTER DELETE ON doctor_record
FOR EACH ROW
BEGIN
    INSERT INTO doctor_log (doctor_id, action, timestamp)
    VALUES (OLD.id, 'DELETE', CURRENT_TIMESTAMP);
END;
-- Query to verify department ID
SELECT id
FROM department_record;

-- Query to fetch department name using department ID
SELECT name
FROM department_record
WHERE id = :id;

-- Query to insert a new department record
INSERT INTO department_record
(
    id, name, description, contact_number_1, contact_number_2,
    address, email_id
)
VALUES (
    :id, :name, :desc, :phone_1, :phone_2, :address, :email_id
);

-- Query to fetch details of a department using department ID
SELECT *
FROM department_record
WHERE id = :id;

-- Query to update a department record
UPDATE department_record
SET description = :desc,
    contact_number_1 = :phone_1, contact_number_2 = :phone_2,
    address = :address, email_id = :email_id
WHERE id = :id;

-- Query to delete a department record
DELETE FROM department_record
WHERE id = :id;

-- Query to fetch all department records
SELECT *
FROM department_record;

-- Query to fetch a list of doctors working in a department
SELECT id, name
FROM doctor_record
WHERE department_id = :dept_id;
-- Verify doctor ID
SELECT id FROM doctor_record WHERE id = ?;

-- Fetch department name by ID
SELECT name FROM department_record WHERE id = ?;

-- Insert a new doctor record
INSERT INTO doctor_record (
    id, name, age, gender, date_of_birth, blood_group,
    department_id, department_name, contact_number_1,
    contact_number_2, aadhar_or_voter_id, email_id,
    qualification, specialisation, years_of_experience,
    address, city, state, pin_code
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- Fetch a doctor record by ID
SELECT * FROM doctor_record WHERE id = ?;

-- Update an existing doctor record
UPDATE doctor_record SET 
    age = ?, department_id = ?, department_name = ?,
    contact_number_1 = ?, contact_number_2 = ?, email_id = ?, 
    qualification = ?, specialisation = ?, years_of_experience = ?, 
    address = ?, city = ?, state = ?, pin_code = ?
WHERE id = ?;

-- Delete a doctor record
DELETE FROM doctor_record WHERE id = ?;

-- Fetch all doctor records
SELECT * FROM doctor_record;
-- Query to verify medical test ID
SELECT id
FROM medical_test_record;

-- Query to fetch patient name by patient ID
SELECT name
FROM patient_record
WHERE id = :id;

-- Query to fetch doctor name by doctor ID
SELECT name
FROM doctor_record
WHERE id = :id;

-- Query to add a new medical test record
INSERT INTO medical_test_record
(
    id, test_name, patient_id, patient_name, doctor_id,
    doctor_name, medical_lab_scientist_id, test_date_time,
    result_date_time, cost, result_and_diagnosis, description,
    comments
)
VALUES (
    :id, :name, :p_id, :p_name, :dr_id, :dr_name, :mls_id,
    :test_date_time, :result_date_time, :cost,
    :result_diagnosis, :desc, :comments
);

-- Query to fetch medical test record by ID
SELECT *
FROM medical_test_record
WHERE id = :id;

-- Query to update an existing medical test record
UPDATE medical_test_record
SET result_and_diagnosis = :result_diagnosis,
    description = :description, comments = :comments
WHERE id = :id;

-- Query to delete a medical test record by ID
DELETE FROM medical_test_record
WHERE id = :id;

-- Query to fetch all medical tests for a particular patient
SELECT *
FROM medical_test_record
WHERE patient_id = :p_id;
-- Query to verify if a prescription ID exists
SELECT id
FROM prescription_record;

-- Query to fetch patient name using patient ID
SELECT name
FROM patient_record
WHERE id = :id;

-- Query to fetch doctor name using doctor ID
SELECT name
FROM doctor_record
WHERE id = :id;

-- Query to insert a new prescription record into the database
INSERT INTO prescription_record
(
    id, patient_id, patient_name, doctor_id,
    doctor_name, diagnosis, comments,
    medicine_1_name, medicine_1_dosage_description,
    medicine_2_name, medicine_2_dosage_description,
    medicine_3_name, medicine_3_dosage_description
)
VALUES (
    :id, :p_id, :p_name, :dr_id, :dr_name, :diagnosis,
    :comments, :med_1_name, :med_1_dose_desc, :med_2_name,
    :med_2_dose_desc, :med_3_name, :med_3_dose_desc
);

-- Query to fetch prescription details using prescription ID
SELECT *
FROM prescription_record
WHERE id = :id;

-- Query to update an existing prescription record in the database
UPDATE prescription_record
SET diagnosis = :diagnosis, comments = :comments,
    medicine_1_name = :med_1_name,
    medicine_1_dosage_description = :med_1_dose_desc,
    medicine_2_name = :med_2_name,
    medicine_2_dosage_description = :med_2_dose_desc,
    medicine_3_name = :med_3_name,
    medicine_3_dosage_description = :med_3_dose_desc
WHERE id = :id;

-- Query to delete a prescription record from the database
DELETE FROM prescription_record
WHERE id = :id;

-- Query to fetch all prescriptions of a particular patient using patient ID
SELECT *
FROM prescription_record
WHERE patient_id = :p_id;
