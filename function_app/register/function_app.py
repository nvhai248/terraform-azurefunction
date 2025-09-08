import logging
import json
import psycopg2
import azure.functions as func

from __app__.utils.utils import hash_pw, generate_token, DB_URL


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Processing register request...")

    try:
        body = req.get_json()
    except ValueError:
        return func.HttpResponse(
            json.dumps({"error": "Invalid JSON"}),
            status_code=400,
            mimetype="application/json"
        )

    username = body.get("username")
    password = body.get("password")
    email = body.get("email")

    if not username or not password or not email:
        return func.HttpResponse(
            json.dumps({"error": "username, password, email required"}),
            status_code=400,
            mimetype="application/json"
        )

    try:
        conn = psycopg2.connect(DB_URL)
        cur = conn.cursor()

        # Check if user exists
        cur.execute("SELECT 1 FROM users WHERE username = %s", (username,))
        if cur.fetchone():
            return func.HttpResponse(
                json.dumps({"error": "User already exists"}),
                status_code=409,
                mimetype="application/json"
            )

        # Hash password
        hashed = hash_pw(password)

        # Insert new user
        cur.execute(
            "INSERT INTO users (username, email, password) VALUES (%s, %s, %s)",
            (username, email, hashed)
        )
        conn.commit()

        # Generate token
        token = generate_token(username)

        return func.HttpResponse(
            json.dumps({"message": "User registered", "token": token}),
            status_code=201,
            mimetype="application/json"
        )
    except Exception as e:
        logging.error(str(e))
        return func.HttpResponse(
            json.dumps({"error": "Server error"}),
            status_code=500,
            mimetype="application/json"
        )
    finally:
        if 'cur' in locals():
            cur.close()
        if 'conn' in locals():
            conn.close()
