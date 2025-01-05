from flask import Flask, render_template, request, redirect, url_for, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("login.html")

@app.route("/login", methods=["POST"])
def login():
    username = request.form.get("username")
    password = request.form.get("password")
    
    if username == "admin@gmail.com" and password == "password":
        return redirect(url_for("dashboard"))
    else:
        return render_template("login.html", error="Invalid credentials")

@app.route("/dashboard")
def dashboard():
    return render_template("dashboard.html")

@app.route("/form")
def form():
    return render_template("form.html")


@app.route("/submit", methods=["POST"])
def submit():
    form_data = request.form.to_dict()
    print(form_data)
    return jsonify({"message": "Form submitted successfully!", "data": form_data})

if __name__ == "__main__":
    app.run(debug=True)