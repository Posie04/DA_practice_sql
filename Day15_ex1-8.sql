--ex1
SELECT 
extract (year from transaction_date) as yr,
product_id, 
spend as curr_year_spend,
lag(spend) over(PARTITION BY product_id order by transaction_date) as prev_year_spend,
Round((spend-lag(spend) over(PARTITION BY product_id order by transaction_date))*100
/lag(spend) over(PARTITION BY product_id order by transaction_date),2) as yoy_rate
FROM user_transactions

--ex2
select card_name, issued_amount from 
((SELECT card_name,issue_month,issue_year,issued_amount,
row_number() over(partition by card_name order by issue_year) as rank
FROM monthly_cards_issued)) as a
where rank=1
order by issued_amount DESC

--ex3
select user_id,spend, transaction_date FROM
(SELECT user_id,spend, transaction_date,
rank() over(partition by user_id ORDER BY transaction_date)
FROM transactions) as A
where rank=3

--ex4
SELECT 
  transaction_date, 
  user_id,
  COUNT(product_id) AS purchase_count
FROM 
  (select 
    transaction_date, 
    user_id, 
    product_id, 
    RANK() OVER (
      PARTITION BY user_id 
      ORDER BY transaction_date DESC) AS transaction_rank 
  FROM user_transactions) as a
WHERE transaction_rank = 1 
GROUP BY transaction_date, user_id
ORDER BY transaction_date;

--ex5
SELECT    
  user_id,    
  tweet_date,   
  ROUND(AVG(tweet_count) OVER (
    PARTITION BY user_id     
    ORDER BY tweet_date     
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) --- đẩy dòng lên/xuống n hàng
  ,2) AS rolling_avg_3d
FROM tweets;

-- ex5: hoặc dùng hàm lag/lead đẩy lên/ xuống

--ex6
WITH payments AS (
  SELECT 
    merchant_id, 
    EXTRACT(EPOCH FROM transaction_timestamp - 
      LAG(transaction_timestamp) OVER(
        PARTITION BY merchant_id, credit_card_id, amount 
        ORDER BY transaction_timestamp)
    )/60 AS minute_difference 
  FROM transactions) 

SELECT COUNT(merchant_id) AS payment_count
FROM payments 
WHERE minute_difference <= 10;

--ex7
SELECT 
  category, 
  product, 
  total_spend 
FROM (
  SELECT 
    category, 
    product, 
    SUM(spend) AS total_spend,
    RANK() OVER (
      PARTITION BY category 
      ORDER BY SUM(spend) DESC) AS ranking 
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
) AS ranked_spending
WHERE ranking <= 2 
ORDER BY category, ranking;

--ex8
WITH top_10_cte AS (
  SELECT 
    artists.artist_name,
    DENSE_RANK() OVER (
      ORDER BY COUNT(songs.song_id) DESC) AS artist_rank
  FROM artists
  INNER JOIN songs
    ON artists.artist_id = songs.artist_id
  INNER JOIN global_song_rank AS ranking
    ON songs.song_id = ranking.song_id
  WHERE ranking.rank <= 10
  GROUP BY artists.artist_name
)

SELECT artist_name, artist_rank
FROM top_10_cte
WHERE artist_rank <= 5;
