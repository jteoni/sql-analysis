WITH SalesData AS (
    SELECT 
        a.Name AS artist,
        g.Name AS genre,
        SUM(il.UnitPrice * il.Quantity) AS sales
    FROM 
        InvoiceLine il
        JOIN Track t ON il.TrackId = t.TrackId
        JOIN Genre g ON t.GenreId = g.GenreId
        JOIN Album al ON t.AlbumId = al.AlbumId
        JOIN Artist a ON al.ArtistId = a.ArtistId
    GROUP BY 
        a.Name, g.Name
),

GenreTotals AS (
    SELECT 
        genre,
        SUM(sales) AS total_sales_by_genre
    FROM 
        SalesData
    GROUP BY 
        genre
),

SalesWithPercentages AS (
    SELECT
        sd.artist,
        sd.genre,
        sd.sales,
        (sd.sales / gt.total_sales_by_genre) * 100 AS sales_percentage_by_genre
    FROM
        SalesData sd
        JOIN GenreTotals gt ON sd.genre = gt.genre
),

SalesWithCumulative AS (
    SELECT 
        artist,
        genre,
        sales,
        sales_percentage_by_genre,
        SUM(sales_percentage_by_genre) OVER (PARTITION BY genre ORDER BY sales_percentage_by_genre DESC) AS cumulative_sum_by_genre
    FROM 
        SalesWithPercentages
)

SELECT 
    artist,
    genre,
    sales,
    ROUND(sales_percentage_by_genre, 1) AS sales_percentage_by_genre,
    ROUND(cumulative_sum_by_genre, 1) AS cumulative_sum_by_genre
FROM 
    SalesWithCumulative
ORDER BY 
    genre ASC,
    sales_percentage_by_genre DESC
LIMIT 10;
