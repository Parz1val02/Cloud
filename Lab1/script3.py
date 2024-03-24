import smtplib

# list of email_id to send the mail
li = ["email1", "email2"]

for dest in li:
    s = smtplib.SMTP("smtp.gmail.com", 587)
    s.starttls()
    s.login("sender_email", "application_password")
    NombreDelAlumno = "owo"
    message = f"¡{NombreDelAlumno}, bienvenido al curso de Ingeniería de Redes Cloud 2024-1!\nAtte. César Santivañez".encode(
        "UTF-8"
    )
    s.sendmail("sender_email", dest, message)
    s.quit()
