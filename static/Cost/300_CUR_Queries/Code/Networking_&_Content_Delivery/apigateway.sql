SELECT 
  bill_payer_account_id,
  line_item_usage_account_id,
  SPLIT_PART(line_item_resource_id, 'apis/', 2) as split_line_item_resource_id,
  DATE_FORMAT(line_item_usage_start_date,'%Y-%m-%d') AS day_line_item_usage_start_date,
  CASE  
    WHEN line_item_usage_type LIKE '%%ApiGatewayRequest%%' OR line_item_usage_type LIKE '%%ApiGatewayHttpRequest%%' THEN 'Requests' 
    WHEN line_item_usage_type LIKE '%%DataTransfer%%' THEN 'Data Transfer'
    WHEN line_item_usage_type LIKE '%%Message%%' THEN 'Messages'
    WHEN line_item_usage_type LIKE '%%Minute%%' THEN 'Minutes'
    WHEN line_item_usage_type LIKE '%%CacheUsage%%' THEN 'Cache Usage'
    ELSE 'Other'
  END AS case_line_item_usage_type,
  SUM(CAST(line_item_usage_amount AS double)) AS sum_line_item_usage_amount,
  SUM(CAST(line_item_unblended_cost AS decimal(16,8))) AS sum_line_item_unblended_cost
FROM 
  ${table_name}
WHERE
  year = '2020' AND (month BETWEEN '7' AND '9' OR month BETWEEN '07' AND '09')
  AND product_product_name = 'Amazon API Gateway'
  AND line_item_line_item_type NOT IN ('Tax','Credit','Refund','EdpDiscount','Fee','RIFee')
GROUP BY
  bill_payer_account_id, 
  line_item_usage_account_id,
  DATE_FORMAT(line_item_usage_start_date,'%Y-%m-%d'),
  line_item_resource_id,
  line_item_usage_type
ORDER BY
  sum_line_item_unblended_cost DESC;
