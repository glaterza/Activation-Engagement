WITH resultset AS (
                    SELECT  resultset_perf.date_nk,
                            resultset_perf.buyer_flow,
                            resultset_perf.channel_sk,
                            resultset_perf.category_sk,
                            resultset_perf.resultset_type,
                            resultset_perf.origin_nk,
                            (COUNT (DISTINCT user_sk))                                          AS users,
                            (SUM(resultset_perf.num_ads_with_adviews))                          AS adviews,
                            (SUM(resultset_perf.num_ads_with_impressions))                      AS ads_with_impressions,
                            (SUM(resultset_perf.num_ads_with_item_chat_tap_send_1st_reply))     AS ads_chat_tap_send_1streply,
                            (SUM(resultset_perf.num_ads_with_item_chat_tap_send_offer))         AS ads_chat_tap_send_offer,
                            (SUM(resultset_perf.num_ads_with_item_chat_tap_sms))                AS ads_chat_tap_sms,
                            (SUM(resultset_perf.num_ads_with_item_tap_call))                    AS ads_tap_call
                    FROM panameraods.ods.fact_resultset_performance resultset_perf
                    WHERE date_nk > '2019-11-24'
                    GROUP BY date_nk,
                             channel_sk,
                             category_sk,
                             buyer_flow,
                             resultset_type,
                             origin_nk
                    ORDER BY date_nk, buyer_flow
                    ),
     channels AS (
                    SELECT dim_channels.channel_sk,
                           dim_channels.channel_l1_name,
                           dim_channels.channel_l2_name,
                           dim_channels.channel_l3_name,
                           dim_channels.channel_l4_name,
                           dim_channels.channel_l5_name,
                           dim_channels.channel_name
                    FROM panameraods.ods.dim_channels
     ),
     categories AS (SELECT dim_categories.category_sk,
                           dim_categories.global_category_l1_name,
                           dim_categories.global_category_l2_name,
                           dim_categories.group_name,
                           dim_categories.region_name,
                           dim_categories.country_name,
                           dim_categories.category_l1_name_en,
                           dim_categories.category_l2_name_en,
                           dim_categories.category_l3_name_en,
                           dim_categories.category_l4_name_en,
                           dim_categories.category_l5_name_en,
                           dim_categories.category_name_en
                    FROM panameraods.ods.dim_categories
     )
SELECT
        resultset.date_nk,
        resultset.channel_sk,
        resultset.category_sk,
        resultset.buyer_flow,
        resultset.resultset_type,
        resultset.origin_nk,
        channels.channel_l1_name,
        channels.channel_l2_name,
        channels.channel_l3_name,
        channels.channel_l4_name,
        channels.channel_l5_name,
        channels.channel_name,
        categories.global_category_l1_name,
        categories.global_category_l2_name,
        categories.group_name,
        categories.region_name,
        categories.country_name,
        categories.category_l1_name_en,
        categories.category_l2_name_en,
        categories.category_l3_name_en,
        categories.category_l4_name_en,
        categories.category_l5_name_en,
        categories.category_name_en,
        resultset.users,
        resultset.adviews,
        resultset.ads_with_impressions,
        resultset.ads_chat_tap_send_1streply,
        resultset.ads_chat_tap_send_offer,
        resultset.ads_tap_call,
        resultset.ads_chat_tap_sms
FROM resultset
LEFT JOIN channels ON resultset.channel_sk = channels.channel_sk
LEFT JOIN categories ON resultset.category_sk = categories.category_sk;