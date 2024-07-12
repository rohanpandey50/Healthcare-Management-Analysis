create database healthcare_management;
use healthcare_management;
create table patient(patient_id int primary key,
                      first_name varchar(20),
                      last_name varchar(20),
                      gender varchar(3),
                      dob date,
                      phone_no varchar(10),
                      email varchar(100),
                      address varchar(100));

create table doctor (doctor_id int primary key,
					 first_name varchar(20),
					 last_name varchar(20),
                     specialty varchar(30),
                     phone_no varchar(10),
                     email varchar(100),
					 address varchar(100));
                     
create table appointment(appointment_id int primary key,
					     patient_id int,
                         doctor_id int,
                         appointment_date date,
                         reason varchar(50),
					     foreign key (patient_id) references patient(patient_id),
					     foreign key (doctor_id) references doctor(doctor_id));

create table medical_records(record_id int primary key,
							patient_id int,
							doctor_id int,
                            appointment_id int,
                            diagnosis varchar(50),
                            treatment varchar(50),
                            foreign key(patient_id) references patient(patient_id),
                            foreign key(doctor_id) references doctor(doctor_id),
                            foreign key(appointment_id) references appointment(appointment_id));
             
select * from patient;
select * from doctor;
select * from appointment;
select * from medical_records;

-- Total number of appointments
select count(*) as total_appointment from appointment;

-- Total number of patients
select count(*) as total_patient from patient;

-- Total number of doctors
select count(*) as total_doctor from doctor;

-- Number of appointments per doctor
select d.first_name,d.last_name,count(a.appointment_id) as appointment_count
from doctor d
inner join appointment a
on d.doctor_id=a.doctor_id
group by d.doctor_id,d.first_name,d.last_name;

-- Doctor with the most appointments
select d.doctor_id,d.first_name,d.last_name,count(a.appointment_id) as appointments
from doctor d
inner join appointment a
on d.doctor_id=a.doctor_id
group by d.doctor_id,d.first_name,d.last_name
order by appointments desc
limit 1;

-- Number of appointments per patient
select p.patient_id,first_name,p.last_name,count(a.appointment_id) as appointment_count
from patient p
inner join appointment a
on p.patient_id=a.patient_id
group by p.patient_id, p.first_name,p.last_name;

-- Most common reason for appointments
select reason,count(*) as frequency
from appointment
group by reason
order by frequency desc
limit 1;

-- Most common diagnosis
select diagnosis,count(*) as frequency
from medical_records
group by diagnosis
order by frequency desc
limit 1;

-- Most common treatment
select treatment,count(*) as frequency
from medical_records
group by treatment
order by frequency desc
limit 1;

-- Average number of appointments per patient
select avg(t.appointment_count) as avg_appointment_per_patient
from(select patient_id,count(appointment_id) as appointment_count
from appointment
group by patient_id) t;

-- Average number of appointments per doctor
select avg(t.appointment_number) as avg_appointment_per_doctor
from(select doctor_id,count(appointment_id) as appointment_number
from appointment
group by doctor_id) t;

-- Patient with the most appointments
select p.patient_id,p.first_name,p.last_name,count(a.appointment_id) as appointment_count
from patient p
inner join appointment a
on p.patient_id=a.patient_id
group by p.patient_id,p.first_name,p.last_name
order by appointment_count desc
limit 1;

-- Doctor with the most appointments
select d.doctor_id,d.first_name,d.last_name,count(a.appointment_id) as appointment_count
from doctor d
inner join appointment a
on d.doctor_id=a.doctor_id
group by d.doctor_id,d.first_name,d.last_name
order by appointment_count desc
limit 1;

-- Number of male and female patients
select gender,count(*) as patients_count
from patient
group by gender;

-- Average age of patients
select round(avg(timestampdiff(year,dob,curdate())),2) as avg_age
from patient;

-- Number of appointments by month
select monthname(appointment_date) as months,count(appointment_id) as appointment_count
from appointment
group by months;

-- Number of appointments by year
select year(appointment_date) as years,count(*) as appointment_count
from appointment
group by years
order by appointment_count;

-- List of all Doctors specializing in their specific field 
select group_concat(first_name," ",last_name separator",") as doctor_name ,specialty
from doctor
group by specialty;

--  Number of unique patients seen by each doctor
select d.doctor_id,d.first_name,d.last_name,count(distinct a.patient_id) as unique_patients
from doctor d
inner join appointment a
on d.doctor_id=a.doctor_id
group by d.doctor_id,d.first_name,d.last_name;

-- Number of medical records per patient
select p.patient_id,p.first_name,p.last_name,count(m.record_id) as medical_records
from patient p
inner join medical_records m
on p.patient_id=m.patient_id
group by p.patient_id,p.first_name,p.last_name;

-- Most common diagnosis by gender
with cte as
(select p.gender,m.diagnosis,count(*) as common_diagnosis_count,dense_rank() over(partition by p.gender order by count(*) desc) as common_diagnosis_rank,
case
when p.gender='M' and dense_rank() over(partition by p.gender order by count(*) desc) =1 then 'most common diagnosis of men'
when p.gender='F' and dense_rank() over(partition by p.gender order by count(*) desc) =1 then 'most common diagnosis of female'
else null
end as common_diagnosis
from patient p
inner join medical_records m
on p.patient_id=m.patient_id
group by p.gender,m.diagnosis)
select gender,diagnosis,common_diagnosis_count,common_diagnosis
from cte
where common_diagnosis_rank=1;

--  Total number of appointments in the current year
select count(*) as appointment_number
from appointment
where year(appointment_date)=year(curdate());

-- Patients with more than one appointment on the same day
select p.patient_id,p.first_name,p.last_name,a.appointment_date, count(a.appointment_id) as appointment_count
from patient p
inner join appointment a
on p.patient_id=a.patient_id
group by p.patient_id,p.first_name,p.last_name,a.appointment_date
having appointment_count>1;








