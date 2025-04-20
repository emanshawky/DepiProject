import os
from flask import Flask, render_template, request, redirect, jsonify
import sqlite3

# Initialize Flask App
app = Flask(__name__)

# Update this to use a mounted volume
db_path = os.path.join(os.getenv("DB_PATH", "/flask-data"), "expenses.db")

# Initialize database and tables
def init_db():
    print("***** START init_db *****")  # New
    print(f"Database path: {db_path}")  # Important!    
    db_dir = os.path.dirname(db_path)
    if not os.path.exists(db_dir):
        os.makedirs(db_dir)
        print(f"Created directory: {db_dir}")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute('''CREATE TABLE IF NOT EXISTS expenses (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        description TEXT NOT NULL,
                        category TEXT NOT NULL,
                        amount REAL NOT NULL,
                        date TEXT NOT NULL
                    )''')
    cursor.execute('''CREATE TABLE IF NOT EXISTS earnings (
                        id INTEGER PRIMARY KEY CHECK (id = 1),
                        amount REAL NOT NULL
                    )''')
    cursor.execute("SELECT COUNT(*) FROM earnings")
    if cursor.fetchone()[0] == 0:
        cursor.execute("INSERT INTO earnings (id, amount) VALUES (1, 0.0)")
    conn.commit()
    conn.close()
    print("***** END init_db *****")

@app.route("/")
def index():
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM expenses")
    rows = cursor.fetchall()
    conn.close()
    return render_template("index.html", expenses=rows)

@app.route("/add", methods=["GET", "POST"])
def add_expense():
    if request.method == "POST":
        description = request.form["description"]
        category = request.form["category"]
        amount = request.form["amount"]
        date = request.form["date"]
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("INSERT INTO expenses (description, category, amount, date) VALUES (?, ?, ?, ?)",
                       (description, category, amount, date))
        conn.commit()
        conn.close()
        return redirect("/")
    return render_template("add_expense.html")

@app.route("/delete/<int:id>", methods=["POST"])
def delete_expense(id):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM expenses WHERE id = ?", (id,))
    conn.commit()
    conn.close()
    return redirect("/")


@app.route("/analysis", methods=["GET", "POST"])
def analysis():
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Update earnings if submitted
    if request.method == "POST":
        amount = request.form.get("amount")
        if amount:
            cursor.execute("UPDATE earnings SET amount = ? WHERE id = 1", (amount,))
            conn.commit()

    # Category breakdown
    cursor.execute("SELECT category, SUM(amount) FROM expenses GROUP BY category")
    data = cursor.fetchall()

    # Total spent
    cursor.execute("SELECT SUM(amount) FROM expenses")
    total_spent = cursor.fetchone()[0] or 0.0

    # Total earnings
    cursor.execute("SELECT amount FROM earnings WHERE id = 1")
    total_earning = cursor.fetchone()[0] or 0.0

    balance = total_earning - total_spent

    conn.close()
    return render_template("analysis.html", 
                           data=data, 
                           total_spent=total_spent,
                           total_earning=total_earning,
                           balance=balance)

if __name__ == "__main__":
    print("***** BEFORE init_db *****")
    init_db()
    print("***** AFTER init_db *****") # New
    app.run(host="0.0.0.0", port=8080, debug=True)

