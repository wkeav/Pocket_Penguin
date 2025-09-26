from datetime import date

# temporary in-memory user data
user_data = {"streak": 0, "last_active": None}

def update_streak():
    today = date.today()
    last = user_data["last_active"]

    if last is None:
        user_data["streak"] = 1
    else:
        days = (today - last).days
        if days == 1:
            user_data["streak"] += 1
        elif days > 1:
            user_data["streak"] = 1

    user_data["last_active"] = today
    return user_data["streak"]
