# SQL data projects

This repository contains small SQL projects focused on Exploratory Data Analysis (EDA), data cleaning, and SQL-based insights. It serves as a personal learning space where I analyze different datasets, experiment with SQL techniques, and explore real-world data challenges.

Not all projects here are perfect - some datasets contained logical inconsistencies or unrealistic records, making them a great learning experience in data validation and anomaly detection.

## Projects Included

### 1. Library Borrowing Analysis

**Goal:** Explore library borrowing data based on specific questions about readers activity, popularity of books, seasonal trends in borrowings etc.
**Data:** Data consists of two dimension tables: Books (BookID, Title, Author, Genre, PublishedYear, Price) and Members (MemberID, FirstName, LastName, JoinDate, Membership), as well as single facts table: BorrowedBooks (BorrowID, MemberID, BookID, BorrowDate, ReturnDate).
**Challenges:** The dataset contained incorrect dates (e.g., users borrowing books before joining the library).
It was technically clean in terms of data types, formatting, and missing values. However, upon closer inspection, some records lacked logical consistency. For example it looked like some users borrowed books before their registration date (for many records). These issues made the dataset a great practice ground for data validation rather than standard exploratory analysis. As a result, the project primarily focused on SQL practice and anomaly detection, rather than deriving actionable insights.
**File**: sql_library_analysis.sql

