--SELECT *
--FROM dsv1069.events
--ORDER BY event_time ASC

--SELECT *
--FROM dsv1069.users
--LIMIT 1000


-- Extracting access methods mobile web users use

SELECT 
    event_id, event_time, user_id, platform, 
    MIN(CASE WHEN parameter_name = 'item_id' 
         THEN CAST(parameter_value AS INT)
         ELSE NULL 
    END) AS item_id,
    MIN(CASE WHEN parameter_name = 'referrer' 
         THEN parameter_value 
         ELSE NULL 
    END) AS referrer
FROM dsv1069.events_ex2
WHERE platform = 'mobile web'
GROUP BY event_id, event_time, user_id, platform
ORDER BY event_time ASC


-- Format view item event

SELECT
  event_time,
  event_id,
  user_id,
  platform,
  MAX(CASE
      WHEN parameter_name = 'item_id' 
      THEN CAST(parameter_value AS INT)
      ELSE NULL 
    END ) AS item_id,
  MAX(CASE
      WHEN parameter_name = 'referrer' 
      THEN parameter_value 
      ELSE NULL 
    END ) AS referrer
FROM
  dsv1069.events
WHERE
  event_name = 'view_item'
GROUP BY event_time,
  event_id,
  user_id,
  platform
ORDER BY event_id\


-- Count of users who placed orders

SELECT if_ordered, COUNT(if_ordered) AS count_
FROM (SELECT 
   u.id AS user_id, 
   MIN(o.paid_at) AS first_ordered_at, 
   CASE 
      WHEN MIN(o.paid_at) IS NULL THEN false
      ELSE true
      END AS if_ordered
FROM dsv1069.users u  
    LEFT OUTER JOIN dsv1069.orders o 
    ON o.user_id = u.id
GROUP BY u.id) i
GROUP BY if_ordered


-- Percentage of view profile page event

SELECT 
  (CASE 
    WHEN first_view IS NULL THEN false
    ELSE true
  END) AS has_viewed_pfp,
  COUNT(user_id) AS users
FROM 
   (SELECT 
     u.id AS user_id,
     MIN(event_time) AS first_view,
     MAX(event_time) AS latest_view
    FROM dsv1069.users u LEFT OUTER JOIN 
       (SELECT * 
        FROM dsv1069.events 
        WHERE event_name = 'view_user_profile') e 
     ON e.user_id = u.id 
    GROUP BY u.id) v 
GROUP BY 
  (CASE WHEN first_view IS NULL THEN false
    ELSE true 
    END)
