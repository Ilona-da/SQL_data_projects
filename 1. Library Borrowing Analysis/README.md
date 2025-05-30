### Library Borrowing Analysis

**Goal:** Explore library borrowing data based on specific questions about readers activity, popularity of books, seasonal trends in borrowings etc.

**Data:** Data consists of two dimension tables: Books (BookID, Title, Author, Genre, PublishedYear, Price) and Members (MemberID, FirstName, LastName, JoinDate, Membership), as well as single facts table: BorrowedBooks (BorrowID, MemberID, BookID, BorrowDate, ReturnDate).

**Challenges:** The dataset contained incorrect dates (e.g., users borrowing books before joining the library).
It was technically clean in terms of data types, formatting, and missing values. However, upon closer inspection, some records lacked logical consistency. For example it looked like some users borrowed books before their registration date (for many records). These issues made the dataset a great practice ground for data validation rather than standard exploratory analysis. As a result, the project primarily focused on SQL practice and anomaly detection, rather than deriving actionable insights.

**Project file**: `sql_library_analysis.sql`
**Project raw data**: 'Raw data files' folder

