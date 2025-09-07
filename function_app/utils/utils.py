import os
import hashlib
import hmac
import base64
import time
import jwt

# ============================
# Constants
# ============================
DB_URL = os.getenv(
    "DB_URL",
    "postgresql://user:password@localhost:5432/mydatabase"
)
SECRET_KEY = os.getenv("SECRET_KEY", "super-secret-key")
TOKEN_EXP_SECONDS = 3600  # 1h

# ============================
# Password utilities
# ============================
def hash_pw(password: str, salt: str = None) -> str:
    """Hash password with SHA256 + salt."""
    if not salt:
        salt = base64.urlsafe_b64encode(os.urandom(16)).decode()
    pwd_bytes = password.encode("utf-8")
    salt_bytes = salt.encode("utf-8")
    hashed = hashlib.pbkdf2_hmac("sha256", pwd_bytes, salt_bytes, 100000)
    return f"{salt}${base64.urlsafe_b64encode(hashed).decode()}"


def verify_pw(password: str, hashed_value: str) -> bool:
    """Verify a password against stored salt+hash."""
    try:
        salt, hash_b64 = hashed_value.split("$")
        pwd_bytes = password.encode("utf-8")
        salt_bytes = salt.encode("utf-8")
        new_hash = hashlib.pbkdf2_hmac("sha256", pwd_bytes, salt_bytes, 100000)
        return hmac.compare_digest(
            base64.urlsafe_b64encode(new_hash).decode(), hash_b64
        )
    except Exception:
        return False

# ============================
# Token utilities (JWT)
# ============================
def generate_token(user_id: str) -> str:
    """Generate a JWT for a user."""
    payload = {
        "sub": user_id,
        "exp": int(time.time()) + TOKEN_EXP_SECONDS,
    }
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")


def verify_token(token: str):
    """Verify JWT and return payload if valid."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None
