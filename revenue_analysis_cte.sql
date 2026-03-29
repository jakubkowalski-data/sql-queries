#Analiza przychodów według kontynentu z podziałem na urządzenia i użytkowników.

WITH base AS (
  SELECT
    IFNULL(sp.continent, 'Unknown') AS continent,
    p.price,
    LOWER(sp.device) AS device,
    sp.ga_session_id,
    acc_s.account_id,
    acc.is_verified
  FROM `DA.order` o
  JOIN `DA.product` p
    ON o.item_id = p.item_id
  JOIN `DA.session_params` sp
    ON o.ga_session_id = sp.ga_session_id


  LEFT JOIN `DA.account_session` acc_s
    ON sp.ga_session_id = acc_s.ga_session_id


  LEFT JOIN `DA.account` acc
    ON acc_s.account_id = acc.id
),


aggregated AS (
  SELECT
    continent,


    SUM(price) AS revenue,


    SUM(CASE WHEN device = 'mobile' THEN price ELSE 0 END) AS revenue_mobile,
    SUM(CASE WHEN device = 'desktop' THEN price ELSE 0 END) AS revenue_desktop,


    COUNT(DISTINCT account_id) AS account_count,


    COUNT(DISTINCT CASE
      WHEN is_verified = 1 THEN account_id
    END) AS verified_account,


    COUNT(DISTINCT ga_session_id) AS session_count


  FROM base
  GROUP BY continent
),


total AS (
  SELECT SUM(revenue) AS total_revenue
  FROM aggregated
)


SELECT
  continent AS Continent,
  revenue AS Revenue,
  revenue_mobile AS `Revenue from Mobile`,
  revenue_desktop AS `Revenue from Desktop`,
  ROUND(SAFE_DIVIDE(revenue, total_revenue) * 100, 2) AS `% Revenue from Total`,
  account_count AS `Account Count`,
  verified_account AS `Verified Account`,
  session_count AS `Session Count`
FROM aggregated
CROSS JOIN total
ORDER BY Revenue DESC;

