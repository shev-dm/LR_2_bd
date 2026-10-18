CREATE TABLE hub_patient (
    patient_hk       CHAR(64) PRIMARY KEY,
    patient_bk       VARCHAR(30) NOT NULL UNIQUE, -- номер медицинской карты
    load_dts         TIMESTAMPTZ NOT NULL,
    record_source    VARCHAR(100) NOT NULL
);
 
CREATE TABLE hub_staff (
    staff_hk         CHAR(64) PRIMARY KEY,
    staff_bk         VARCHAR(40) NOT NULL UNIQUE, -- табельный номер
    load_dts         TIMESTAMPTZ NOT NULL,
    record_source    VARCHAR(100) NOT NULL
);
 
CREATE TABLE hub_department (
    department_hk    CHAR(64) PRIMARY KEY,
    department_bk    VARCHAR(40) NOT NULL UNIQUE, -- код подразделения
    load_dts         TIMESTAMPTZ NOT NULL,
    record_source    VARCHAR(100) NOT NULL
);
 
CREATE TABLE hub_visit (
    visit_hk         CHAR(64) PRIMARY KEY,
    visit_bk         VARCHAR(40) NOT NULL UNIQUE, -- номер обращения/случая
    load_dts         TIMESTAMPTZ NOT NULL,
    record_source    VARCHAR(100) NOT NULL
);
 
CREATE TABLE hub_diagnosis (
    diagnosis_hk     CHAR(64) PRIMARY KEY,
    diagnosis_bk     VARCHAR(20) NOT NULL UNIQUE, -- код диагноза
    load_dts         TIMESTAMPTZ NOT NULL,
    record_source    VARCHAR(100) NOT NULL
);
 
CREATE TABLE hub_bed (
    bed_hk           CHAR(64) PRIMARY KEY,
    bed_bk           VARCHAR(50) NOT NULL UNIQUE, -- код койки
    load_dts         TIMESTAMPTZ NOT NULL,
    record_source    VARCHAR(100) NOT NULL
);
 
CREATE TABLE link_visit_patient (
    visit_patient_lk CHAR(64) PRIMARY KEY,
    visit_hk         CHAR(64) NOT NULL REFERENCES hub_visit(visit_hk),
    patient_hk       CHAR(64) NOT NULL REFERENCES hub_patient(patient_hk),
    load_dts         TIMESTAMPTZ NOT NULL,
    record_source    VARCHAR(100) NOT NULL,
    UNIQUE (visit_hk, patient_hk)
);
 
CREATE TABLE link_visit_staff (
    visit_staff_lk  CHAR(64) PRIMARY KEY,
    visit_hk        CHAR(64) NOT NULL REFERENCES hub_visit(visit_hk),
    staff_hk        CHAR(64) NOT NULL REFERENCES hub_staff(staff_hk),
    staff_role      VARCHAR(50) NOT NULL, -- роль сотрудника в конкретном обращении
    load_dts        TIMESTAMPTZ NOT NULL,
    record_source   VARCHAR(100) NOT NULL,
    UNIQUE (visit_hk, staff_hk, staff_role)
);
 
CREATE TABLE link_visit_department (
    visit_department_lk CHAR(64) PRIMARY KEY,
    visit_hk            CHAR(64) NOT NULL REFERENCES hub_visit(visit_hk),
    department_hk       CHAR(64) NOT NULL REFERENCES hub_department(department_hk),
    load_dts             TIMESTAMPTZ NOT NULL,
    record_source        VARCHAR(100) NOT NULL,
    UNIQUE (visit_hk, department_hk)
);
 
CREATE TABLE link_visit_diagnosis (
    visit_diagnosis_lk CHAR(64) PRIMARY KEY,
    visit_hk           CHAR(64) NOT NULL REFERENCES hub_visit(visit_hk),
    diagnosis_hk       CHAR(64) NOT NULL REFERENCES hub_diagnosis(diagnosis_hk),
    load_dts            TIMESTAMPTZ NOT NULL,
    record_source       VARCHAR(100) NOT NULL,
    UNIQUE (visit_hk, diagnosis_hk)
);
 
CREATE TABLE link_visit_bed (
    visit_bed_lk CHAR(64) PRIMARY KEY,
    visit_hk     CHAR(64) NOT NULL REFERENCES hub_visit(visit_hk),
    bed_hk       CHAR(64) NOT NULL REFERENCES hub_bed(bed_hk),
    assigned_at  TIMESTAMPTZ NOT NULL, -- контекст связи/события
    load_dts     TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    UNIQUE (visit_hk, bed_hk, assigned_at)
);
 
CREATE TABLE sat_patient_profile (
    patient_hk      CHAR(64) NOT NULL REFERENCES hub_patient(patient_hk),
    load_dts        TIMESTAMPTZ NOT NULL,
    load_end_dts    TIMESTAMPTZ,
    hashdiff        CHAR(64) NOT NULL,
    last_name       VARCHAR(80) NOT NULL,
    first_name      VARCHAR(80) NOT NULL,
    middle_name     VARCHAR(80),
    birth_date      DATE,
    sex             VARCHAR(20),
    phone           VARCHAR(30),
    record_source   VARCHAR(100) NOT NULL,
    PRIMARY KEY (patient_hk, load_dts),
    CHECK (load_end_dts IS NULL OR load_end_dts > load_dts)
);
 
CREATE TABLE sat_staff_profile (
    staff_hk        CHAR(64) NOT NULL REFERENCES hub_staff(staff_hk),
    load_dts        TIMESTAMPTZ NOT NULL,
    load_end_dts    TIMESTAMPTZ,
    hashdiff        CHAR(64) NOT NULL,
    last_name       VARCHAR(80) NOT NULL,
    first_name      VARCHAR(80) NOT NULL,
    role_name       VARCHAR(80) NOT NULL,
    phone           VARCHAR(30),
    record_source   VARCHAR(100) NOT NULL,
    PRIMARY KEY (staff_hk, load_dts),
    CHECK (load_end_dts IS NULL OR load_end_dts > load_dts)
);
CREATE TABLE sat_visit_details (
    visit_hk        CHAR(64) NOT NULL REFERENCES hub_visit(visit_hk),
    load_dts        TIMESTAMPTZ NOT NULL,
    load_end_dts    TIMESTAMPTZ,
    hashdiff        CHAR(64) NOT NULL,
    received_at     TIMESTAMPTZ NOT NULL,
    complaint       TEXT NOT NULL,
    triage_level    VARCHAR(40),
    visit_status    VARCHAR(50),
    arrival_method  VARCHAR(60),
    ended_at        TIMESTAMPTZ,
    discharge_outcome VARCHAR(80),
    record_source   VARCHAR(100) NOT NULL,
    PRIMARY KEY (visit_hk, load_dts),
    CHECK (load_end_dts IS NULL OR load_end_dts > load_dts),
    CHECK (ended_at IS NULL OR ended_at >= received_at)
);
