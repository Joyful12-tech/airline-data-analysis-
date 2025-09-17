# ✈️ Airline Data Cleaning & Dashboard (MySQL + Tableau)

## 📌 Project Overview
This project focuses on cleaning, analyzing, and visualizing airline data 
using **MySQL** for data preparation and **Tableau** for visualization.  
The goal is to uncover insights into flight operations, passenger demographics, 
and revenue performance.

---

## 🗂 Dataset
The project simulates real-world airline data, split into three main tables:
- **Flights** → flight schedules, airline, origin, destination, status
- **Passengers** → passenger demographics (age, gender, nationality)
- **Bookings** → ticket purchases, prices, seat classes, booking date

After cleaning, the tables were joined into a master dataset for analysis.

---

## 🔧 Data Cleaning Process (MySQL)
Steps taken:
1. Removed duplicates across all tables
2. Standardized airline names (e.g., “DELTA”, “Delta Airlines” → “Delta”)
3. Fixed null values:
   - Filled missing **ages** with average values
   - Set missing **arrival times** based on departure + 2 hrs
4. Checked and removed orphaned references in bookings
5. Ensured valid ranges:
   - Age between 5 and 100
   - Ticket price > 0
6. Converted **booking_date** from text → proper DATETIME

---

## 📊 KPIs
Key performance indicators calculated:
- 💰 **Total Revenue** = `SUM(price)`
- 👥 **Total Passengers** = `COUNT(DISTINCT passenger_id)`
- ✈️ **Total Flights** = `COUNT(DISTINCT flight_id)`
- ⏱ **On-time Performance** = `% flights with status = 'On Time'`
- 🎟 **Average Ticket Price** = `AVG(price)`

---

## 📈 Visualizations (Tableau)
1. **Revenue by Airline** → Bar chart with airline filter
2. **Passenger Age Distribution** → Histogram with gender comparison
3. **Flight Punctuality** → Donut chart (On-time, Delayed, Cancelled)
4. **Revenue by Route** → Bar chart of top 10 origin-destination pairs
5. **Monthly Revenue Trend** → Line chart with airline filter

📌 Interactivity: Filters for airline, route, and seat class

---

## 📂 Project Structure
- `data/` → Clean datasets (CSV)
- `sql/` → SQL cleaning scripts
- `tableau/` → Tableau dashboard
- `images/` → Dashboard screenshots
- `README.md` → Documentation


---

## 🚀 Tools Used
- **MySQL** → Data cleaning & preparation
- **Tableau** → Dashboard & visualizations
- **GitHub** → Documentation & portfolio

---

## 📷 Dashboard Preview
![airline dasboard](https://github.com/user-attachments/assets/20848faf-7c83-45f0-a6a2-ccbdb74f889f)



