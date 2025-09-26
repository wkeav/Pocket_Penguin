
from datetime import date


streak = 0
last_active = None

def update_streak():
    global streak, last_active
    today = date.today()

    if last_active == today:
        return streak 
    elif last_active == None or (today - last_active).days > 1:
        streak = 1  
    else:
        streak += 1  

    last_active = today
    return streak

print("Today's streak:", update_streak())
