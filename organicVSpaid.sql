WITH organic AS
        (SELECT listing_activity.date_nk,
                listing_activity.country_sk,
                listing_activity.category_sk,
                listing_activity.channel_sk,
                SUM(listing_activity.num_adviews)            AS organic_adviews,
                SUM(listing_activity.num_impressions)        AS organic_impressions,
                SUM(listing_activity.num_replies)            AS organic_replies
        FROM panameraods.ods.fact_listing_activity listing_activity
        WHERE listing_activity.date_nk > '2019-11-18'
        GROUP BY listing_activity.date_nk,
                 listing_activity.country_sk,
                 listing_activity.category_sk,
                 listing_activity.channel_sk),
     paid AS
        (SELECT paid_products.date_featured_nk      AS date_nk,
       paid_products.country_sk,
       paid_products.category_sk,
       paid_products.channel_sk,
       SUM(paid_products.num_adviews)               AS paid_adviews,
       SUM(paid_products.num_impressions)           AS paid_impressions,
       SUM(paid_products.num_replies)               AS paid_replies
FROM panameraods.ods.fact_items_with_paid_products paid_products
WHERE paid_products.date_featured_nk > '2019-11-18'
GROUP BY paid_products.date_featured_nk,
         paid_products.country_sk,
         paid_products.category_sk,
         paid_products.channel_sk)
SELECT
    organic.date_nk,
    organic.country_sk,
    organic.category_sk,
    organic.channel_sk,
    organic.organic_adviews,
    organic.organic_impressions,
    organic.organic_replies,
    paid.paid_adviews,
    paid.paid_impressions,
    paid.paid_replies
FROM organic
LEFT JOIN paid
ON organic.date_nk = paid.date_nk AND
   organic.country_sk = paid.country_sk AND
   organic.category_sk = paid.category_sk AND
   organic.channel_sk = paid.channel_sk
ORDER BY
    organic.date_nk, organic.country_sk, organic.category_sk, organic.channel_sk



