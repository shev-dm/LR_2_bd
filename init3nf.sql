CREATE TABLE departments (
    department_id  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(120) NOT NULL UNIQUE,
    location        VARCHAR(120)
);
 
CREATE TABLE staff (
    staff_id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_id  BIGINT NOT NULL REFERENCES departments(department_id),
    last_name      VARCHAR(80) NOT NULL,
    first_name     VARCHAR(80) NOT NULL,
    middle_name    VARCHAR(80),
    role_name      VARCHAR(80) NOT NULL,
    phone          VARCHAR(30)
);
 
CREATE TABLE patients (
    patient_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    medical_record_no VARCHAR(30) NOT NULL UNIQUE,
    last_name      VARCHAR(80) NOT NULL,
    first_name     VARCHAR(80) NOT NULL,
    middle_name    VARCHAR(80),
    birth_date     DATE,
    sex            VARCHAR(20),
    phone          VARCHAR(30)
);
 
CREATE TABLE triage_levels (
    triage_level_id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    level_name      VARCHAR(40) NOT NULL UNIQUE,
    priority_order  SMALLINT NOT NULL UNIQUE CHECK (priority_order > 0),
    description     TEXT
);
 
CREATE TABLE arrival_methods (
    arrival_method_id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    method_name       VARCHAR(60) NOT NULL UNIQUE
);
 
CREATE TABLE visit_statuses (
    visit_status_id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status_name     VARCHAR(50) NOT NULL UNIQUE
);
 
CREATE TABLE discharge_outcomes (
    discharge_outcome_id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    outcome_name         VARCHAR(80) NOT NULL UNIQUE
);
 
CREATE TABLE emergency_visits (
    visit_id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id        BIGINT NOT NULL REFERENCES patients(patient_id),
    arrival_method_id SMALLINT NOT NULL REFERENCES arrival_methods(arrival_method_id),
    visit_status_id   SMALLINT NOT NULL REFERENCES visit_statuses(visit_status_id),
    received_at       TIMESTAMPTZ NOT NULL,
    complaint         TEXT NOT NULL,
    ended_at          TIMESTAMPTZ,
    CHECK (ended_at IS NULL OR ended_at >= received_at)
);
 
CREATE TABLE triage_assessments (
    assessment_id  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    visit_id       BIGINT NOT NULL REFERENCES emergency_visits(visit_id) ON DELETE CASCADE,
    triage_level_id SMALLINT NOT NULL REFERENCES triage_levels(triage_level_id),
    assessed_by    BIGINT NOT NULL REFERENCES staff(staff_id),
    assessed_at    TIMESTAMPTZ NOT NULL,
    notes          TEXT
);
 
CREATE TABLE diagnoses (
    diagnosis_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    diagnosis_code VARCHAR(20) NOT NULL UNIQUE,
    diagnosis_name VARCHAR(200) NOT NULL
);
 
CREATE TABLE visit_diagnoses (
    visit_id      BIGINT NOT NULL REFERENCES emergency_visits(visit_id) ON DELETE CASCADE,
    diagnosis_id  BIGINT NOT NULL REFERENCES diagnoses(diagnosis_id),
    is_primary    BOOLEAN NOT NULL DEFAULT FALSE,
    recorded_by   BIGINT NOT NULL REFERENCES staff(staff_id),
    recorded_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (visit_id, diagnosis_id)
);
 
CREATE TABLE procedures (
    procedure_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    procedure_code VARCHAR(20) NOT NULL UNIQUE,
    procedure_name VARCHAR(200) NOT NULL
);
 
CREATE TABLE visit_procedures (
    visit_id      BIGINT NOT NULL REFERENCES emergency_visits(visit_id) ON DELETE CASCADE,
    procedure_id  BIGINT NOT NULL REFERENCES procedures(procedure_id),
    performed_by  BIGINT NOT NULL REFERENCES staff(staff_id),
    performed_at  TIMESTAMPTZ NOT NULL,
    result_notes  TEXT,
    PRIMARY KEY (visit_id, procedure_id, performed_at)
);
 
CREATE TABLE beds (
    bed_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_id BIGINT NOT NULL REFERENCES departments(department_id),
    bed_code      VARCHAR(30) NOT NULL,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (department_id, bed_code)
);
 
CREATE TABLE bed_assignments (
    bed_assignment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    visit_id          BIGINT NOT NULL REFERENCES emergency_visits(visit_id) ON DELETE CASCADE,
    bed_id            BIGINT NOT NULL REFERENCES beds(bed_id),
    assigned_at       TIMESTAMPTZ NOT NULL,
    released_at       TIMESTAMPTZ,
    CHECK (released_at IS NULL OR released_at >= assigned_at)
);
 
CREATE TABLE visit_dispositions (
    disposition_id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    visit_id             BIGINT NOT NULL UNIQUE REFERENCES emergency_visits(visit_id) ON DELETE CASCADE,
    discharge_outcome_id SMALLINT NOT NULL REFERENCES discharge_outcomes(discharge_outcome_id),
    decided_by           BIGINT NOT NULL REFERENCES staff(staff_id),
    decided_at           TIMESTAMPTZ NOT NULL,
    destination          VARCHAR(160),
    notes                TEXT
);
