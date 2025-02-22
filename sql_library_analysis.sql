USE library_database

-- 1) USERS

-- Sum of books borrowed by each membership type

SELECT t2.MembershipType, COUNT(t1.BorrowID) AS CountOfBorrows
FROM BorrowedBooks t1 
	JOIN Members t1 ON t1.MemberID = t2.MemberID
GROUP BY t2.MembershipType
ORDER BY CountOfBorrows DESC

-- Find 10 top readers

SELECT TOP 10  FirstName, LastName, MembershipType, BorrowsCount
FROM (
	SELECT MemberID, COUNT(BorrowID) as BorrowsCount
	FROM BorrowedBooks
	GROUP BY MemberID
	) t1
	JOIN Members t2 ON t1.MemberID = t2.MemberID
ORDER BY BorrowsCount DESC

-- Find readers who borrowed less than 3 books

WITH MembersWithBooks AS (
	SELECT MemberID, COUNT(DISTINCT BookID) AS HowManyBooksBorrowed
	FROM BorrowedBooks
	GROUP BY MemberID)

SELECT t1.MemberID, FirstName, LastName, HowManyBooksBorrowed
FROM MembersWithBooks t1
	JOIN Members t2 ON t1.MemberID = t2.MemberID
WHERE HowManyBooksBorrowed < 3
ORDER BY HowManyBooksBorrowed ASC

-- Find reader who didn't give back the books

SELECT DISTINCT t1.MemberID, t2.FirstName AS BadBorrowerFirstName, t2.LastName AS BadBorrowerLastName
FROM BorrowedBooks t1
JOIN Members t2 ON t1.MemberID = t2.MemberID
WHERE t1.ReturnDate IS NULL

-- Classify readers by year of joining 

ALTER TABLE Members
ADD MemberStatus NVARCHAR(50)

UPDATE Members
SET MemberStatus = 
	CASE 
		WHEN JoinDate >= DATEADD(YEAR, -1, GETDATE()) THEN 'New'
		ELSE 'Regular'
	END

-- Readers who joined in the last three months

SELECT * FROM Members
WHERE JoinDate >= DATEADD(MONTH, -3, GETDATE())
ORDER BY JoinDate DESC

-- Find most active readers (who borrow books at least once per 2 months)

WITH BorrowedBooksWithLag AS (
	SELECT MemberID, BorrowDate, LAG(BorrowDate) OVER(PARTITION BY MemberID ORDER BY BorrowDate) AS PreviousBorrowDate
	FROM BorrowedBooks),
	BorrowedBooksWithGap AS (
	SELECT MemberID, BorrowDate, PreviousBorrowDate, DATEDIFF(DAY, PreviousBorrowDate, BorrowDate) AS DaysBetween
	FROM BorrowedBooksWithLag
	WHERE PreviousBorrowDate IS NOT NULL)

SELECT DISTINCT MemberID
FROM BorrowedBooksWithGap
GROUP BY MemberID
HAVING AVG(DaysBetween) >= 60

-- Check date inconsistency

WITH CheckDates AS (
	SELECT t1.MemberID, t2.JoinDate, MIN(t1.BorrowDate) AS FirstBorrowDate
	FROM BorrowedBooks t1 
	JOIN Members t2 ON t1.MemberID = t2.MemberID
	GROUP BY t1.MemberID, t2.JoinDate)

SELECT * FROM checkDates
WHERE FirstBorrowDate < JoinDate

-- 2) BOOKS

-- Number of days while each book was borrowed (also books not returned)

WITH BorrowWithTime AS (
SELECT *,
	CASE 
		WHEN ReturnDate IS NOT NULL THEN DATEDIFF(DAY, BorrowDate, ReturnDate)
		ELSE DATEDIFF(DAY, BorrowDate, CAST(GETDATE() AS DATE))
	 END AS BorrowDays
FROM BorrowedBooks)

-- Average book loan duration (in days)

SELECT AVG(DATEDIFF(DAY, BorrowDate, ReturnDate))
FROM BorrowWithTime
WHERE ReturnDate IS NOT NULL

SELECT t1.BookID, t1.Title, t1.Author, t1.Genre, SUM(t2.BorrowDays) AS BorrowDays
FROM Books t1
	JOIN BorrowWithTime t2 ON t2.BookID = t1.BookID
GROUP BY t1.BookID, t1.Title, t1.Author, t1.Genre
ORDER BY BorrowDays DESC

-- Median number of loan days

SELECT TOP 1
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY BorrowDays) OVER () AS MedianBorrowDays
FROM BorrowWithTime
WHERE ReturnDate IS NOT NULL

-- Check sum of book prices by the genre

SELECT Genre, SUM(Price) AS TotalPrice
FROM Books
GROUP BY Genre
ORDER BY TotalPrice DESC

-- Add column that classifies books by its price

ALTER TABLE Books
ADD BookValue NVARCHAR(50)

UPDATE Books
SET BookValue =
	CASE
		WHEN Price < 10 THEN 'Low'
		WHEN Price >= 10 AND Price < 30 THEN 'Medium'
		WHEN Price  >= 30 THEN 'High'
	END

SELECT COUNT(BookValue)
FROM Books
WHERE BookValue = 'High'

-- Books that have been borrowed the longest (per days)

WITH BooksStillBorrowed AS (
	SELECT BookID, DATEDIFF(DAY, BorrowDate, CAST(GETDATE() AS DATE)) AS DaysFromBorrow
	FROM BorrowedBooks
	WHERE ReturnDate IS NULL)

SELECT t1.BookID, Title, DaysFromBorrow
FROM BooksStillBorrowed t1
	JOIN Books t2 ON t1.BookID = t2.BookID
ORDER BY DaysFromBorrow DESC

-- Most borrowed books

SELECT t1.BookID, t2.Title, COUNT(t1.BookID) AS BookPopularityRate
FROM BorrowedBooks t1
JOIN Books t2 ON t1.BookID = t2.BookID
GROUP BY t1.BookID, t2.Title
ORDER BY BookPopularityRate DESC

-- Books popularity by the genre

WITH GenreByPopularity AS (
    SELECT Genre, COUNT(*) AS GenrePopularity
    FROM BorrowedBooks t1
    JOIN Books t2 ON t1.BookID = t2.BookID
    GROUP BY Genre),
	RankedGenres AS (
    SELECT Genre, GenrePopularity,
      DENSE_RANK() OVER (ORDER BY GenrePopularity DESC) AS PopularityRank
    FROM GenreByPopularity)

SELECT Genre, GenrePopularity, PopularityRank
FROM RankedGenres
WHERE PopularityRank <= 10
ORDER BY PopularityRank

-- Popularity of older books

SELECT COUNT(t1.BookID)
FROM BorrowedBooks t1
JOIN Books t2 ON t1.BookID = t2.BookID
WHERE PublishedYear < 1970

-- 3) TIME TRENDS

-- Time trends in borrowings

SELECT YEAR(BorrowDate) AS BorrowYear, MONTH(BorrowDate) AS BorrowMonth, COUNT(*) AS TotalBorrows
FROM BorrowedBooks
GROUP BY YEAR(BorrowDate), MONTH(BorrowDate)
ORDER BY BorrowYear, BorrowMonth

