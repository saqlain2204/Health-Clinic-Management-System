import streamlit as st
from datetime import datetime, date
import database as db
import pandas as pd
import department

# function to verify doctor id
def verify_doctor_id(doctor_id):
    conn, c = db.connection()
    with conn:
        c.execute("SELECT id FROM doctor_record WHERE id = ?", (doctor_id,))
        result = c.fetchone()
    conn.close()
    return result is not None

# function to show doctor details
def show_doctor_details(doctors):
    doctor_titles = [
        'Doctor ID', 'Name', 'Age', 'Gender', 'Date of birth (DD-MM-YYYY)',
        'Blood group', 'Department ID', 'Department name', 'Contact number',
        'Alternate contact number', 'Aadhar ID / Voter ID', 'Email ID',
        'Qualification', 'Specialisation', 'Years of experience', 'Address',
        'City', 'State', 'PIN code'
    ]
    if not doctors:
        st.warning('No data to show')
    else:
        df = pd.DataFrame(doctors, columns=doctor_titles)
        st.write(df)

# function to calculate age
def calculate_age(dob):
    today = date.today()
    return today.year - dob.year - ((dob.month, dob.day) > (today.month, today.day))

# function to generate unique doctor id
def generate_doctor_id():
    return f'DR-{datetime.now().strftime("%H%M-%d%m%y")}'

# function to fetch department name from the database
def get_department_name(dept_id):
    conn, c = db.connection()
    with conn:
        c.execute("SELECT name FROM department_record WHERE id = ?", (dept_id,))
        result = c.fetchone()
    conn.close()
    return result[0] if result else None

class Doctor:
    def __init__(self):
        self.clear_fields()

    def clear_fields(self):
        self.name = self.id = self.gender = self.date_of_birth = self.blood_group = ""
        self.department_id = self.department_name = self.contact_number_1 = ""
        self.contact_number_2 = self.aadhar_or_voter_id = self.email_id = ""
        self.qualification = self.specialisation = self.address = ""
        self.city = self.state = self.pin_code = ""
        self.age = self.years_of_experience = 0

    # add new doctor record
    def add_doctor(self):
        self.name = st.text_input('Full name')
        self.gender = st.radio('Gender', ['Female', 'Male', 'Other'])
        self.date_of_birth = st.date_input('Date of birth').strftime('%d-%m-%Y')
        self.age = calculate_age(datetime.strptime(self.date_of_birth, '%d-%m-%Y'))
        self.blood_group = st.text_input('Blood group')

        dept_id = st.text_input('Department ID')
        if department.verify_department_id(dept_id):
            self.department_id = dept_id
            self.department_name = get_department_name(dept_id)
            st.success('Verified')
        else:
            st.error('Invalid Department ID')
            return

        self.contact_number_1 = st.text_input('Contact number')
        self.contact_number_2 = st.text_input('Alternate contact number (optional)')
        self.aadhar_or_voter_id = st.text_input('Aadhar ID / Voter ID')
        self.email_id = st.text_input('Email ID')
        self.qualification = st.text_input('Qualification')
        self.specialisation = st.text_input('Specialisation')
        self.years_of_experience = st.number_input('Years of experience', min_value=0, max_value=100)
        self.address = st.text_area('Address')
        self.city = st.text_input('City')
        self.state = st.text_input('State')
        self.pin_code = st.text_input('PIN code')
        self.id = generate_doctor_id()
        save = st.button('Save')

        if save:
            conn, c = db.connection()
            with conn:
                c.execute(
                    """
                    INSERT INTO doctor_record (
                        id, name, age, gender, date_of_birth, blood_group,
                        department_id, department_name, contact_number_1,
                        contact_number_2, aadhar_or_voter_id, email_id,
                        qualification, specialisation, years_of_experience,
                        address, city, state, pin_code
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        self.id, self.name, self.age, self.gender, self.date_of_birth,
                        self.blood_group, self.department_id, self.department_name,
                        self.contact_number_1, self.contact_number_2, self.aadhar_or_voter_id,
                        self.email_id, self.qualification, self.specialisation,
                        self.years_of_experience, self.address, self.city,
                        self.state, self.pin_code
                    )
                )
            st.success(f'Doctor details saved successfully. Your Doctor ID is: {self.id}')
            conn.close()

    # update existing doctor record
    def update_doctor(self):
        doctor_id = st.text_input('Enter Doctor ID of the doctor to be updated')
        if not verify_doctor_id(doctor_id):
            st.error('Invalid Doctor ID')
            return
        st.success('Verified')

        conn, c = db.connection()
        with conn:
            c.execute("SELECT * FROM doctor_record WHERE id = ?", (doctor_id,))
            show_doctor_details([c.fetchone()])

        st.write('Enter new details of the doctor:')
        self.fill_fields()
        update = st.button('Update')

        if update:
            with conn:
                c.execute(
                    """
                    UPDATE doctor_record SET age = ?, department_id = ?, department_name = ?,
                    contact_number_1 = ?, contact_number_2 = ?, email_id = ?, qualification = ?,
                    specialisation = ?, years_of_experience = ?, address = ?, city = ?, state = ?, pin_code = ?
                    WHERE id = ?
                    """,
                    (
                        self.age, self.department_id, self.department_name, self.contact_number_1,
                        self.contact_number_2, self.email_id, self.qualification, self.specialisation,
                        self.years_of_experience, self.address, self.city, self.state,
                        self.pin_code, doctor_id
                    )
                )
            st.success('Doctor details updated successfully.')
            conn.close()

    # delete doctor record
    def delete_doctor(self):
        doctor_id = st.text_input('Enter Doctor ID of the doctor to be deleted')
        if not verify_doctor_id(doctor_id):
            st.error('Invalid Doctor ID')
            return
        st.success('Verified')

        conn, c = db.connection()
        with conn:
            c.execute("SELECT * FROM doctor_record WHERE id = ?", (doctor_id,))
            show_doctor_details([c.fetchone()])

            if st.checkbox('Check this box to confirm deletion') and st.button('Delete'):
                c.execute("DELETE FROM doctor_record WHERE id = ?", (doctor_id,))
                st.success('Doctor details deleted successfully.')
        conn.close()

    # display all doctor records
    def show_all_doctors(self):
        conn, c = db.connection()
        with conn:
            c.execute("SELECT * FROM doctor_record")
            show_doctor_details(c.fetchall())
        conn.close()

    # search doctor record by ID
    def search_doctor(self):
        doctor_id = st.text_input('Enter Doctor ID of the doctor to be searched')
        if not verify_doctor_id(doctor_id):
            st.error('Invalid Doctor ID')
            return
        st.success('Verified')

        conn, c = db.connection()
        with conn:
            c.execute("SELECT * FROM doctor_record WHERE id = ?", (doctor_id,))
            show_doctor_details([c.fetchone()])
        conn.close()
